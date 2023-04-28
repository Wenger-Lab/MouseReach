function new_kinematic_row = extract_kinematic_param(all_points, hand_d, hand_dx, hand_dy, hand_t, calib_ratio)

%take in reach parameters and use them to calculate kinematics

%all_points = [speak peak epeak turnpoint strough trough etrough]
%contains indices (positions) and NOT frames in the signal matrix

%predefine duration variables
[reach_duration, reach_dur_flex, reach_dur_ext, reach_flex_percent, reach_ext_percent] = deal(zeros(size(all_points,1),1));

%predefine path length and reach distance variables
[path_length, reach_distance] = deal(zeros(size(all_points,1),1));

%predefine speed, acceleration, deceleration and time-related variables
[average_speed_total, average_speed_flex, average_speed_ext, max_speed_total, max_speed_flex, max_speed_ext] = deal(zeros(size(all_points,1),1));
[average_acc_total, average_acc_flex, average_acc_ext, max_acc_total, max_acc_flex, max_acc_ext] = deal(zeros(size(all_points,1),1));
[average_dec_total, average_dec_flex, average_dec_ext, max_dec_total, max_dec_flex, max_dec_ext] = deal(zeros(size(all_points,1),1));

[max_speed_total_time, max_speed_flex_time, max_speed_ext_time, max_acc_total_time, max_acc_flex_time, max_acc_ext_time,...
max_dec_total_time, max_dec_flex_time, max_dec_ext_time] = deal(zeros(size(all_points,1),1));
[max_speed_total_time_perc, max_speed_flex_time_perc, max_speed_ext_time_perc, max_acc_total_time_perc, max_acc_flex_time_perc, max_acc_ext_time_perc,...
max_dec_total_time_perc, max_dec_flex_time_perc, max_dec_ext_time_perc] = deal(zeros(size(all_points,1),1));

[onset_speed_flex, onset_speed_ext, onset_acc_flex, onset_acc_ext, onset_dec_flex, onset_dec_ext] = deal(zeros(size(all_points,1),1));

for point = 1:size(all_points,1)
pstart = all_points(point,1); peak = all_points(point,2); pend = all_points(point,3); tpoint = all_points(point,4);
tstart = all_points(point,5); trough = all_points(point,6); tend = all_points(point,7);

%__Duration__
reach_duration(point) = hand_d(tend,2) - hand_d(pstart,2); %calculate phase duration
reach_dur_flex(point) = hand_d(pend,2) - hand_d(pstart,2);
reach_dur_ext(point) = hand_d(tend,2) - hand_d(tstart,2);

reach_flex_percent(point) = reach_dur_flex(point)/reach_duration(point);
reach_ext_percent(point) = reach_dur_ext(point)/reach_duration(point);

%__Path Length__ total path length from start to end
delta_length = zeros(length(pstart:tend),1); i = 1;
for index = pstart:tend
delta_length(i) = sqrt(hand_dx(index)^2 + hand_dy(index)^2);
delta_length(i) = delta_length(i)*calib_ratio; %correct video distance to a fixed value based on zoom
i = i + 1;
end
path_length(point) = sum(delta_length,'omitnan');

%define relative locations of peak and trough phases/checkpoints in delta_length
r_pstart = 1; r_peak = r_pstart+(peak-pstart); r_pend = r_pstart+(pend-pstart); r_tpoint = r_pstart+(tpoint-pstart);
r_tstart = r_pstart+(tstart-pstart); r_trough = r_pstart+(trough-pstart); r_tend = r_pstart+(tend-pstart);

%__Speed__ delta length divided by delta time, scalar unlike velocity
delta_speed = delta_length/1;
speed_flex = delta_speed(r_pstart:r_tpoint-1); %up to, but not tpoint means -1 frame
speed_ext = delta_speed(r_tpoint+1:r_tend);
if isempty(speed_flex), speed_flex = NaN; end; if isempty(speed_ext), speed_ext = NaN; end

