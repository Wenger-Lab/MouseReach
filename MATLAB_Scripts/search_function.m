function [turning_points, turning_peaks, turning_min, grabs_count, highest_peaks, highest_peaksf, lows_content1] = search_function(hand_peaks, hand_peaksf, hand_min, hand_minf, hand_d, hand_t, longest_grabbing_time)
%SEARCH_FUNCTION Summary of this function goes here


%%%%%%%%%%%%%MAIN SEARCH FUNCTION
%preallocate peaks and minima
j=0; turning_points = zeros(max(length(hand_peaks), length(hand_min)),1); lows_content1 = zeros(length(hand_peaks),1);
highest_peaks = zeros(length(hand_peaks),1); highest_peaksf = zeros(length(hand_peaksf),1); idx_delta_peaks = zeros(max(length(hand_peaks), length(hand_min)),1);
idx_deltamov_lows1 = zeros(max(length(hand_peaks), length(hand_min)),1); turning_index = zeros(1,1);
turning_peaks = zeros(max(length(hand_peaks), length(hand_min)),1); turning_min = zeros(max(length(hand_peaks), length(hand_min)),1);

%search upfront for min_analyze_dist
for i=1:length(hand_peaksf)

    if ~isempty(hand_minf(hand_minf > hand_peaksf(i) & hand_minf <= hand_peaksf(i)+longest_grabbing_time))
        content_plholder1 = hand_minf(hand_minf > hand_peaksf(i) & hand_minf <= hand_peaksf(i)+longest_grabbing_time); %find nearest minimum

        %PEAK ABSORPTION
        peaks_inbetween = hand_peaksf(hand_peaksf >= hand_peaksf(i) & hand_peaksf < content_plholder1(1)); %are there more peaks before the minimum?
        highest_peaksf_index = zeros(1,1); for idx = 1:length(peaks_inbetween), highest_peaksf_index(idx) = find(hand_peaksf == peaks_inbetween(idx)); end
        highest_peaksf(i) = hand_peaksf(hand_peaks == max(hand_peaks(highest_peaksf_index)));
        highest_peaks(i) = hand_peaks(hand_peaks == max(hand_peaks(highest_peaksf_index))); %the highest of all peaks
        content_plholder1 = hand_minf(hand_minf > highest_peaksf(i) & hand_minf <= highest_peaksf(i)+longest_grabbing_time); %update content_plholder1

        %MINIMUM ABSORPTION
        %disp('cnt plcholder:'); disp(content_plholder1(1));
        upper_boundary_lc = hand_peaksf(hand_peaksf > content_plholder1(1)); %all peaks after minimum
        if ~isempty(upper_boundary_lc) %choose the highest of several minima but with consideration to next peaks
        available_minima = content_plholder1(content_plholder1 < upper_boundary_lc(1)); %watch matrix dimensions here
        available_minima_index = zeros(1,1); for idx = 1:length(available_minima), available_minima_index(idx) = find(hand_minf == available_minima(idx)); end
        lows_content1(i) = hand_minf(hand_min == max(hand_min(available_minima_index)));
       
        else %if no peaks ahead, choose the highest of inventory minima
        available_minima = content_plholder1; %watch matrix dimensions here because of find function
        available_minima_index = zeros(1,1); for idx = 1:length(available_minima), available_minima_index(idx) = find(hand_minf == available_minima(idx)); end
        lows_content1(i) = hand_minf(hand_min == max(hand_min(available_minima_index))); 
        end, j=j+1; 

        %by this point, we have the highest peak and highest minimum

        %further peak search: find values spanning the distance
        idx_delta_peaks(i) = find(hand_d(:,2) == highest_peaksf(i)); idx_deltamov_lows1(i) = find(hand_d(:,2) == lows_content1(i));
        deltamov_range1 = [hand_d(idx_delta_peaks(i):idx_deltamov_lows1(i),1) hand_d(idx_delta_peaks(i):idx_deltamov_lows1(i),2)]; %velocity values; frames
        deltamov_range2 = [hand_t(idx_delta_peaks(i):idx_deltamov_lows1(i),2) hand_t(idx_delta_peaks(i):idx_deltamov_lows1(i),3)]; %y values; frames
        %disp('i: '); disp(i); fprintf('highest_peaksf is: %d\n', highest_peaksf); fprintf('lowscontent1 is: %d\n', lows_content1); disp('idx_delta_peaks: '); disp(idx_delta_peaks(i)); disp('idx_deltamov_lows1: '); disp(idx_deltamov_lows1(i)); disp('deltamov_range: '); disp(deltamov_range1); 
        
        %PAIRING FUNCTION
        if j==1 %if first step
            %[~, turning_index(i)] = min(abs(deltamov_range1(:,1))); %find index of closest velocity to turning point = 0; old
            [~, t1] = min(abs(deltamov_range1(:,1))); [~, t2] = max(deltamov_range2(:,1)); %t2 is an alternative timepoint
            if t1 < t2, turning_index(i) = t1; else, turning_index(i) = t2; end %check whether velocity drop or y minimum occurs sooner
            turning_points(j,1) = deltamov_range1(turning_index(i),1); %find velocity at the corresponding index
            if isnan(turning_points(j,1)), turning_points(j,1) = deltamov_range1(t1,1); end %if hand_d unavailable at t2, pick hand_d at t1
            turning_points(j,2) = deltamov_range1(turning_index(i),2); %find timeframe of turning point
            turning_peaks(j,1) = highest_peaks(i); turning_peaks(j,2) = highest_peaksf(i);
            turning_min(j,1) = hand_min(hand_minf == lows_content1(i)); turning_min(j,2) = lows_content1(i);
            
        elseif j>1 && (highest_peaksf(i) < lows_content1(i-1)) %if we are still considering the same row of peak(s), we're just gonna take one
