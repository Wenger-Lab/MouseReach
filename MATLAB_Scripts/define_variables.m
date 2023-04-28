function [csv, xo, vo, yo, hand_t, hand_d, hand_dx, hand_dy] = define_variables(csv, box, shortest_grabbing_time)
%DEFINE_VARIABLES Summary of this function goes here

%DEFINE VARIABLES
%load
csv.x(strcmp(csv.bodyparts,'Hand') & csv.likelihood < 0.999) = NaN; %take out everything below certain likelihood for bodypart hands < 1 %0.999

%camera & box & bodypart FOR loops (maybe this goes into another script)
bodypart = 'Hand';

%TABLE: get bodypart [x, y, frames]
hand_t = [csv.x(strcmp(csv.bodyparts,bodypart) & csv.box == box), csv.y(strcmp(csv.bodyparts,bodypart) & csv.box == box), csv.frames(strcmp(csv.bodyparts,bodypart) & csv.box == box)];

%clear tables of uncertain coordinates (what remains are x, y, frames with likelihood > 1)
hand_t = hand_t(~isnan(hand_t(:,1)),:);
if isempty(hand_t), [xo, vo, yo, hand_t, hand_d, hand_dx, hand_dy] = deal([]); return; end

%find gaps and interpolate missing NaN values
if hand_t(1,3) == 0, hand_t(:,3) = hand_t(:,3) + 1; end %if frames start with 0 (DeepLabCut default)
range = hand_t(1,3):hand_t(end,3); range = range';

new_hand_t = nan(length(range),3);
new_hand_t(ismember(range,hand_t(:,3)),:) = hand_t;
hand_t = [fillmissing(new_hand_t(:,1),'movmean',6), fillmissing(new_hand_t(:,2),'movmean',6), fillmissing(new_hand_t(:,3),'linear')];
%fill in smaller gaps in coordinate data using a moving mean, fill in corresponding frames linearly, i.e. 1 2 NaN 3 4 5

%DELTA: delta x, delta y, delta (x+y)
hand_dx = hand_t(2:end, 1)-hand_t(1:end-1, 1);
if box == 3 || box == 4, hand_dx = -hand_dx; end
hand_dy = hand_t(2:end, 2)-hand_t(1:end-1, 2);

%original values before movmeans
xo = hand_dx; %hold on; plot(xo, 'b'); plot(hand_dx, 'r'); yline(0);
yo = hand_dy; %hold on; plot(yo, 'b'); plot(hand_dy,'r'); yline(0);
vo = [xo + yo, hand_t(2:end,3)]; %hold on; plot(vo(:,2), vo(:,1),'b'); plot(hand_d(:,2), hand_d(:,1),'r'); yline(0);
%hold on; plot(xo, 'r'); plot(yo, 'g'); yline(0); yline(t_jumps_threshold); yline(-t_jumps_threshold);

%FILTER OUT BIG TRAJECTORY JUMPS/SPIKES
% t_jumps_threshold = 10; %4
% hand_dx(hand_dx > t_jumps_threshold | hand_dx < -t_jumps_threshold) = NaN; %0
% hand_dy(hand_dy > t_jumps_threshold | hand_dy < -t_jumps_threshold) = NaN; %0

%MOVMEAN: get movmeans (smoothen the curve, movmean is user's choice)
movmean_points = shortest_grabbing_time/2; %if shortest_grab_time is 10, half of that is a peak, meaning 5, movmean has to be <= 5

hand_dx = movmean(hand_dx, movmean_points);
hand_dy = movmean(hand_dy, movmean_points);
hand_d = [hand_dx + hand_dy, hand_t(2:end,3)];
%hand_d = [fillmissing(hand_d(:,1),'linear'), hand_d(:,2)]; %fill NaNs if there are any after movmeans

%new from 06/05/2022 to polish signal -> does NOT change peaks and troughs significantly
hand_dx = movmean(hand_dx(:,1),10); hand_dy = movmean(hand_dy(:,1),10);
hand_d = [movmean(hand_d(:,1),10) hand_d(:,2)];
%look into this at a later stage

end

