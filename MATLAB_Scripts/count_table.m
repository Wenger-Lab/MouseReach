function [total_grabs_count_r_c, total_grabs_count_l_c, total_grabs_count_r_e, total_grabs_count_l_e, total_pellets_count_r_c, total_pellets_count_l_c, total_pellets_count_r_e, total_pellets_count_l_e] = ...
count_table(grabs_count, day, trial_group, hand_side, mouse_ID, box, file, pellets_missing, total_grabs_count_r_c, total_grabs_count_l_c, total_grabs_count_r_e, total_grabs_count_l_e, total_pellets_count_r_c, total_pellets_count_l_c, total_pellets_count_r_e, total_pellets_count_l_e)

if strcmp(hand_side,'R')
switch trial_group
case 1
total_grabs_count_r_e(mouse_ID,day) = total_grabs_count_r_e(mouse_ID,day) + grabs_count;
total_pellets_count_r_e(mouse_ID,day) = total_pellets_count_r_e(mouse_ID,day) + pellets_missing(box,file);   
case 0
total_grabs_count_r_c(mouse_ID,day) = total_grabs_count_r_c(mouse_ID,day) + grabs_count;
total_pellets_count_r_c(mouse_ID,day) = total_pellets_count_r_c(mouse_ID,day) + pellets_missing(box,file);
end

elseif strcmp(hand_side,'L')
switch trial_group
case 1
total_grabs_count_l_e(mouse_ID,day) = total_grabs_count_l_e(mouse_ID,day) + grabs_count;
total_pellets_count_l_e(mouse_ID,day) = total_pellets_count_l_e(mouse_ID,day) + pellets_missing(box,file);     
case 0
total_grabs_count_l_c(mouse_ID,day) = total_grabs_count_l_c(mouse_ID,day) + grabs_count;
total_pellets_count_l_c(mouse_ID,day) = total_pellets_count_l_c(mouse_ID,day) + pellets_missing(box,file);
end
end

end %function

