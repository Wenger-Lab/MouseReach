function [pellet_events, pellet_coords, pellets_disappeared, pellets_appeared, pellets_missing, outliers, sig_pellets] = pellet_signal(shortest_grabbing_time, folder, files, file, box, pellets_disappeared, pellets_appeared, pellets_missing, outliers)

%define pellet file location
pellet_csv = readtable(strcat(folder,'/', files(file).name));


%rearrange table
corner_up_var(:,1) = mean(pellet_csv.x(strcmp(pellet_csv.bodyparts, 'CornerUp') & pellet_csv.likelihood > 0.999 & pellet_csv.box == box));
corner_up_var(:,2) = mean(pellet_csv.y(strcmp(pellet_csv.bodyparts, 'CornerUp') & pellet_csv.likelihood > 0.999 & pellet_csv.box == box));
corner_down_var(:,1) = mean(pellet_csv.x(strcmp(pellet_csv.bodyparts, 'CornerDown') & pellet_csv.likelihood > 0.999 & pellet_csv.box == box));
corner_down_var(:,2) = mean(pellet_csv.y(strcmp(pellet_csv.bodyparts, 'CornerDown') & pellet_csv.likelihood > 0.999 & pellet_csv.box == box));
deleteRows = strcmp(pellet_csv.bodyparts, 'CornerUp') | strcmp(pellet_csv.bodyparts, 'CornerDown'); %delete corner variables
pellet_csv(deleteRows,:) = [];

for pellet = 1:8 %rename pelletN to N
renameRows = strcmp(pellet_csv.bodyparts, strcat('Pellet', num2str(pellet)));
pellet_csv.bodyparts(renameRows) = {pellet};
end

%new table with 3 important variables
pellets = table(pellet_csv.bodyparts(pellet_csv.box == box), pellet_csv.likelihood(pellet_csv.box == box), pellet_csv.frames(pellet_csv.box == box), ...
pellet_csv.x(pellet_csv.box == box), pellet_csv.y(pellet_csv.box == box));
pellets.Properties.VariableNames = {'pellet','likelihood', 'frames', 'x', 'y'};

%find and remove all bodyparts except pellets from the table
idxs = find(strcmp(pellets.pellet,'Hand') | strcmp(pellets.pellet,'GrabbedObj'));
pellets(idxs,:) = []; %#ok<FNDSB>
pellets.pellet = cell2mat(pellets.pellet);

%create signal for each pellet
sig_pellets = zeros(height(pellets(pellets.pellet==1,1)),8);
for pellet=1:8, sig_pellets(:,pellet) = pellets.likelihood(pellets.pellet == pellet); end
sig_pellets(sig_pellets < 0.999) = 0; sig_pellets(sig_pellets >= 0.999) = 1; %create binary signal (everything>threshold is 1, else 0) 0.999

%find spikes in signal to delete (unwanted short variations in probability)
max_width = 10; %10
f_spikewidth = 10; %25
del_pspikes=cell(1,8); del_pspikesf=cell(1,8);
del_nspikes=cell(1,8); del_nspikesf=cell(1,8);

%find positive spikes
for pellet=1:8
try isempty(findpeaks(sig_pellets(:,pellet), 'MinPeakHeight', 0.9, 'MinPeakDistance', 1, 'MaxPeakWidth', max_width)); catch, continue; end %MaxPeakWidth 20
[del_pspikes{pellet}, del_pspikesf{pellet}] = findpeaks(sig_pellets(:,pellet), 'MinPeakHeight', 0.9, 'MinPeakDistance', 1, 'MaxPeakWidth', max_width); %find spikes as peaks
end

%find negative spikes
for pellet=1:8
try isempty(findpeaks(-sig_pellets(:,pellet), 'MinPeakHeight', -0.1, 'MinPeakDistance', 1, 'MaxPeakWidth', max_width)); catch, continue; end
[del_nspikes{pellet}, del_nspikesf{pellet}] = findpeaks(-sig_pellets(:,pellet), 'MinPeakHeight', -0.1, 'MinPeakDistance', 1, 'MaxPeakWidth', max_width);
end

