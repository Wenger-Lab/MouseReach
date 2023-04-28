function plot_singles(grabbing_duration, frame_wishlist, diagonal, hand_t, hand_d, hand_dx, hand_dy, ...
reach_events, highest_peaksf, lows_content1, hand_peaksf, hand_peaks, hand_minf, hand_min, longest_grabbing_time)
%PLOT_SINGLE Summary of this function goes here
d_grabs = reach_events;
j=0;

for i = 1:length(frame_wishlist), j=j+1;


%PLOTTING COORDINATES
subplot(length(frame_wishlist),2,j); title(sprintf('Reaching at: %d', frame_wishlist(i))); xlabel('x'); ylabel('y'); hold on; axis ij; 
if exist('diagonal', 'var'), plot(diagonal(:,1), diagonal(:,2),'r'); end

plot(hand_t((hand_t(:,3) >= frame_wishlist(i)-grabbing_duration) & (hand_t(:,3) <= frame_wishlist(i)+grabbing_duration), 1), ... %plot reaching trajectory
    hand_t((hand_t(:,3) >= frame_wishlist(i)-grabbing_duration) & (hand_t(:,3) <= frame_wishlist(i)+grabbing_duration), 2), 'b');

if ~isempty(d_grabs)
d_grabsf_toplot = d_grabs(d_grabs(:,1) >= frame_wishlist(i)-grabbing_duration & d_grabs(:,1) <= frame_wishlist(i)+grabbing_duration, 1);
if ~isempty(d_grabsf_toplot)
[~,d_grabsf_toplot_index] = min(abs(d_grabsf_toplot-frame_wishlist(i))); %find reach closest to input frame
d_grabsf_toplot = d_grabsf_toplot(d_grabsf_toplot_index); %frame of the reach to be plotted

plot(d_grabs(d_grabs(:,1) == d_grabsf_toplot, 2), d_grabs(d_grabs(:,1) == d_grabsf_toplot, 3), 'g.', 'MarkerSize', 20); %plot reaches
end
end

if exist('highest_peaksf', 'var') && exist('lows_content1', 'var') && exist('d_grabsf_toplot', 'var')
if ~isempty(d_grabsf_toplot) %plot positions of the peak and minimum that belong strictly to the reach (highest peak and lowest minimum)
peaksf_toplot = highest_peaksf(highest_peaksf >= d_grabsf_toplot-longest_grabbing_time & highest_peaksf < d_grabsf_toplot);
minf_toplot = lows_content1(lows_content1 > d_grabsf_toplot & lows_content1 <= d_grabsf_toplot+longest_grabbing_time);

plot(hand_t(hand_t(:,3) == peaksf_toplot(end), 1), hand_t(hand_t(:,3) == peaksf_toplot(end), 2), 'r.', 'MarkerSize', 20);
plot(hand_t(hand_t(:,3) == minf_toplot(1), 1), hand_t(hand_t(:,3) == minf_toplot(1), 2), 'b.', 'MarkerSize', 20);
end
end

j=j+1;


%PLOTTING VELOCITY
subplot(length(frame_wishlist),2,j); title(sprintf('Velocity change at: %d', frame_wishlist(i))); xlabel('frames'); ylabel('velocity'); hold on; 

%legend_v = plot(hand_d(hand_d(:,2) >= frame_wishlist(i)-grabbing_duration & hand_d(:,2) <= frame_wishlist(i)+grabbing_duration ,2), ... %plot velocity
%hand_d(hand_d(:,2) >= frame_wishlist(i)-grabbing_duration & hand_d(:,2) <= frame_wishlist(i)+grabbing_duration, 1));

%set axis
axis([min(hand_d(hand_d(:,2) >= frame_wishlist(i)-grabbing_duration,2)) max(hand_d(hand_d(:,2) <= frame_wishlist(i)+grabbing_duration,2)) ...
      min(hand_d(hand_d(:,2) >= frame_wishlist(i)-grabbing_duration,1)) max(hand_d(hand_d(:,2) <= frame_wishlist(i)+grabbing_duration,1))]);

yline(0); %axis manual;

if ~isempty(hand_peaks) && ~isempty(hand_peaksf), plot(hand_peaksf, hand_peaks, 'ro'); hold on; plot(hand_minf, -hand_min, 'bo'); end
if ~isempty(d_grabs), plot(d_grabs(:,2), d_grabs(:,3), 'ko'); end
legend_x = plot(hand_t(2:end,3), hand_dx, 'r');%plot delta x
legend_y = plot(hand_t(2:end,3), hand_dy, 'g'); %plot delta y
legend_v = plot(hand_d(:,2), hand_d(:,1), 'b'); %plot delta v

legend([legend_v legend_x legend_y], 'delta v', 'delta x', 'delta y')
hold off; %plot peaks and lows within axis

end %end plotting


end %end function

