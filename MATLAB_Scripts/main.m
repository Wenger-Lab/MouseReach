clear

%empiric grabbing parameters
shortest_grabbing_time = 10; %minimal physiological time between grabs (used to define movmeans)
average_grabbing_time = 20; %most frequently observed grabbing duration
longest_grabbing_time = 40; %max duration used to search for minima) corresponding to peaks; used to be 60
grabbing_duration = longest_grabbing_time/2; %plotting parameter

%calibration constant
calib_const = 213.7; %pixels; distance between corner up and corner down in RL, equals to 5.77 cm

%INITIATE LOOPS OVER ALL FILES
project_table = readtable(''); %experimental table that allocates mice to groups and staircase boxes
directory = ''; %location of CSVs
days = dir(directory); days = {days(3:end).name}; days = char(days);
[~,sort_days] = sort(str2num(days(:,2:end))); days = days(sort_days,:); %#ok<ST2NM> %sort ascending

%reaches counting
[total_grabs_count_l_c, total_grabs_count_r_c, total_grabs_count_l_e, total_grabs_count_r_e] = deal(zeros(max(project_table.ID),size(days,1)));
%pellet counting
[total_pellets_count_l_c, total_pellets_count_r_c, total_pellets_count_l_e, total_pellets_count_r_e] = deal(zeros(max(project_table.ID),size(days,1)));
outliers = {}; %for pellet outliers (i.e. hand in video)

big_merge_matrix = table('Size', [1,16], 'VariableTypes', {'cell','double','double','double','double','double','double','cell','double','double','double','double','double','double','double','cell'}, ...
    'VariableNames', {'Video','Frame','x','y','Grab','Pellet','Success','Hand','Box','Camera','Trial','Mouse','Subgroup','Group','Day','Folder'});
%file_tracking = {}; %for debugging

kinematic_matrix = table('Size', [1,49], 'VariableTypes', {'double','double','double','double','double','double','double','double','double','double','double',...
'double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double', 'double', ...
'double','double','double','double','double','double','double','double','double','double','double', 'double','double','double','double','double','double','double','double','double'}, ...
'VariableNames', {'TotalDur','FlexDur','ExtDur','FlexDurPer','ExtDurPer','PathLen','ReachDist','AvgSpeedTotal','AvgSpeedFlex','AvgSpeedExt','MaxSpeedTotal','MaxSpeedFlex',...
'MaxSpeedExt', 'AvgAccTotal','AvgAccFlex', 'AvgAccExt','MaxAccTotal','MaxAccFlex','MaxAccExt','AvgDecTotal','AvgDecFlex','AvgDecExt', 'MaxDecTotal', 'MaxDecFlex', 'MaxDecExt',...
'T_MaxSpeedTotal','T_MaxSpeedFlex','T_MaxSpeedExt','T_MaxAccTotal', 'T_MaxAccFlex', 'T_MaxAccExt','T_MaxDecTotal', 'T_MaxDecFlex', 'T_MaxDecExt',...
'TPerc_MaxSpeedTotal','TPerc_MaxSpeedFlex','TPerc_MaxSpeedExt','TPerc_MaxAccTotal', 'TPerc_MaxAccFlex', 'T_PercMaxAccExt','TPerc_MaxDecTotal', 'TPerc_MaxDecFlex',...
'TPerc_MaxDecExt','OnsetSpeedFlex', 'OnsetSpeedExt','OnsetAccFlex','OnsetAccExt','OnsetDecFlex', 'OnsetDecExt'});

huge_merge_matrix = table('Size',[1,65],'VariableTypes',{'cell','double','double','double','double','double','double','cell','double','double','double',...
'double','double','double','double','cell','double','double','double','double','double','double','double','double','double','double','double','double',...
'double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double', 'double', ...
'double','double','double','double','double','double','double','double','double','double','double', 'double','double','double','double','double','double',...
'double','double','double'},'VariableNames', {'Video','Frame','x','y','Grab','Pellet','Success','Hand','Box','Camera','Trial','Mouse','Subgroup','Group','Day',...
'Folder','TotalDur','FlexDur','ExtDur','FlexDurPer','ExtDurPer','PathLen','ReachDist','AvgSpeedTotal','AvgSpeedFlex','AvgSpeedExt','MaxSpeedTotal','MaxSpeedFlex',...
'MaxSpeedExt', 'AvgAccTotal','AvgAccFlex', 'AvgAccExt','MaxAccTotal','MaxAccFlex','MaxAccExt','AvgDecTotal','AvgDecFlex','AvgDecExt', 'MaxDecTotal', 'MaxDecFlex',...
'MaxDecExt','T_MaxSpeedTotal','T_MaxSpeedFlex','T_MaxSpeedExt','T_MaxAccTotal', 'T_MaxAccFlex', 'T_MaxAccExt','T_MaxDecTotal', 'T_MaxDecFlex', 'T_MaxDecExt',...
'TPerc_MaxSpeedTotal','TPerc_MaxSpeedFlex','TPerc_MaxSpeedExt','TPerc_MaxAccTotal', 'TPerc_MaxAccFlex', 'T_PercMaxAccExt','TPerc_MaxDecTotal', 'TPerc_MaxDecFlex',...
'TPerc_MaxDecExt','OnsetSpeedFlex', 'OnsetSpeedExt','OnsetAccFlex','OnsetAccExt','OnsetDecFlex', 'OnsetDecExt'});