%delete positive spikes
for pellet=1:8
for spike=1:length(del_pspikesf{pellet})
if del_pspikesf{pellet}(spike,:) <= f_spikewidth %check spike position in signal (avoid search out of bounds)
sig_pellets(1:del_pspikesf{pellet}(spike,:)+f_spikewidth, pellet) = 0;
elseif del_pspikesf{pellet}(spike,:)+f_spikewidth >= size(sig_pellets,1)
sig_pellets(del_pspikesf{pellet}(spike,:)-f_spikewidth:end, pellet) = 0;
else
sig_pellets(del_pspikesf{pellet}(spike,:)-f_spikewidth:del_pspikesf{pellet}(spike,:)+f_spikewidth, pellet) = 0; %flatten area left and right of the spike
end
end

end %end for positive spikes

%delete negative spikes
for pellet=1:8
for spike=1:length(del_nspikesf{pellet})
if del_nspikesf{pellet}(spike,:) <= f_spikewidth %check spike position in signal (avoid search out of bounds)
sig_pellets(1:del_nspikesf{pellet}(spike,:)+f_spikewidth, pellet) = 1;
elseif del_nspikesf{pellet}(spike,:)+f_spikewidth >= size(sig_pellets,1)
sig_pellets(del_nspikesf{pellet}(spike,:)-f_spikewidth:end, pellet) = 1;
else
sig_pellets(del_nspikesf{pellet}(spike,:)-f_spikewidth:del_nspikesf{pellet}(spike,:)+f_spikewidth, pellet) = 1; %flatten area left and right of the spike
end
end

end %end for negative spikes

%create delta signal (now spikes equal pellet appearance/disappearance)
dx_pellets = sig_pellets(2:end,:)-sig_pellets(1:end-1,:); %remove all pellet appearances

%find moments when pellets disappeared
pellet_disapp=cell(1,8); pellet_disappf=cell(1,8);
warning('off', 'signal:findpeaks:largeMinPeakHeight');
for pellet=1:8
try isempty(findpeaks(-dx_pellets(:,pellet),'MinPeakHeight', 0.9, 'MinPeakDistance', shortest_grabbing_time)); catch, continue; end
[pellet_disapp{pellet}, pellet_disappf{pellet}] = findpeaks(-dx_pellets(:,pellet),'MinPeakHeight', 0.9, 'MinPeakDistance', shortest_grabbing_time);
end

%find moments when pellets appeared
pellet_app=cell(1,8); pellet_appf=cell(1,8);
warning('off', 'signal:findpeaks:largeMinPeakHeight');
for pellet=1:8
try isempty(findpeaks(dx_pellets(:,pellet),'MinPeakHeight', 0.9, 'MinPeakDistance', shortest_grabbing_time)); catch, continue; end
[pellet_app{pellet}, pellet_appf{pellet}] = findpeaks(dx_pellets(:,pellet),'MinPeakHeight', 0.9, 'MinPeakDistance', shortest_grabbing_time);
end

%record pellet events [frames x y pellet_nr] in the video
pellet_events = []; pellet_coords = zeros(8,3);
for pellet=1:8
if ~isempty(pellet_disappf{pellet})
for multi_events=1:length(pellet_disappf{pellet}) %in case same pellet disappears multiple times
%determine pellet locations
pellet_locs = [mean(pellets.x(pellets.pellet == pellet & pellets.likelihood > 0.999)) mean(pellets.y(pellets.pellet == pellet & pellets.likelihood > 0.999))];
%check if pellet_disappf does not 

%build pellet events
pellet_events = [pellet_events; pellet_disappf{pellet}(multi_events) pellet_locs pellet]; %#ok<AGROW>
end
end
%save general pellet coordinates IF those pellets currently exist in pocket [pellet x y]
pellet_coords(pellet,:) = [pellet mean(pellets.x(pellets.pellet == pellet & pellets.likelihood > 0.999)) mean(pellets.y(pellets.pellet == pellet & pellets.likelihood > 0.999))];
end

