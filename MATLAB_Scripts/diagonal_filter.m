function [grabs_count, reach_events, diagonal, horizontal, thr_line, turning_points, turning_peaks, turning_min, slips_peaks, slips_peaksf, slips_min, slips_minf, calib_dist] = ...
diagonal_filter(csv, box, turning_points, turning_peaks, turning_min, slips_peaks, slips_peaksf, slips_min, slips_minf)
%DIAGONAL_FILTER Summary of this function goes here

%%%%%%%%%%%%%DIAGONAL FILTERING
%introduce spatial filtering

%regular calculation
cornerup = [nanmean(csv.x(strcmp(csv.bodyparts,'CornerUp') & csv.box == box & csv.likelihood > 0.9)),...
nanmean(csv.y(strcmp(csv.bodyparts,'CornerUp') & csv.box == box & csv.likelihood > 0.9))];
cornerdown = [nanmean(csv.x(strcmp(csv.bodyparts,'CornerDown') & csv.box == box & csv.likelihood > 0.9)),...
nanmean(csv.y(strcmp(csv.bodyparts,'CornerDown') & csv.box == box & csv.likelihood > 0.9))];

%UPDATE 23/03/2023 CALIBRATION BETWEEN DATASETS
calib_dist = sqrt((cornerup(1,1)-cornerdown(1,1))^2 + (cornerup(1,2)-cornerdown(1,2))^2);

%DIAGONAL FILTER: defined by cornerup and cornerdown
f_reach_attempt = 15; %farthest reach attempt was within 20 pixels of the pellets, but only one; farthest reach was actually 7 pixels away %10
dist_wrist_pell = 15; %wrist and pellets are distanced app. 15 pixels (length of the fingers)
d_threshold = f_reach_attempt + dist_wrist_pell; %hence threshold is 35 

d_linspace = abs(cornerdown(1,1)-cornerup(1,1));
diagonal = [linspace(cornerup(1,1), cornerdown(1,1), d_linspace); linspace(cornerup(1,2), cornerdown(1,2), d_linspace)]'; %watch dimensions!

%horizontal threshold
horizontal = [linspace(cornerup(1,1), cornerdown(1,1), d_linspace); linspace(cornerup(1,2), cornerup(1,2), d_linspace)]';

%create a single filter out of the two
d_thr_line = [diagonal(:,1) diagonal(:,2)-d_threshold];
h_thr_line = [horizontal(:,1) horizontal(:,2)-dist_wrist_pell]; %here was dist_wrist_pellet before
thr_line = [diagonal(:,1) max(d_thr_line(:,2), h_thr_line(:,2))];

%check for occurence of reach near the diagonal line
grabs_check = zeros(size(turning_points,1),1);
for i=1:length(turning_points(:,1))
    [~, current_x] = min(abs(turning_points(i,3)-thr_line(:,1)));
    if thr_line(current_x,2)<=turning_points(i,4)
        grabs_check(i) = 1;
    end
end

%optional update 09/01/2022 for slips: add diagonally filtered out reaches
% slips_peaks = [slips_peaks turning_peaks(grabs_check == 0, 1)'];
% slips_peaksf = [slips_peaksf turning_peaks(grabs_check == 0, 2)'];
% slips_min = [slips_min turning_min(grabs_check == 0, 1)'];
% slips_minf = [slips_minf turning_min(grabs_check == 0, 2)'];
%%%

turning_points = [turning_points(grabs_check == 1, 1) turning_points(grabs_check == 1, 2) turning_points(grabs_check == 1, 3) turning_points(grabs_check == 1, 4)];
turning_peaks = [turning_peaks(grabs_check == 1, 1) turning_peaks(grabs_check == 1, 2)];
turning_min = [turning_min(grabs_check == 1, 1) turning_min(grabs_check == 1, 2)];

reach_events = turning_points(:,2:end); %[frames x y]
%reach_events = [turning_points(grabs_check == 1, 2) turning_points(grabs_check == 1, 3) turning_points(grabs_check == 1, 4)]; 
grabs_count = length(reach_events(:,1));
%%%%%%%%%%%%%DIAGONAL FILTERING




end

