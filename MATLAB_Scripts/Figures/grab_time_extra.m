clear
close all

%load post-processed big merge matrix
bmm = readtable(''); %big_merge_matrix
bmm(strcmp(bmm.Trial,'E'),:) = []; bmm(bmm.Mouse == 23,:) = []; grab_table = bmm(bmm.Grab == 1 & bmm.Success == 1,:);
summary_table = readtable(''); %summary table

for grab = 1:size(grab_table,1) 

file = strcat(grab_table.Folder(grab),'/',grab_table.Video(grab),'.csv'); csv = readtable(string(file));

%DEFINE VARIABLES
%load
csv.x(strcmp(csv.bodyparts,'Hand') & csv.likelihood < 0.999) = NaN; 

%find corners for calibration
cornerup = [nanmean(csv.x(strcmp(csv.bodyparts,'CornerUp') & csv.box == grab_table.Box(grab) & csv.likelihood > 0.9)),...
nanmean(csv.y(strcmp(csv.bodyparts,'CornerUp') & csv.box == grab_table.Box(grab) & csv.likelihood > 0.9))];
cornerdown = [nanmean(csv.x(strcmp(csv.bodyparts,'CornerDown') & csv.box == grab_table.Box(grab) & csv.likelihood > 0.9)),...
nanmean(csv.y(strcmp(csv.bodyparts,'CornerDown') & csv.box == grab_table.Box(grab) & csv.likelihood > 0.9))];

calib_dist = sqrt((cornerup(1,1)-cornerdown(1,1))^2 + (cornerup(1,2)-cornerdown(1,2))^2);
calib_const = 213.7; calib_ratio = calib_const/calib_dist;

%TABLE: get bodypart [x, y, frames]
hand_t = [csv.x(strcmp(csv.bodyparts,'Hand') & csv.box == grab_table.Box(grab)),...
csv.y(strcmp(csv.bodyparts,'Hand') & csv.box == grab_table.Box(grab)),...
csv.frames(strcmp(csv.bodyparts,'Hand') & csv.box == grab_table.Box(grab))];

%clear tables of uncertain coordinates (what remains are x, y, frames with likelihood > 1)
hand_t = hand_t(~isnan(hand_t(:,1)),:);
if isempty(hand_t), [hand_t, hand_d, hand_dx, hand_dy] = deal([]); disp('File empty!'); return; end

%find gaps and interpolate missing NaN values
if hand_t(1,3) == 0, hand_t(:,3) = hand_t(:,3) + 1; end %if frames start with 0 (DeepLabCut default)
range = hand_t(1,3):hand_t(end,3); range = range';

new_hand_t = nan(length(range),3);
new_hand_t(ismember(range,hand_t(:,3)),:) = hand_t;
hand_t = [fillmissing(new_hand_t(:,1),'movmean',6), fillmissing(new_hand_t(:,2),'movmean',6), fillmissing(new_hand_t(:,3),'linear')];
%fill in smaller gaps in coordinate data using a moving mean, fill in corresponding frames linearly, i.e. 1 2 NaN 3 4 5

%DELTA: delta x, delta y, delta (x+y)
hand_dx = hand_t(2:end, 1)-hand_t(1:end-1, 1);
if grab_table.Box(grab) == 3 || grab_table.Box(grab) == 4, hand_dx = -hand_dx; end
hand_dy = hand_t(2:end, 2)-hand_t(1:end-1, 2);

