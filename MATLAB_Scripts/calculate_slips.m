function slips_events = calculate_slips(hand_d, hand_t, slips_peaksf, slips_peaks, horizontal)

%first try to find start/end of all peaks
dy = diff(hand_d(:,1)); dx = diff(hand_d(:,2)); %get derivatives of hand motion signal
dy_dx = [0; dy./dx];

%remove peaks that are too small
% height_thr = 1; %peak height threshold
% slips_peaksf(slips_peaks < height_thr) = [];
% if isempty(slips_peaksf), slips_events = []; return; end

%Quantify start/end for peaks
%if slips_peaks not empty...
startpoints = zeros(length(slips_peaksf),1); endpoints = zeros(length(slips_peaksf),1);
for peak = 1:length(slips_peaksf)
    
    %NOTE: we are working with a signal that has differing indices and frames, meaning that index does not equal frame number
    spoint = find(hand_d(:,2) < slips_peaksf(peak) & (dy_dx <= 0), 1, 'last'); %find the nearest point left of peak, whose derivative is equal to 0
    
    if isempty(spoint) %if signal begins abruptly without dy/dx = 0
        spoint = 1;
    end

    points_inbetween = find(hand_d(:,2) > hand_d(spoint,2) & hand_d(:,2) < slips_peaksf(peak)); %find points between start and peak
    [alt_point, alt_position] = min(abs(hand_d(points_inbetween,1))); %find point closest to zero
    if alt_point < abs(hand_d(spoint,1)), spoint = points_inbetween(alt_position); end %if the point has a smaller value than current starting point, replace

    startpoints(peak) = spoint;


    epoint = find(hand_d(:,2) > slips_peaksf(peak) & (dy_dx >= 0), 1, 'first') - 1; %find the nearest point right of peak, whose derivative is equal to 0
    
    if isempty(epoint) %if signal ends abruptly without dy/dx = 0
        epoint = length(hand_d(:,2));
    end

    points_inbetween = find(hand_d(:,2) < hand_d(epoint,2) & hand_d(:,2) > slips_peaksf(peak));
    [alt_point, alt_position] = min(abs(hand_d(points_inbetween,1)));
    if alt_point < abs(hand_d(epoint,1)), epoint = points_inbetween(alt_position); end
    
    endpoints(peak) = epoint;    
end

slips_events(:,1) = hand_d(endpoints,2); slips_events(:,2) = hand_t(endpoints,1); slips_events(:,3) = hand_t(endpoints,2);


%filter: minimal points in trajectory filtering
% for event = 1:size(slips_events,1)
% traj_points = length(hand_d(:,2) > hand_d(startpoints(event),2) & hand_d(:,2) < hand_d(endpoints(event),2));
% if traj_points < 10, slips_events(event,:) = NaN; end %3
% end

%filter: minimal vertical distance crossed
% vert_thr = 8; %5
% for event = 1:size(slips_events,1)
% if all(~isnan(slips_events(event,:))) 
% dist_crossed = abs(hand_t(startpoints(event),2)-hand_t(endpoints(event),2));
% if dist_crossed < vert_thr, slips_events(event,:) = NaN; end
% end
% end

%filter: above horizontal line
for event = 1:size(slips_events,1)
if all(~isnan(slips_events(event,:))) %if none of values NaN
if slips_events(event,3) < horizontal(1,2) - 20 %right at the green platform
slips_events(event,:) = NaN;
end
end
end

%remove filtered values
slips_events(any(isnan(slips_events),2),:) = []; %remove all rows with NaN values

end