total_grabbed_time = table('Size',[1,6],'VariableTypes',{'double','double','cell','double','double','double'},'VariableNames',{'Day','Mouse','Hand','File','Events','Time'});

for day=1:size(days,1) %days folders
groups = dir(strcat(directory,'/',days(day,:))); groups = {groups(3:end).name}; groups = char(groups); disp(days(day,:)) %sort here too?

for group=1:size(groups,1) %group folders (below structure is specifically designed for a certain type of data structure)
mice = dir(strcat(directory, '/', days(day,:),'/', groups(group,:))); mice = {mice(3:end).name}; mice = char(mice);
if day == 4 && group == 4, mice = sortrows(mice, 4); disp(groups(group,:)); else,  mice = sortrows(mice, 3); disp(groups(group,:)); end
%file_tracking = [file_tracking; mice(1,:), mice(2,:), mice(3,:)];

for subgroup=1:size(mice,1) %mice folders (1-4; 5-8, etc.)
folder = strcat(directory,'/',days(day,:),'/',groups(group,:),'/', mice(subgroup,:)); disp(mice(subgroup,:))

for camera=1:2
if camera == 1, files = dir([folder,'/A*.csv']); elseif camera == 2, files = dir([folder,'/B*.csv']); end

%pellet parameters for the session with i.e. mice 1-4
s_pellet = ones(8, 4, length(files)); e_pellet = ones(8, 4, length(files)); %predefine pellets (pellet, box, file)
d_pellet = zeros(8, 4, length(files)); a_pellet = zeros(8, 4, length(files)); %check pellet_tracking.csv for more details
pellets_disappeared = zeros(4, length(files)); pellets_appeared = zeros(4, length(files)); pellets_missing = zeros(4, length(files));

for file = 1:length(files) %list folders %file
csv = readtable(strcat(folder,'/',files(file).name)); disp(files(file).name)

for box=1:4 %set box 

%FUNCTIONS (separate scripts)

%assign mouse labels
[cage, hand_side, trial_group, mouse_label, mouse_ID] = assign_mouse(project_table, day, group, subgroup, camera, box);
if isempty(trial_group) || isempty(hand_side) || isempty(mouse_ID), continue; end %if cannot assign mouse, move on (mouse was probably excluded later on in the experiment)

%include/exclude mice
%if ~ismember(mouse_ID,[1 2 3 4 5 6 7 8 9 10]), continue; end

%define variables
[csv, xo, vo, yo, hand_t, hand_d, hand_dx, hand_dy] = define_variables(csv, box, shortest_grabbing_time);
if isempty(hand_t), continue; end

%PELLETS before reaches (if zero reaches, loop skips to next iteration)
[pellet_events, pellet_coords, pellets_disappeared, pellets_appeared, pellets_missing, outliers, sig_pellets] = pellet_signal(shortest_grabbing_time, folder, files, file, box, pellets_disappeared, pellets_appeared, pellets_missing, outliers);

%find peaks
[hand_peaks, hand_peaksf, hand_min, hand_minf, slips_peaks, slips_peaksf, slips_min, slips_minf, grabs_count] = find_peaks(hand_d, shortest_grabbing_time);

if isempty(grabs_count) %if empty, it is a sign to run next functions
%movement filter
[hand_peaks, hand_peaksf, hand_min, hand_minf, slips_peaks, slips_peaksf, slips_min, slips_minf] = movement_filter(hand_t, hand_peaks, hand_peaksf, hand_min, hand_minf, slips_peaks, slips_peaksf, slips_min, slips_minf, average_grabbing_time, hand_dx, hand_dy);

%search function
[turning_points, turning_peaks, turning_min, grabs_count, highest_peaks, highest_peaksf, lows_content1] = search_function(hand_peaks, hand_peaksf, hand_min, hand_minf, hand_d, hand_t, longest_grabbing_time);
end

if isempty(grabs_count) %if still empty, do next functions
%minimal trajectory points filtering
[turning_points, turning_peaks, turning_min] = min_points_filter(turning_points, turning_peaks, turning_min, hand_d);

%diagonal filter
[grabs_count, reach_events, diagonal, horizontal, thr_line, turning_points, turning_peaks, turning_min, slips_peaks, slips_peaksf, slips_min, slips_minf, calib_dist] = ...
diagonal_filter(csv, box, turning_points, turning_peaks, turning_min, slips_peaks, slips_peaksf, slips_min, slips_minf); %now outputs real grabs_count

else
[diagonal, horizontal] = threshold_lines(csv, box); %calculate threshold lines anyway
reach_events = []; %reset reach_events in case they are not being overwritten by new events
end

%slips
if ~isempty(slips_peaksf) && ~isempty(slips_peaks)
slips_events = calculate_slips(hand_d, hand_t, slips_peaksf, slips_peaks, horizontal);
else
slips_events = [];
end