%MOVMEAN: get movmeans (smoothen the curve, movmean is user's choice)
movmean_points = 5;

hand_dx = movmean(hand_dx, movmean_points); hand_dy = movmean(hand_dy, movmean_points); hand_d = [hand_dx + hand_dy, hand_t(2:end,3)];

%new from 06/05/2022 to polish signal -> does NOT change peaks and troughs significantly
hand_dx = movmean(hand_dx(:,1),10); hand_dy = movmean(hand_dy(:,1),10);
hand_d = [movmean(hand_d(:,1),10) hand_d(:,2)];

%table turn time
gtime = grab_table.Frame(grab); %time of slip occurence
idx = find(hand_d(:,2) == gtime); %index of gtime
check = 50; %check left and right of turn to fill missing values
to_end = length(hand_d)-idx; if to_end < check, check = to_end - 1; end; if check > idx, check = idx - 1; end
%hand_d(idx-check:idx+check,1) = fillmissing(hand_d(idx-check:idx+check,1),'linear');
if any(isnan(hand_d(idx-check:idx+check,1))), grab_table.GrabDepth(grab) = NaN; grab_table.GrabTime(grab) = NaN; continue; end

%first try to find start/end of all peaks
dy = diff(hand_d(:,1)); dx = diff(hand_d(:,2)); %DIFFERENT: get derivatives from vertical motion only
dy_dx = [0; dy./dx];

%NOTE: we are working with a signal that has differing indices and frames, meaning that index does not equal frame number
peak = find(hand_d(:,2) < gtime & (dy_dx >= 0) & hand_d(:,1) > 1.5, 1, 'last'); %peak is an indice unlike stime

turn = find(hand_d(:,2) > hand_d(peak,2) & (dy_dx >= 0) & hand_d(:,1) < 1.5, 1, 'first'); %recalibrate turn 
if isempty(turn), turn = length(hand_d(:,2)); end %if mouse pulls the pellet from the screen

points_inbetween = find(hand_d(:,2) > hand_d(peak,2) & hand_d(:,2) < hand_d(turn,2)); 
[alt_point, alt_position] = min(abs(hand_d(points_inbetween,1))); 
if alt_point < abs(hand_d(turn,1)), turn = points_inbetween(alt_position); end 

trough = find(hand_d(:,2) > hand_d(turn,2) & (dy_dx >= 0) & hand_d(:,1) < -1.5, 1, 'first'); 
if isempty(trough), trough = turn; end %if mouse pulls the pellet from the screen

spoint = find(hand_d(:,2) < hand_d(peak,2) & (dy_dx <= 0) & hand_d(:,1) < 1.5, 1, 'last'); %last condition to remain reasonably close to 0
%make sure peaktop also has a certain value (minimal peak height), as well as peakbottom(s) (maximal start/end value)

if isempty(spoint) %if signal begins abruptly without dy/dx = 0
    spoint = 1;
end

points_inbetween = find(hand_d(:,2) > hand_d(spoint,2) & hand_d(:,2) < hand_d(peak,2)); %find points between start and peak
[alt_point, alt_position] = min(abs(hand_d(points_inbetween,1))); %find point closest to zero
if alt_point < abs(hand_d(spoint,1)), spoint = points_inbetween(alt_position); end %if the point has a smaller value than current starting point, replace

epoint = find(hand_d(:,2) > hand_d(trough,2) & (dy_dx <= 0) & hand_d(:,1) > -1.5, 1, 'first') - 1; %find the nearest point right of peak, whose derivative is equal to 0

if isempty(epoint) %if signal ends abruptly without dy/dx = 0
    epoint = length(hand_d(:,2));
end

points_inbetween = find(hand_d(:,2) < hand_d(epoint,2) & hand_d(:,2) > hand_d(trough,2));
[alt_point, alt_position] = min(abs(hand_d(points_inbetween,1)));
if alt_point < abs(hand_d(epoint,1)), epoint = points_inbetween(alt_position); end

endpoints = epoint;    

grab_table.GrabDepth(grab) = (hand_t(turn+1,2)-hand_t(epoint+1,2))*calib_ratio; %grab starts from pellet, unlike slips (y is reversed)
grab_table.GrabTime(grab) = hand_d(epoint,2)-hand_d(turn,2); %from pellet grab to end = time held
end

grab_table(:,{'GrabDepth','GrabTime'}) = filloutliers(grab_table(:,{'GrabDepth','GrabTime'}),NaN,'percentiles',[1 99]);

grabs_grouped = groupsummary(grab_table(:,{'Day','Mouse','Hand','GrabDepth','GrabTime'}),["Day","Mouse","Hand"],"mean");
%plot(grabs_grouped.Day(strcmp(grabs_grouped.Hand,'R')),grabs_grouped.mean_GrabTime(strcmp(grabs_grouped.Hand,'R')),'kx')

%DEBUG
% plot(hand_d(:,2),hand_d(:,1)); hold on; plot(hand_d(spoint,2),hand_d(spoint,1),'xr'); plot(hand_d(epoint,2),hand_d(epoint,1),'xr'); 
% plot(hand_d(peak,2),hand_d(peak,1),'xg'); plot(hand_d(trough,2),hand_d(trough,1),'xg');

%integrate into summary table
%summary_table.GrabbedTime = []; summary_table.GrabbedEvents = [];

for i = 1:size(grabs_grouped,1)
summary_table.GrabDepth(summary_table.Day == grabs_grouped.Day(i) & summary_table.Mouse == grabs_grouped.Mouse(i)...
 & strcmp(summary_table.Hand,grabs_grouped.Hand(i))) = grabs_grouped.mean_GrabDepth(i);
summary_table.GrabTime(summary_table.Day == grabs_grouped.Day(i) & summary_table.Mouse == grabs_grouped.Mouse(i)...
 & strcmp(summary_table.Hand,grabs_grouped.Hand(i))) = grabs_grouped.mean_GrabTime(i);
end

%find missing values
for j = 1:size(summary_table,1)
if summary_table.SuccessEvents(j) > 0 && summary_table.GrabDepth(j) == 0, summary_table.GrabDepth(j) = NaN; end
if summary_table.SuccessEvents(j) > 0 && summary_table.GrabTime(j) == 0, summary_table.GrabTime(j) = NaN; end
%summary_table.GrabTime(j) = mean(summary_table.GrabTime(summary_table.Day == summary_table.Day(j) & strcmp(summary_table.Hand,summary_table.Hand(j)) & summary_table.GrabTime > 0));
end
summary_table.GrabDepth(summary_table.GrabDepth ~= 0) = fillmissing(summary_table.GrabDepth(summary_table.GrabDepth ~= 0),'linear');
summary_table.GrabTime(summary_table.GrabTime ~= 0) = fillmissing(summary_table.GrabTime(summary_table.GrabTime ~= 0),'linear');

%convert to centimeters
c = 0.027; %1 pixel = 0.027 centimeters
s = 0.01; %1 frame = 0.01 seconds
summary_table.GrabDepth = summary_table.GrabDepth.*c; summary_table.GrabTime = summary_table.GrabTime.*s;

summary_table.SlipDepth(summary_table.SlipDepth == 0) = NaN; summary_table.SlipTime(summary_table.SlipTime == 0) = NaN;
summary_table.GrabDepth(summary_table.GrabDepth == 0) = NaN; summary_table.GrabTime(summary_table.GrabTime == 0) = NaN;

%writetable(summary_table,'');
