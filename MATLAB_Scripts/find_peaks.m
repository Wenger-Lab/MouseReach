function [hand_peaks, hand_peaksf, hand_min, hand_minf, slips_peaks, slips_peaksf, slips_min, slips_minf, grabs_count] = find_peaks(hand_d, shortest_grabbing_time)
%FIND_PEAKS Summary of this function goes here

min_pk_height = 1.5;
min_low_height = 1.5;
min_pk_dist = shortest_grabbing_time;
min_peak_width = 3;

%preallocate slips variables for later on
slips_peaks = []; slips_peaksf = []; slips_min = []; slips_minf = []; %these will be calculated separately later on

%REACH PEAKS/MINS: check for empty dataset/no peaks
if isempty(hand_d), grabs_count = 0; hand_peaks = []; hand_peaksf = 0; hand_min = []; hand_minf = []; return; end %if any variable empty, return empty values and 0 grabs
warning('off', 'signal:findpeaks:largeMinPeakHeight'); %turn off warning for findpeaks = []

try isempty(findpeaks(hand_d(:,1), hand_d(:,2),'MinPeakHeight', min_pk_height, 'MinPeakDistance', min_pk_dist, 'MinPeakWidth', min_peak_width)); catch, ...
grabs_count = 0;  hand_peaks = []; hand_peaksf = 0; hand_min = []; hand_minf = []; return; end %error return

if isempty(findpeaks(hand_d(:,1), hand_d(:,2),'MinPeakHeight', min_pk_height, 'MinPeakDistance', min_pk_dist, 'MinPeakWidth', min_peak_width)),...
grabs_count = 0;  hand_peaks = []; hand_peaksf = 0; hand_min = []; hand_minf = []; return; end %warning return

%find local maxima & minima & corresponding frames
[hand_peaks, hand_peaksf] = findpeaks(hand_d(:,1), hand_d(:,2),'MinPeakHeight', min_pk_height, 'MinPeakDistance', min_pk_dist, 'MinPeakWidth', min_peak_width);
[hand_min, hand_minf] = findpeaks(-hand_d(:,1), hand_d(:,2),'MinPeakHeight', min_low_height, 'MinPeakDistance', min_pk_dist, 'MinPeakWidth', min_peak_width); %find peaks and lows
grabs_count = []; %assign empty grabs_count to proceed forward

%PREVENTION OF START/END NAN VALUES
%add peak/minimum to the beginning of trajectory
if hand_d(1,1) > min_pk_height, hand_peaks = [hand_d(1,1); hand_peaks]; hand_peaksf = [hand_d(1,2); hand_peaksf]; %%#ok<AGROW>
elseif -hand_d(1,1) > min_pk_height, hand_min = [hand_d(1,1); hand_min]; hand_minf = [hand_d(1,2); hand_minf]; end %%#ok<AGROW>

%add peak/minimum to the end of trajectory
if hand_d(end,1) > min_pk_height, hand_peaks = [hand_peaks; hand_d(end,1)]; hand_peaksf = [hand_peaksf; hand_d(end,2)]; %%#ok<AGROW>
elseif -hand_d(end,1) > min_pk_height, hand_min = [hand_min; -hand_d(end,1)]; hand_minf = [hand_minf; hand_d(end,2)]; end %%#ok<AGROW>

end %end function