%plots within loops %only one function should be active at a time

%all reaches in a single box !!(comment/uncomment)!!
%plot_box(grabbing_duration, turning_points, reach_events, hand_t, diagonal, thr_line);

%single out specific reaching attempts !!(comment/uncomment)!!
%frame_wishlist = [205,261,602];
%plot_singles(grabbing_duration, frame_wishlist, diagonal, hand_t, hand_d, hand_dx, hand_dy, reach_events, highest_peaksf, lows_content1, hand_peaksf, hand_peaks, hand_minf, hand_min, longest_grabbing_time);

%count reaches & pellets
[total_grabs_count_r_c, total_grabs_count_l_c, total_grabs_count_r_e, total_grabs_count_l_e, total_pellets_count_r_c, total_pellets_count_l_c, total_pellets_count_r_e, total_pellets_count_l_e] = ...
count_table(grabs_count, day, trial_group, hand_side, mouse_ID, box, file, pellets_missing, total_grabs_count_r_c, total_grabs_count_l_c, total_grabs_count_r_e, total_grabs_count_l_e, total_pellets_count_r_c, total_pellets_count_l_c, total_pellets_count_r_e, total_pellets_count_l_e);

%total grab time (optional)
%total_grabbed_time = time_grabbed(csv,box,day,mouse_ID,hand_side,file,sig_pellets,pellet_coords,reach_events,pellet_events,total_grabbed_time);

%extract kinematic parameters
if exist('hand_d','var') && exist('turning_peaks','var') && exist('turning_points','var') && exist('turning_min','var') 
if sum(turning_peaks,'all') && sum(turning_points,'all') && sum(turning_min,'all')

calib_ratio = calib_const/calib_dist; %ratio between current CU/CD distance and ideal distance
%if calib_ratio < 1, video is zoomed in; if calib_ratio > 1, video is zoomed out

all_points = reach_parameters(hand_d, turning_peaks, turning_points, turning_min);
new_kinematic_row = extract_kinematic_param(all_points, hand_d, hand_dx, hand_dy, hand_t, calib_ratio);
%disp(calib_dist); disp(calib_ratio)

%incorporate kinematic parameters together with reaches for this video
if kinematic_matrix.TotalDur == 0
kinematic_matrix(1:size(new_kinematic_row,1),1:49) = num2cell(new_kinematic_row);
else
kinematic_matrix = [kinematic_matrix; num2cell(new_kinematic_row)]; %#ok<AGROW>
end

end
end

%compute reach & pellet matrix
[big_merge_matrix,new_reaches_matrix] = compute_matrix(big_merge_matrix, folder, day, group, subgroup, camera, files, file, box, reach_events, pellet_events, slips_events, pellet_coords, hand_side, trial_group, mouse_ID);

%merge simple matrix and kinematic matrix
if ~isempty(reach_events)
new_huge_row = [new_reaches_matrix num2cell(new_kinematic_row)]; %combine standard and kinematic parameters
huge_merge_matrix = [huge_merge_matrix; new_huge_row]; %#ok<AGROW>
end

clear reach_events pellet_events turning_points turning_peaks turning_min slips_events slips_peaks slips_peaksf horizontal

end %end box loop
end %end file loop
end %end camera loop
end %end mouse loop
end %end group loop
end %end day loop

%ADD TONGUE, SLIPS AND EXTRA
huge_merge_matrix = [huge_merge_matrix; [table2cell(big_merge_matrix(~isnan(big_merge_matrix.Success) | big_merge_matrix.Grab == 2,:)), ...
num2cell(NaN(length(big_merge_matrix.Success(~isnan(big_merge_matrix.Success) | big_merge_matrix.Grab == 2)), size(kinematic_matrix,2)))]];
huge_merge_matrix(1,:) = []; %drop first row because empty
huge_merge_matrix = sortrows(huge_merge_matrix,{'Day','Group','Subgroup','Camera','Video','Box','Frame'});

%reaches -- final variables to plot
% total_rightp_control = sum(total_grabs_count_r_c);
% total_leftp_control = sum(total_grabs_count_l_c);
% total_rightp_exp = sum(total_grabs_count_r_e);
% total_leftp_exp = sum(total_grabs_count_l_e);

%pellets -- final variables to plot
% pellets_rightp_control = sum(total_pellets_count_r_c); %total_pellets_count is per box and per day, not per group(!)
% pellets_leftp_control = sum(total_pellets_count_l_c);
% pellets_rightp_exp = sum(total_pellets_count_r_e);
% pellets_leftp_exp = sum(total_pellets_count_l_e);

%FINAL PLOTS
%all reaches from experiment !!(comment/uncomment)!!
%plot_all(total_leftp_exp, total_leftp_control, total_rightp_exp, total_rightp_control, pellets_leftp_exp, pellets_leftp_control, pellets_rightp_exp, pellets_rightp_control)

%WRITE TABLE
%writetable(big_merge_matrix, 'big_merge_matrix.xlsx', 'Sheet', 1)