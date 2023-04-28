clear
close all

%load post-processed big merge matrix
bmm = readtable(''); %big_merge_matrix
bmm(strcmp(bmm.Trial,'E'),:) = []; bmm(bmm.Mouse == 23,:) = []; slips_table = bmm(bmm.Grab == 2,:);
summary_table = readtable(''); %summary table

for slip = 1:size(slips_table,1)

file = strcat(slips_table.Folder(slip),'/',slips_table.Video(slip),'.csv'); csv = readtable(string(file));

%DEFINE VARIABLES
%load
csv.x(strcmp(csv.bodyparts,'Hand') & csv.likelihood < 0.999) = NaN; 

%find corners to restrict slips from glass (and not platform) and for calibration
cornerup = [nanmean(csv.x(strcmp(csv.bodyparts,'CornerUp') & csv.box == slips_table.Box(slip) & csv.likelihood > 0.9)),...
nanmean(csv.y(strcmp(csv.bodyparts,'CornerUp') & csv.box == slips_table.Box(slip) & csv.likelihood > 0.9))];
cornerdown = [nanmean(csv.x(strcmp(csv.bodyparts,'CornerDown') & csv.box == slips_table.Box(slip) & csv.likelihood > 0.9)),...
nanmean(csv.y(strcmp(csv.bodyparts,'CornerDown') & csv.box == slips_table.Box(slip) & csv.likelihood > 0.9))];

calib_dist = sqrt((cornerup(1,1)-cornerdown(1,1))^2 + (cornerup(1,2)-cornerdown(1,2))^2);
calib_const = 213.7; calib_ratio = calib_const/calib_dist;

%TABLE: get bodypart [x, y, frames]
hand_t = [csv.x(strcmp(csv.bodyparts,'Hand') & csv.box == slips_table.Box(slip)),...
csv.y(strcmp(csv.bodyparts,'Hand') & csv.box == slips_table.Box(slip)),...
csv.frames(strcmp(csv.bodyparts,'Hand') & csv.box == slips_table.Box(slip))];

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
if slips_table.Box(slip) == 3 || slips_table.Box(slip) == 4, hand_dx = -hand_dx; end
hand_dy = hand_t(2:end, 2)-hand_t(1:end-1, 2);