average_speed_total(point) = mean([speed_flex; speed_ext],'omitnan'); %average of single speed instances per frame
average_speed_flex(point) = mean(speed_flex,'omitnan'); %from start to before tpoint
average_speed_ext(point) = mean(speed_ext,'omitnan'); %from after tpoint to tend
%alternative average flexion speed between two points:
%sqrt(abs(hand_t(tpoint-1,1)-hand_t(pstart,1))^2 + abs(hand_t(tpoint-1,2)-hand_t(pstart,2))^2)/(tpoint-1-pstart)

max_speed_total(point) = max([speed_flex; speed_ext]);
max_speed_flex(point) = max(speed_flex);
max_speed_ext(point) = max(speed_ext);

max_speed_total_time(point) = sum([speed_flex; speed_ext] >= floorS(max_speed_total(point),1)); %time for which max speed occurs in frames (while speed value > max speed integer)
max_speed_flex_time(point) = sum(speed_flex >= floorS(max_speed_flex(point),1));
max_speed_ext_time(point) = sum(speed_ext >= floorS(max_speed_ext(point),1));

max_speed_total_time_perc(point) = max_speed_total_time(point)/length([speed_flex; speed_ext]); %time over which max speed occurs for corresponding phase
max_speed_flex_time_perc(point) = max_speed_flex_time(point)/length(speed_flex); 
max_speed_ext_time_perc(point) = max_speed_ext_time(point)/length(speed_ext);

onset_thr = 3; %onset threshold, take first three frames of the corresponding phase into account
if onset_thr > length(speed_flex)
onset_speed_flex(point) = mean(speed_flex(1:end),'omitnan'); %speed at reach onset (first 3 frames)
else
onset_speed_flex(point) = mean(speed_flex(1:onset_thr),'omitnan'); 
end
if onset_thr > length(speed_ext)
onset_speed_ext(point) = mean(speed_ext(1:end),'omitnan'); %speed at retraction onset
else
onset_speed_ext(point) = mean(speed_ext(1:onset_thr),'omitnan');
end

%__Reach Distance__ length of a vector from starting point to turning point
x_start = hand_t(pstart,1); y_start = hand_t(pstart,2); %extract start x and y coordinates of starting point and turning point
x_turn = hand_t(tpoint,1); y_turn = hand_t(tpoint,2);
x_distance = abs(x_start-x_turn); y_distance = abs(y_start-y_turn); %calculate x and y values of the distance length
reach_distance(point) = sqrt(x_distance^2 + y_distance^2);
reach_distance(point) = reach_distance(point)*calib_ratio; %calculate to fixed camera zoom

%__Acceleration__ delta speed divided by delta time (one frame), magnitude
delta_acc = (delta_speed(2:end)-delta_speed(1:end-1))/1;
acc_flex = delta_acc(r_pstart:r_peak-1); acc_flex = acc_flex(acc_flex > 0);
acc_ext = delta_acc(r_tpoint:r_trough-1); acc_ext = acc_ext(acc_ext > 0);
if isempty(acc_flex), acc_flex = NaN; end; if isempty(acc_ext), acc_ext = NaN; end

average_acc_total(point) = mean([acc_flex; acc_ext],'omitnan'); %measured only for acceleration TOWARDS the pellet
average_acc_flex(point) = mean(acc_flex,'omitnan'); %due to another delta, indices exhibit a shift to the right
average_acc_ext(point) = mean(acc_ext,'omitnan');

max_acc_total(point) = max([acc_flex; acc_ext]);
max_acc_flex(point) = max(acc_flex);
max_acc_ext(point) = max(acc_ext);

max_acc_total_time(point) = sum([acc_flex; acc_ext] >= floorS(max_acc_total(point),1)); %time for which max acc occurs
max_acc_flex_time(point) = sum(acc_flex >= floorS(max_acc_flex(point),1));
max_acc_ext_time(point) = sum(acc_ext >= floorS(max_acc_ext(point),1));

max_acc_total_time_perc(point) = max_acc_total_time(point)/length([acc_flex; acc_ext]); %percentage during corresponding phase
max_acc_flex_time_perc(point) = max_acc_flex_time(point)/length(acc_flex); 
max_acc_ext_time_perc(point) = max_acc_ext_time(point)/length(acc_ext);

