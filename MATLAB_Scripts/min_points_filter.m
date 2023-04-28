function [turning_points, turning_peaks, turning_min] = min_points_filter(turning_points, turning_peaks, turning_min, hand_d)
%MIN_POINTS_FILTER Summary of this function goes here


%%%%%%%%%%%%%MINIMUM TRAJECTORY POINTS FILTERING
for i=1:length(turning_points(:,1)) %take out turning points if they have only one (or no) points between themselves and a peak/min

points_amount_peak = length(hand_d(hand_d(:,2) > hand_d(hand_d(:,2)==turning_peaks(i,2),2) & hand_d(:,2) < hand_d(hand_d(:,2)==turning_points(i,2),2),1));
points_amount_min = length(hand_d(hand_d(:,2) < hand_d(hand_d(:,2)==turning_min(i,2),2) & hand_d(:,2) > hand_d(hand_d(:,2)==turning_points(i,2),2),1));
traj_points_threshold = 2; %was 3

if points_amount_peak < traj_points_threshold || points_amount_min < traj_points_threshold, turning_points(i,2) = NaN; end 

end

nan_position = find(isnan(turning_points(:,2)));

%turning_points = [turning_points(turning_points(:,2) ~= 0, 1) turning_points(turning_points(:,2) ~= 0, 2) turning_points(turning_points(:,2) ~= 0, 3) turning_points(turning_points(:,2) ~= 0, 4)];
turning_points(nan_position,:) = []; turning_peaks(nan_position,:) = []; turning_min(nan_position,:) = [];

%%%%%%%%%%%%%MINIMUM TRAJECTORY POINTS FILTERING

end

