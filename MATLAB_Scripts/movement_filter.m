function [hand_peaks, hand_peaksf, hand_min, hand_minf, slips_peaks, slips_peaksf, slips_min, slips_minf] = movement_filter(hand_t, hand_peaks, hand_peaksf, hand_min, hand_minf, slips_peaks, slips_peaksf, slips_min, slips_minf, average_grabbing_time, hand_dx, hand_dy)
%MOVEMENT_FILTER Summary of this function goes here

%%%%%%%%%%%%%MOVEMENT PATTERN FILTER
for i=1:length(hand_peaksf) %check each peak
    idx_diff_1 = find(hand_t(:,3) == hand_peaksf(i))-average_grabbing_time/2; if idx_diff_1 < 1, idx_diff_1 = find(hand_t(:,3) == hand_t(1,3)); end %check for beginning or end of trajectory
    idx_diff_2 = find(hand_t(:,3) == hand_peaksf(i))+average_grabbing_time/2; if idx_diff_2 > length(hand_t(:,3))-1, idx_diff_2 = find(hand_t(:,3) == hand_t(end,3)-1); end %-1 because delta has -1 indices
    hand_dx_diff = hand_dx(idx_diff_1:idx_diff_2); %idx_diff_1 & 2 are locations where the peak should start and finish
    hand_dy_diff = hand_dy(idx_diff_1:idx_diff_2);

    if mean(abs(hand_dy_diff)) > 1.5*mean(abs(hand_dx_diff)) %if the average y is greater than average x, it is a slip
    slips_peaks = [slips_peaks hand_peaks(i)]; slips_peaksf = [slips_peaksf hand_peaksf(i)]; %add to slip values
    hand_peaks(i) = 0; hand_peaksf(i) = 0; %delete among reaching peaks
    end 
end

for i=1:length(hand_minf) %check each minimum
    idx_diff_1 = find(hand_t(:,3) == hand_minf(i))-average_grabbing_time/2; if idx_diff_1 < 1, idx_diff_1 = find(hand_t(:,3) == hand_t(1,3)); end %check for beginning or end of trajectory
    idx_diff_2 = find(hand_t(:,3) == hand_minf(i))+average_grabbing_time/2; if idx_diff_2 > length(hand_t(:,3))-1, idx_diff_2 = find(hand_t(:,3) == hand_t(end,3)-1); end %-1 because delta has -1 indices
    hand_dx_diff = hand_dx(idx_diff_1:idx_diff_2); %locations where each minimum should start and end
    hand_dy_diff = hand_dy(idx_diff_1:idx_diff_2);

    if mean(abs(hand_dy_diff)) > 1.5*mean(abs(hand_dx_diff)) %reverse because negative peak
    slips_min = [slips_min hand_min(i)]; slips_minf = [slips_minf hand_minf(i)];
    hand_min(i) = 0; hand_minf(i) = 0;
    end 
end

%remove all slip values from reaching peaks/minima
hand_peaks = hand_peaks(hand_peaks ~= 0); hand_peaksf = hand_peaksf(hand_peaksf ~= 0); hand_min = hand_min(hand_min ~= 0); hand_minf = hand_minf(hand_minf ~= 0);

%%%%%%%%%%%%%MOVEMENT PATTERN FILTER



end