%MOVMEAN: get movmeans (smoothen the curve, movmean is user's choice)
movmean_points = 5;

hand_dx = movmean(hand_dx, movmean_points); hand_dy = movmean(hand_dy, movmean_points); hand_d = [hand_dx + hand_dy, hand_t(2:end,3)];

%new from 06/05/2022 to polish signal -> does NOT change peaks and troughs significantly
hand_dx = movmean(hand_dx(:,1),10); hand_dy = movmean(hand_dy(:,1),10);
hand_d = [movmean(hand_d(:,1),10) hand_d(:,2)];

%Quantify start/end for peaks
stime = slips_table.Frame(slip); %time of slip occurence
% idx = find(hand_d(:,2) == stime); %index of stime
% check = 50; %check left and right of turn to find missing values
% to_end = length(hand_dy)-idx; if to_end < check, check = to_end - 1; end; if check > idx, check = idx - 1; end
%if any(isnan(hand_dy(idx-check:idx+check))), slips_table.SlipDepth(slip) = NaN; slips_table.SlipTime(slip) = NaN; continue; end %if signal NaN

%first try to find start/end of all peaks
dy = diff(hand_dy); dx = diff(hand_d(:,2)); %DIFFERENT: get derivatives from vertical motion only
dy_dx = [0; dy./dx];

%NOTE: we are working with a signal that has differing indices and frames, meaning that index does not equal frame number
peaktop = find(hand_d(:,2) < stime & (dy_dx >= 0) & hand_dy > 0.75, 1, 'last'); if isempty(peaktop), peaktop = 1; end %peaktop is an indice unlike stime
spoint = find(hand_d(:,2) < hand_d(peaktop,2) & (dy_dx <= 0) & hand_dy < 0.25, 1, 'last'); 
%make sure peaktop also has a certain value (minimal peak height), as well as peakbottom(s) (maximal start/end value)

if isempty(spoint) %if signal begins abruptly without dy/dx = 0
    spoint = 1;
end

points_inbetween = find(hand_d(:,2) > hand_d(spoint,2) & hand_d(:,2) < hand_d(peaktop,2)); %find points between start and peak
[alt_point, alt_position] = min(abs(hand_dy(points_inbetween))); %find point closest to zero
if alt_point < abs(hand_dy(spoint)), spoint = points_inbetween(alt_position); end %if the point has a smaller value than current starting point, replace

epoint = find(hand_d(:,2) > hand_d(peaktop,2) & (dy_dx >= 0) & hand_dy < 0.25, 1, 'first') - 1; %find the nearest point right of peak, whose derivative is equal to 0

if isempty(epoint) %if signal ends abruptly without dy/dx = 0
    epoint = length(hand_d(:,2));
end

points_inbetween = find(hand_d(:,2) < hand_d(epoint,2) & hand_d(:,2) > hand_d(peaktop,2));
[alt_point, alt_position] = min(abs(hand_dy(points_inbetween)));
if alt_point < abs(hand_dy(epoint)), epoint = points_inbetween(alt_position); end

endpoints = epoint;    

%define end and start y-point
y_end = hand_t(epoint+1,2); y_start = hand_t(spoint+1,2); %one extra timeframe because of shift between hand_d and hand_t

%correct values for slips from glass
plat_dist = 20*calib_ratio; %platform and CUP distance
if y_end < cornerup(1,2) - plat_dist %y position of the platform (empirical, uncalibrated)
y_end = cornerup(1,2) - plat_dist; %reposition slip start to the platform location
end

slips_table.SlipDepth(slip) = (y_end-y_start)*calib_ratio;
slips_table.SlipTime(slip) = hand_d(epoint,2)-hand_d(spoint,2);

%if slips_table.SlipDepth(slip) <= 5, slips_table.SlipDepth(slip) = NaN; end %cutoff value for hanging paws etc. 
end

slips_table(:,{'SlipDepth','SlipTime'}) = filloutliers(slips_table(:,{'SlipDepth','SlipTime'}),NaN,'percentiles',[1 98]); %also remove slips on the glass
slips_grouped = groupsummary(slips_table(:,{'Day','Mouse','Hand','SlipDepth','SlipTime'}),["Day","Mouse","Hand"],"mean");
%plot(slips_grouped.Day(strcmp(slips_grouped.Hand,'R')),slips_grouped.mean_SlipDepth(strcmp(slips_grouped.Hand,'R')),'kx')

%DEBUG
%plot(hand_d(:,2),hand_d(:,1)); hold on; plot(hand_d(spoint,2),hand_dy(spoint),'xr'); plot(hand_d(epoint,2),hand_dy(epoint),'xr'); plot(hand_d(:,2),hand_dy);

%integrate into summary table
summary_table.GrabbedTime = []; summary_table.GrabbedEvents = []; 

for i = 1:size(slips_grouped,1)
summary_table.SlipDepth(summary_table.Day == slips_grouped.Day(i) & summary_table.Mouse == slips_grouped.Mouse(i)...
 & strcmp(summary_table.Hand,slips_grouped.Hand(i))) = slips_grouped.mean_SlipDepth(i);
summary_table.SlipTime(summary_table.Day == slips_grouped.Day(i) & summary_table.Mouse == slips_grouped.Mouse(i)...
 & strcmp(summary_table.Hand,slips_grouped.Hand(i))) = slips_grouped.mean_SlipTime(i);
end

%check for missing slipdepth and sliptime values
for j = 1:size(summary_table,1)
if summary_table.SlipsCount(j) > 0 && summary_table.SlipDepth(j) == 0, summary_table.SlipDepth(j) = NaN; end
%summary_table.SlipDepth(j) = mean(summary_table.SlipDepth(summary_table.Day == summary_table.Day(j) & strcmp(summary_table.Hand,summary_table.Hand(j)) & summary_table.SlipDepth > 0));
if summary_table.SlipsCount(j) > 0 && summary_table.SlipTime(j) == 0, summary_table.SlipTime(j) = NaN; end
end
summary_table.SlipDepth(summary_table.SlipDepth ~= 0) = fillmissing(summary_table.SlipDepth(summary_table.SlipDepth ~= 0),'linear');
summary_table.SlipTime(summary_table.SlipTime ~= 0) = fillmissing(summary_table.SlipTime(summary_table.SlipTime ~= 0),'linear');

%convert to centimeters
c = 0.027; %1 pixel = 0.027 centimeters
s = 0.01; %1 frame = 0.01 seconds

summary_table.SlipDepth = summary_table.SlipDepth.*c; summary_table.SlipTime = summary_table.SlipTime.*s;

%writetable(summary_table,'');
