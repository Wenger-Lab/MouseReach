function total_grabbed_time = time_grabbed(csv,box,day,mouse_ID,hand_side,file,sig_pellets,pellet_coords,reach_events,pellet_events,total_grabbed_time)

%polish GrabbedObj signal
object_signal = movmean(csv.likelihood(strcmp(csv.bodyparts,'GrabbedObj') & csv.box == box),3); 
object_signal(object_signal < 0.99) = 0; object_signal(object_signal >= 0.99) = 1;  

%find unwanted spikes in signal with small width
max_width = 9; %little less than minimal grabbing time
[~, delete_spikesf] = findpeaks(object_signal, 'MinPeakHeight', 0.9, 'MinPeakDistance', 1, 'MaxPeakWidth', max_width);

for spike=1:length(delete_spikesf) %remove them unwanted spikes
if delete_spikesf(spike)+max_width >= size(object_signal,1)
object_signal(delete_spikesf(spike):end) = 0;
else
object_signal(delete_spikesf(spike):delete_spikesf(spike)+max_width) = 0; %flatten area right of the spike
end
end

%find smaller gaps in peaks
gap_width = 20;
[~, gapsf] = findpeaks(-object_signal, 'MinPeakHeight', -0.1, 'MinPeakDistance', 1, 'MaxPeakWidth', gap_width);
for gap=1:length(gapsf)
[gap_end, ~] = find(object_signal(gapsf(gap):end) == 1, 1, 'first'); %find gap end
if gap_end <= gap_width && gapsf(gap)+gap_end < length(object_signal), object_signal(gapsf(gap):gapsf(gap)+gap_end) = 1; end %close gap in the peak
end

%find binary peak start and peak end
min_dist = 9; %minimal peak distance
if length(object_signal) > 2*min_dist %otherwise findpeaks doesn't work

[~, peak_start] = findpeaks(object_signal, 'MinPeakHeight', 0.9, 'MinPeakDistance', min_dist); peak_end = zeros(length(peak_start),1);
for peak=1:length(peak_start)
[idx, ~] = find(object_signal(peak_start(peak):end) == 0, 1, 'first'); %ending frame of the peak
if ~isempty(idx), peak_end(peak) = peak_start(peak) + (idx - 2); else, peak_end(peak) = length(object_signal); end
end

else
peak_start = []; peak_end = []; %if signal short, peaks are empty
end

%match pellet existence and GrabbedObj events (specificity to two nearby pellets)
for event = 1:length(peak_start)
temporal_dist = 20; %allowed time difference between pellet existence and GrabbedObj event (empirical) %15
spatial_dist = 30; %allowed distance from GrabbedObj to the target pellet well
x_pos = csv.x(strcmp(csv.bodyparts,'GrabbedObj') & csv.box == box & csv.frames == peak_start(event)); %find position of GrabbedObj
dist_grab_well = abs(pellet_coords(:,2)-x_pos); dist_altered = dist_grab_well; [~,idx1_x] = min(dist_altered);
dist_altered(idx1_x) = 1000; [~,idx2_x] = min(dist_altered); clear dist_altered %find first two minima

if peak_start(event) <= temporal_dist, temp_dist = peak_start(event)-1; else, temp_dist = temporal_dist; end %in case peak_start is close to video start

if dist_grab_well(idx1_x) < spatial_dist
pellet_n1 = pellet_coords(idx1_x,1); %find two corresponding pellets (first choice)
n1_presence = sum(sig_pellets(peak_start(event)-temp_dist:peak_start(event),pellet_n1));
if pellet_n1 < 5 && ~isempty(pellet_events) %additional sanity check with pellet_events for first 4 pellets (less piling up of pellets here)
[proximity1,~] = find(pellet_events(pellet_events(:,4) == pellet_n1,1) > peak_start(event)-temp_dist & pellet_events(pellet_events(:,4) == pellet_n1,1) < peak_start(event)+temp_dist);
if isempty(proximity1), n1_presence = 0; end %if no pellet_events occuring at that time
elseif pellet_n1 < 5 && isempty(pellet_events), n1_presence = 0;
end %end pellet_events check
else, n1_presence = 0;
end

if dist_grab_well(idx2_x) < spatial_dist
pellet_n2 = pellet_coords(idx2_x,1); %find two corresponding pellets (second choice)
n2_presence = sum(sig_pellets(peak_start(event)-temp_dist:peak_start(event),pellet_n2));
if pellet_n2 < 5 && ~isempty(pellet_events) %additional check if first N pellets
[proximity2,~] = find(pellet_events(pellet_events(:,4) == pellet_n2,1) > peak_start(event)-temp_dist & pellet_events(pellet_events(:,4) == pellet_n2,1) < peak_start(event)+temp_dist);
if isempty(proximity2), n2_presence = 0; end
elseif pellet_n2 < 5 && isempty(pellet_events), n2_presence = 0;
end %end pellet_events check
else, n2_presence = 0;
end

if n1_presence<=1 && n2_presence<=1 %if pellet is present in only one or no frames
peak_start(event) = NaN; peak_end(event) = NaN; %remove event
end
end
peak_start = peak_start(~isnan(peak_start)); peak_end = peak_end(~isnan(peak_end));


%match pellet_events and GrabbedObj events (doesn't work because of pellet on pellet)
% if isempty(pellet_events), peak_start = []; peak_end = []; end
% 
% temp_dist = 15; %distance between pellet disappearing and grabbed object being detected (empirical)
% for event = 1:length(peak_start)
% [proximity1,~] = find(pellet_events(:,1) > peak_start(event)-temp_dist & pellet_events(:,1) < peak_start(event)+temp_dist);
% if isempty(proximity1), peak_start(event) = NaN; peak_end(event) = NaN; end %if no match, delete peak_start (could be a closed hand without pellet)
% end
% peak_start = peak_start(~isnan(peak_start)); peak_end = peak_end(~isnan(peak_end));

grabbed_frames = mean(peak_end-peak_start); %average duration of each peak

%match reach_events and filtered GrabbedObj events (no empty hands)
if isempty(reach_events), return; end

% attempts_wpellet = 0;
% for event = 1:length(peak_start)
% [proximity2,~] = find(reach_events(:,1) > peak_start(event) & reach_events(:,1) < peak_end(event)); %CHANGE according to metam
% attempts_wpellet = attempts_wpellet + length(proximity2);
% end

%summarize
if ~isempty(grabbed_frames) && ~isempty(peak_start) && ~isnan(grabbed_frames)
total_grabbed_time = [total_grabbed_time; {day, mouse_ID, hand_side, file, length(peak_start), grabbed_frames}]; %size(pellet_events,1)
end


end %function