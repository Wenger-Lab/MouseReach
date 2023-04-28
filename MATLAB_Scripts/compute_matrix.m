function [big_merge_matrix,new_reaches_matrix] = compute_matrix(big_merge_matrix, folder, day, group, subgroup, camera, files, file, box, reach_events, pellet_events, slips_events, pellet_coords, hand_side, trial_group, mouse_ID)

t_window = 10; %temporal error window between reach and pell_disp events
s_window = 25; %spatial error window between reach and pell_disp events
new_matrix = []; %placeholder for temporary matrix

% video_loc = strrep(folder, 'Analyzed_csvs/merger/', ''); vname = strcat(files(file).name(1:end-4),'.avi');
% video_loc = VideoReader(char(strcat(video_loc,'/',vname))); %add next video name out of folder
% video = read(video_loc); %update global video

%enlist reach events (categorize all reach events -> reach or grab)
if ~isempty(reach_events)
for r_event=1:size(reach_events,1) %goes through all reaching events and tries to assign them to pellets that disappear

%to determine correct reaching target, correct x for wrist tracking b/c we want to track the position of hand/fingers
if pellet_coords(1,2) > pellet_coords(8,2) %then the mouse is grabbing from the left
reach_events(r_event,2) = reach_events(r_event,2)+10;
elseif pellet_coords(1,2) < pellet_coords(8,2) %then the mouse is grabbing from the right
reach_events(r_event,2) = reach_events(r_event,2)-10;
end

%TEMPORAL match: determine if reach and pellet occur simultaneously; always match up the earliest pellet event
if ~isempty(pellet_events)
match = find(reach_events(r_event,1) > pellet_events(:,1)-t_window & reach_events(r_event,1) < pellet_events(:,1)+t_window,1);
else, match = [];
end

%SPATIAL match: check if the simultaneous occurence is not random
if ~isempty(match) && abs(reach_events(r_event,2)-pellet_events(match,2)) < s_window && abs(reach_events(r_event,3)-pellet_events(match,3)) < s_window
%write grab yes, which pellet
grab_yn = 1; pellet = pellet_events(match,4);
%assign to new big_matrix row (using more precise pellet coordinates)
newrow = {files(file).name(1:end-4), reach_events(r_event,1), pellet_events(match,2), pellet_events(match,3), grab_yn, pellet, NaN, hand_side, box, camera, trial_group, mouse_ID, subgroup, group, day, folder};
%delete this pellet event so it's not reused by other reaches
pellet_events(match,:) = [];

else %no grab, use coordinates of existing pellets to find in which direction did the reach go (if the hand is positioned high above it will still be considered! y+20)
grab_yn = 0; which_pellet = find(abs(reach_events(r_event,2)-pellet_coords(:,2)) < s_window & abs(reach_events(r_event,3)-pellet_coords(:,3)) < s_window+20); 

%if the reach is between two pockets, decide on the one closer to the hand in the x dimension
if length(which_pellet) > 1, pellet_list = []; 
for pellet_12 = 1:length(which_pellet), pellet_list = [pellet_list; which_pellet(pellet_12) abs(reach_events(r_event,2)-pellet_coords(which_pellet(pellet_12),2))]; end
which_pellet = which_pellet(which_pellet == pellet_list(pellet_list(:,2) == min(pellet_list(:,2)),1)); %the smaller of two distances pellet-hand-pellet
end

if isempty(which_pellet), pellet = 0; else, pellet = pellet_coords(which_pellet,1); end

%read global time
% output_image = imadjust(video(:,:,:,reach_events(r_event,1)),[0 0.8],[0 1]);
% global_time = ReadTime(output_image); disp(global_time);

%assign to new big_matrix row (using reach coordinates)
newrow = {files(file).name(1:end-4), reach_events(r_event,1), reach_events(r_event,2), reach_events(r_event,3), grab_yn, pellet, NaN, hand_side, box, camera, trial_group, mouse_ID, subgroup, group, day, folder};