%fill in values missing for currently non-existing pellets
if sum(~isnan(pellet_coords(:,2))) < 2 %replacement coordinates from corners if there is only one sugar pellet present

corr_value = 10; %+corr_value because length of pellet pocket is ca. 5 pixels away from corner
if corner_up_var(1) > corner_down_var(1) %determine orientation of box
pellet_coords(1,2) = corner_up_var(1)-corr_value; pellet_coords(1,3) = corner_up_var(2); 
pellet_coords(8,2) = corner_down_var(1)+corr_value; pellet_coords(8,3) = corner_down_var(2);
elseif corner_up_var(1) < corner_down_var(1)
pellet_coords(1,2) = corner_up_var(1)+corr_value; pellet_coords(1,3) = corner_up_var(2);
pellet_coords(8,2) = corner_down_var(1)-corr_value; pellet_coords(8,3) = corner_down_var(2);
end
end

pellet_coords(pellet_coords == 0) = NaN; %if any remaining zeros, turn to NaN
pellet_coords = fillmissing(pellet_coords, 'linear'); %calculate pocket coordinates if more pellets present
 

%calculate missing pellets
for pellet=1:8
pellets_disappeared(box,file) = pellets_disappeared(box,file) + length(pellet_disapp{pellet});
pellets_appeared(box,file) = pellets_appeared(box,file) + length(pellet_app{pellet});
end

pellets_missing(box,file) = pellets_disappeared(box,file)- pellets_appeared(box,file);
if pellets_missing(box,file) < 0, pellets_missing(box,file) = 0; end %pellets cannot miss in negative

%remove outliers (optional, if dataset has a lot of errors, i.e. experimenter hands in videos...)
if pellets_disappeared(box,file) > 2 && height(pellets(pellets.pellet==1,1)) <= 300 || ... %equals app. 15 seconds
pellets_disappeared(box,file) > 3 && height(pellets(pellets.pellet==1,1)) <= 400 || ...
pellets_disappeared(box,file) > 4 && height(pellets(pellets.pellet==1,1)) <= 500 || ...
pellets_disappeared(box,file) > 5 && height(pellets(pellets.pellet==1,1)) <= 600 || ...
pellets_disappeared(box,file) > 6 && height(pellets(pellets.pellet==1,1)) <= 700 || ...
pellets_disappeared(box,file) > 7 && height(pellets(pellets.pellet==1,1)) <= 800
outliers = [outliers; folder, '/', files(file).name, ' Too many pellets disappeared: ', num2str(pellets_disappeared(box, file)), ' in box ', num2str(box)];
pellets_disappeared(box,file) = 0; pellets_appeared(box,file) = 0; pellets_missing(box,file) = 0; %do not count this file
pellet_events = []; %empty pellet events if outlier
%disp(outliers)
end

if pellets_appeared(box,file) > 2 && height(pellets(pellets.pellet==1,1)) <= 300 || ... %equals app. 15 seconds
pellets_appeared(box,file) > 3 && height(pellets(pellets.pellet==1,1)) <= 400 || ...
pellets_appeared(box,file) > 4 && height(pellets(pellets.pellet==1,1)) <= 500 || ...
pellets_appeared(box,file) > 5 && height(pellets(pellets.pellet==1,1)) <= 600 || ...
pellets_appeared(box,file) > 6 && height(pellets(pellets.pellet==1,1)) <= 700 || ...
pellets_appeared(box,file) > 7 && height(pellets(pellets.pellet==1,1)) <= 800
outliers = [outliers; folder, '/', files(file).name, ' Too many pellets appeared: ', num2str(pellets_missing(box, file)), ' in box ', num2str(box)];
pellets_disappeared(box,file) = 0; pellets_appeared(box,file) = 0; pellets_missing(box,file) = 0; %do not count this file
pellet_events = [];
%disp(outliers)
end

end %end function

