function plot_box(grabbing_duration, turning_points, d_grabs, hand_t, diagonal, thr_line)
%REACHES_BOX Summary of this function goes here

%PLOT ALL REACHES IN ONE BOX
hold on;
for i=1:size(turning_points,1), plot(hand_t(hand_t(:,3) >= turning_points(i,2)-grabbing_duration & hand_t(:,3) <= turning_points(i,2)+grabbing_duration, 1), ...
hand_t(hand_t(:,3) >= turning_points(i,2)-grabbing_duration & hand_t(:,3) <= turning_points(i,2)+grabbing_duration, 2),'LineWidth',3); end

plot(turning_points(:,3), turning_points(:,4), 'Marker', 'x', 'MarkerSize', 20, 'LineStyle', 'None', 'Color', 'k'); axis ij; 
%plot(diagonal(:,1), diagonal(:,2), 'b-'); plot(thr_line(:,1), thr_line(:,2),'r--');
disp(length(d_grabs(:,1)));



end %end function