end %end SPATIAL match 

%{'Video','Frame','x','y','Grab','Pellet','Success','Hand','Box','Camera','Trial','Mouse','Subgroup','Group','Day','Folder'}

%create temporary matrix
if isempty(new_matrix)
new_matrix = newrow;
else
new_matrix = [new_matrix; newrow];
end

end 
end %end r_events; all reaching events have been enlisted
new_reaches_matrix = new_matrix;

%enlist remaining pellet events that haven't been assigned to reaches!
if ~isempty(pellet_events) && ~isempty(pellet_events(:,1))
pellet_events = pellet_events(pellet_events(:,1) ~= 0,:); grab_yn = 1; 

for remainder = 1:size(pellet_events,1) %all remaining pellet removal should be classified as tongue(table.Success=2) as there is supposedly no paw movement

if pellet_events(remainder,4) < 3 %mark automatically only pellets 1 and 2 as pellets taken by tongue; otherwise not physically possible
newrow = {files(file).name(1:end-4), pellet_events(remainder,1), pellet_events(remainder,2), pellet_events(remainder,3), grab_yn, pellet_events(remainder,4),...
            2, hand_side, box, camera, trial_group, mouse_ID, subgroup, group, day, folder};
else
newrow = {files(file).name(1:end-4), pellet_events(remainder,1), pellet_events(remainder,2), pellet_events(remainder,3), grab_yn, pellet_events(remainder,4),...
            NaN, hand_side, box, camera, trial_group, mouse_ID, subgroup, group, day, folder};
end

if isempty(new_matrix) %add to temporary matrix
new_matrix = newrow;
else
new_matrix = [new_matrix; newrow];
end

end
end


%enlist slip events into the matrix (HAVE TO EDIT THIS!)
if ~isempty(slips_events)
grab_yn = 2; %slips get table.Grab = 2
for slip = 1:size(slips_events,1)

%find corresponding pellet target (same as above)
which_pellet = find(abs(slips_events(slip,2)-pellet_coords(:,2)) < s_window & abs(slips_events(slip,3)-pellet_coords(:,3)) < s_window+20); 

if length(which_pellet) > 1, pellet_list = []; %if the reach is between two pockets, decide on the one closer to the hand in the x dimension
for pellet_12 = 1:length(which_pellet), pellet_list = [pellet_list; which_pellet(pellet_12) abs(slips_events(slip,2)-pellet_coords(which_pellet(pellet_12),2))]; end
which_pellet = which_pellet(which_pellet == pellet_list(pellet_list(:,2) == min(pellet_list(:,2)),1)); %the smaller of two distances pellet-hand-pellet
end

if isempty(which_pellet), pellet = 0; else, pellet = pellet_coords(which_pellet,1); end

%create newrow
newrow = {files(file).name(1:end-4), slips_events(slip,1), slips_events(slip,2), slips_events(slip,3), grab_yn, pellet,...
            NaN, hand_side, box, camera, trial_group, mouse_ID, subgroup, group, day, folder};

if isempty(new_matrix) %add to temporary matrix
new_matrix = newrow;
else
new_matrix = [new_matrix; newrow];
end

end
end


%fill in the BIG matrix
if ~isempty(new_matrix)
new_matrix = sortrows(new_matrix, 2); %sort new_matrix according to frames

if big_merge_matrix.Day == 0 %if starting, replace first row
big_merge_matrix(1:size(new_matrix,1),1:16) = new_matrix;
else
big_merge_matrix = [big_merge_matrix; new_matrix];

%in case there are more events from several boxes, sort by frames for this specific video
sorting_hat = sortrows(big_merge_matrix(strcmp(big_merge_matrix.Video,files(file).name(1:end-4)) & strcmp(big_merge_matrix.Folder,folder),:),2);
big_merge_matrix(strcmp(big_merge_matrix.Video,files(file).name(1:end-4)) & strcmp(big_merge_matrix.Folder,folder),:) = sorting_hat;

end
end

end %end function