%             if lows_content1(i) > lows_content1(i-1) %in case if a new, bigger minimum has been found
%             [~, turning_index(i)] = min(abs(deltamov_range1(:,1)));
%             turning_points(j,1) = deltamov_range1(turning_index(i),1);
%             turning_points(j,2) = deltamov_range1(turning_index(i),2);
%             turning_peaks(j,1) = highest_peaks(i); turning_peaks(j,2) = highest_peaksf(i);
%             turning_min(j,1) = hand_min(hand_minf == lows_content1(i)); turning_min(j,2) = lows_content1(i);
%             
%             turning_points(j-1,1) = 0; turning_points(j-1,2) = 0; %delete previous values
%             turning_peaks(j-1,1) = 0; turning_peaks(j-1,2) = 0;
%             turning_min(j-1,1) = 0; turning_min(j-1,2) = 0;
%             
%             else %if old minimum bigger or same, disregard the new one
            turning_points(j,1) = 0; turning_points(j,2) = 0; turning_peaks(j,1) = 0; turning_peaks(j,2) = 0; turning_min(j,1) = 0; turning_min(j,2) = 0;
%            end

        elseif j>1 %NORMAL PAIRING
            %[~, turning_index(i)] = min(abs(deltamov_range1(:,1))); 
            [~, t1] = min(abs(deltamov_range1(:,1))); [~, t2] = max(deltamov_range2(:,1)); 
            if t1 < t2, turning_index(i) = t1; else, turning_index(i) = t2; end 
            turning_points(j,1) = deltamov_range1(turning_index(i),1);
            if isnan(turning_points(j,1)), turning_points(j,1) = deltamov_range1(t1,1); end 
            turning_points(j,2) = deltamov_range1(turning_index(i),2);
            turning_peaks(j,1) = highest_peaks(i); turning_peaks(j,2) = highest_peaksf(i);
            turning_min(j,1) = hand_min(hand_minf == lows_content1(i)); turning_min(j,2) = lows_content1(i);

        end
    end
end

%clean turning_points
if ~any(turning_points, 'all'), grabs_count = 0; return; end %return
turning_points = [turning_points(turning_points(:,2) ~= 0, 1) turning_points(turning_points(:,2) ~= 0, 2)]; %clean of zeros and output integers
turning_peaks = [turning_peaks(turning_peaks(:,2) ~= 0, 1) turning_peaks(turning_peaks(:,2) ~= 0, 2)];
turning_min = [turning_min(turning_min(:,2) ~= 0, 1) turning_min(turning_min(:,2) ~= 0, 2)];

%find corresponding x & y [velocity frames x y]
for i=1:length(turning_points(:,1)), turning_points(i,3) = hand_t(hand_t(:,3) == turning_points(i,2),1); end %corresponding x
for i=1:length(turning_points(:,1)), turning_points(i,4) = hand_t(hand_t(:,3) == turning_points(i,2),2); end %corresponding y

grabs_count = []; %move on to next checkpoint

%update? consider replacing 0 as a marker with NaN (i.e. line 83)

end

