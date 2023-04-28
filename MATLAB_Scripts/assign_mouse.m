function [cage, hand_side, trial_group, mouse_label, mouse_ID] = assign_mouse(project_table, day, group, subgroup, camera, box)

%converter for different box annotations of software and user
%clockwise: software [1 3 4 2]; user in this case [1 2 3 4]
cage = 0;

if camera == 1
switch box
case 1, cage = 1;
case 2, cage = 4;
case 3, cage = 2;
case 4, cage = 3;
end

elseif camera == 2
switch box
case 1, cage = 2;
case 2, cage = 3;
case 3, cage = 1;
case 4, cage = 4;
end
end

%loop through the excel table
for i=1:size(project_table,1)
if project_table.Day(i) == day && project_table.Group(i) == group && project_table.Subgroup(i) == subgroup && project_table.Cage(i) == cage

%extra: write down which hand is being observed and which trial group
%if grabs_count > 0 %if there are any grabs, their attributes have to be saved
if camera == 1 && (cage == 1 || cage == 4) || camera == 2 && (cage == 2 || cage == 3)
hand_side = 'R';
elseif camera == 1 && (cage == 2 || cage == 3) || camera == 2 && (cage == 1 || cage == 4)
hand_side = 'L';
end
trial_group = project_table.Treatment(i);
mouse_label = project_table.Label(i); 
mouse_ID = project_table.ID(i);
%end

%%%%%%

break; %stop the for loop, our mouse has been found

end %end big if

end %end for

%if the function doesn't find a match, output empty attribute values
%if grabs_count == 0, hand_side = []; trial_group = []; mouse_label = []; end

if ~exist('hand_side','var'), hand_side = ''; end
if ~exist('trial_group','var'), trial_group = ''; end 
if ~exist('mouse_label','var'), mouse_label = NaN; end
if ~exist('mouse_ID','var'), mouse_ID = NaN; end

end