if onset_thr > length(acc_flex)
onset_acc_flex(point) = mean(acc_flex(1:end),'omitnan'); %acc at phase onset (first 3 frames)
else
onset_acc_flex(point) = mean(acc_flex(1:onset_thr),'omitnan'); 
end
if onset_thr > length(acc_ext)
onset_acc_ext(point) = mean(acc_ext(1:end),'omitnan');
else
onset_acc_ext(point) = mean(acc_ext(1:onset_thr),'omitnan');
end

%__Deceleration__ 
dec_flex = delta_acc(r_peak:r_tpoint-1); dec_flex = dec_flex(dec_flex < 0); %take only deceleration values
dec_ext = delta_acc(r_trough:r_tend-1); dec_ext = dec_ext(dec_ext < 0);
if isempty(dec_flex), dec_flex = NaN; end; if isempty(dec_ext), dec_ext = NaN; end

average_dec_total(point) = mean([dec_flex; dec_ext],'omitnan'); %measured only for deceleration TOWARDS the pellet
average_dec_flex(point) = mean(dec_flex,'omitnan');
average_dec_ext(point) = mean(dec_ext,'omitnan');

max_dec_total(point) = min([dec_flex; dec_ext]); %max negative value
max_dec_flex(point) = min(dec_flex);
max_dec_ext(point) = min(dec_ext);

max_dec_total_time(point) = sum(abs([dec_flex; dec_ext]) >= floorS(abs(max_dec_total(point)),1)); %all absolutes of negative values that are bigger than abs. max
max_dec_flex_time(point) = sum(abs(dec_flex) >= floorS(abs(max_dec_flex(point)),1));
max_dec_ext_time(point) = sum(abs(dec_ext) >= floorS(abs(max_dec_ext(point)),1));

max_dec_total_time_perc(point) = max_dec_total_time(point)/length([dec_flex; dec_ext]); %percentage during corresponding phase
max_dec_flex_time_perc(point) = max_dec_flex_time(point)/length(dec_flex); 
max_dec_ext_time_perc(point) = max_dec_ext_time(point)/length(dec_ext);

if onset_thr > length(dec_flex)
onset_dec_flex(point) = mean(dec_flex(1:end),'omitnan'); %dec at phase onset (first 3 frames)
else
onset_dec_flex(point) = mean(dec_flex(1:onset_thr),'omitnan'); 
end
if onset_thr > length(dec_ext)
onset_dec_ext(point) = mean(dec_ext(1:end),'omitnan');
else
onset_dec_ext(point) = mean(dec_ext(1:onset_thr),'omitnan');
end

end

new_kinematic_row = [reach_duration, reach_dur_flex, reach_dur_ext, reach_flex_percent, reach_ext_percent, path_length, reach_distance, ...
average_speed_total, average_speed_flex, average_speed_ext, max_speed_total, max_speed_flex, max_speed_ext, average_acc_total, average_acc_flex, ...
average_acc_ext, max_acc_total, max_acc_flex, max_acc_ext, average_dec_total, average_dec_flex, average_dec_ext, max_dec_total, max_dec_flex, max_dec_ext, ...
max_speed_total_time, max_speed_flex_time, max_speed_ext_time, max_acc_total_time, max_acc_flex_time, max_acc_ext_time, max_dec_total_time, max_dec_flex_time, ...
max_dec_ext_time, max_speed_total_time_perc, max_speed_flex_time_perc, max_speed_ext_time_perc, max_acc_total_time_perc, max_acc_flex_time_perc, ...
max_acc_ext_time_perc, max_dec_total_time_perc, max_dec_flex_time_perc, max_dec_ext_time_perc, onset_speed_flex, onset_speed_ext, onset_acc_flex, ...
onset_acc_ext, onset_dec_flex, onset_dec_ext];

new_kinematic_row(new_kinematic_row == 0) = NaN; %if any of the parameters remained uncalculated because of missing data

%function for flooring with significant values (used in this script)
function rounded_value = floorS(value, round_this_digit) %if round_this_number = 1, we round the first significant value in any number, i.e. 0.00434 -> 0.004 
magnitude = ceil(log10(value)); %find order of magnitude of value
resolution = 10^(magnitude-round_this_digit); %resolution to round to
rounded_value = floor(value/resolution)*resolution;
end

end