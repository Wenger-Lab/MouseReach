function all_points = reach_parameters(hand_d, turning_peaks, turning_points, turning_min)

%find start and end of a reach

%variables: hand_peaks, hand_peaksf, hand_min, hand_minf
%these have not been filtered to belong to particular reaches

%or variables: turning_peaks, turning_min (frame included)
%they have been filtered to belong to specific reaches

%signal is plotted from hand_d(sum, frames)

%first try to find start/end of all peaks
dy = diff(hand_d(:,1)); dx = diff(hand_d(:,2)); %get derivatives
dy_dx = [0; dy./dx];
all_points = zeros(size(turning_points,1),7);

% __1__ Quantify start/end for peaks
%if turning_peaks not empty...
startpoints = zeros(size(turning_peaks,1),1); endpoints = zeros(size(turning_peaks,1),1);
for peak = 1:size(turning_peaks,1)
    
    %NOTE: we are working with a signal that has differing indices and frames, meaning that index does not equal frame number
    spoint = find((hand_d(:,2) < turning_peaks(peak,2)) & (dy_dx <= 0), 1, 'last'); %find the nearest point left of peak, whose derivative is equal to 0
    
    if isempty(spoint) %if signal begins abruptly without dy/dx = 0
        spoint = 1;
    end

    points_inbetween = find(hand_d(:,2) > hand_d(spoint,2) & hand_d(:,2) < turning_peaks(peak,2)); %find points between start and peak
    [alt_point, alt_position] = min(abs(hand_d(points_inbetween,1))); %find point closest to zero
    if alt_point < abs(hand_d(spoint,1)), spoint = points_inbetween(alt_position); end %if the point has a smaller value than current starting point, replace

    startpoints(peak) = spoint;


    epoint = find((hand_d(:,2) > turning_peaks(peak,2)) & (dy_dx >= 0), 1, 'first') - 1; %find the nearest point right of peak, whose derivative is equal to 0
    
    if isempty(epoint) %if signal ends abruptly without dy/dx = 0
        epoint = length(hand_d(:,2));
    end

    points_inbetween = find(hand_d(:,2) < hand_d(epoint,2) & hand_d(:,2) > turning_peaks(peak,2));
    [alt_point, alt_position] = min(abs(hand_d(points_inbetween,1)));
    if alt_point < abs(hand_d(epoint,1)), epoint = points_inbetween(alt_position); end
    
    endpoints(peak) = epoint;
    
end
all_points(:,1) = startpoints; all_points(:,3) = endpoints; %assign peak start/end to the main variable

%__2__ Quantify start/end for troughs
startpoints = zeros(size(turning_min,1),1); endpoints = zeros(size(turning_min,1),1); %reset
for trough = 1:size(turning_min,1)
    
    spoint = find((hand_d(:,2) < turning_min(trough,2)) & (dy_dx >= 0), 1, 'last');
    
    if isempty(spoint) 
        spoint = 1;
    end

    points_inbetween = find(hand_d(:,2) > hand_d(spoint,2) & hand_d(:,2) < turning_min(trough,2)); 
    [alt_point, alt_position] = min(abs(hand_d(points_inbetween,1)));
    if alt_point < abs(hand_d(spoint,1)), spoint = points_inbetween(alt_position); end 

    startpoints(trough) = spoint;


    epoint = find((hand_d(:,2) > turning_min(trough,2)) & (dy_dx <= 0), 1, 'first') - 1; 
    
    if isempty(epoint) 
        epoint = length(hand_d(:,2));
    end

    points_inbetween = find(hand_d(:,2) < hand_d(epoint,2) & hand_d(:,2) > turning_min(trough,2));
    [alt_point, alt_position] = min(abs(hand_d(points_inbetween,1)));
    if alt_point < abs(hand_d(epoint,1)), epoint = points_inbetween(alt_position); end
    
    endpoints(trough) = epoint;

end
all_points(:,5) = startpoints; all_points(:,7) = endpoints; %assign trough start/end to main variable

%__3__Quantify peaks, turning points and troughs
for turnpoint = 1:length(turning_points(:,2))
all_points(turnpoint,2) = find(hand_d(:,2) == turning_peaks(turnpoint,2),1);
all_points(turnpoint,4) = find(hand_d(:,2) == turning_points(turnpoint,2),1);
all_points(turnpoint,6) = find(hand_d(:,2) == turning_min(turnpoint,2),1);
end

%all_points = [speak peak epeak turnpoint strough trough etrough]
%contains indices (positions) and NOT frames in the signal matrix !!!!


%plot check
% hold on; plot(hand_d(:,2), hand_d(:,1)); yline(0)
% plot(hand_d(all_points(:,1),2), hand_d(all_points(:,1),1),'og') %peak startpoints
% plot(hand_d(all_points(:,3),2), hand_d(all_points(:,3),1),'or') %peak endpoints
% plot(hand_d(all_points(:,2),2), hand_d(all_points(:,2),1),'.k','MarkerSize',15); %peaks
% plot(hand_d(all_points(:,5),2), hand_d(all_points(:,5),1),'sg') %trough startpoints
% plot(hand_d(all_points(:,7),2), hand_d(all_points(:,7),1),'sr') %trough endpoints
% plot(hand_d(all_points(:,6),2), hand_d(all_points(:,6),1),'.m','MarkerSize',15) %troughs
% 
% plot(turning_points(:,2), turning_points(:,1),'ok') %these can be plotted if turning_peaks match turning_points


end