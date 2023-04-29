%function [reach_table] = compute_averages(huge_merge_matrix)
clear

%answer = input('App evaluation done? (yes/no)\n','s'); %move to main script
%[file, path] = uigetfile('*.m','Please select the edited big table!','MultiSelect','off'); big_table_PT = readtable(path);
huge_merge_matrix = readtable('/home/user/project/huge_merge_matrix.xlsx'); 

%merging edited big_merge_matrix and huge_merge_matrix
big_table_PT = readtable('(home/user/project/big_merge_matrix.xlsx'); %big_merge_matrix after post-processing via MouseReach App

[found, where] = ismember(huge_merge_matrix(:,1:4),big_table_PT(:,1:4)); %update grab & success from app
huge_merge_matrix.Success(found) = big_table_PT.Success(where(found));
huge_merge_matrix.Grab(found) = big_table_PT.Grab(where(found));

new_entries = big_table_PT(~ismember(big_table_PT(:,1:4),huge_merge_matrix(:,1:4)),:); %additional entries from the app
size_new_entries = size(new_entries,1); size_hmm = size(huge_merge_matrix,1);
huge_merge_matrix.Success(size_hmm+1:size_hmm+size_new_entries) = NaN; %add new entries
huge_merge_matrix(size_hmm+1:size_hmm+size_new_entries,1:16) = new_entries;
huge_merge_matrix(size_hmm+1:size_hmm+size_new_entries,17:end) = table(NaN); %set kinematic parameters to NaN for those entries

huge_merge_matrix(isnan(huge_merge_matrix.Grab),:) = []; %remove false reaching events marked with the app
huge_merge_matrix = sortrows(huge_merge_matrix,{'Day','Group','Subgroup','Camera','Video','Box','Frame'});

%clean and modify huge_merge_matrix, extract tables for analysis
huge_merge_matrix_wo_strings = huge_merge_matrix;
huge_merge_matrix_wo_strings.Video = []; huge_merge_matrix_wo_strings.Folder = [];
huge_merge_matrix_wo_strings = huge_merge_matrix_wo_strings(huge_merge_matrix_wo_strings.Trial == 1,:);
huge_merge_matrix_wo_strings(huge_merge_matrix_wo_strings.Success == 2,:) = []; %exclude tongue

days_list = unique(huge_merge_matrix_wo_strings.Day); mouse_list = unique(huge_merge_matrix_wo_strings.Mouse); hands = ['R';'L'];

%HMM without outliers (specific for each day to exclude parameters based on signal spikes)
huge_merge_matrix_wo_outliers = huge_merge_matrix_wo_strings; 

%extreme outliers (optional)
huge_merge_matrix_wo_outliers(:,15:end) = filloutliers(huge_merge_matrix_wo_outliers(:,15:end),NaN,'percentiles',[1 99]);

for day = 1:size(days_list,1)
for hand = 1:length(hands)
outlier_window = size(huge_merge_matrix_wo_outliers(strcmp(huge_merge_matrix_wo_outliers.Hand,hands(hand)) & huge_merge_matrix_wo_outliers.Day == days_list(day),15:end),1);
huge_merge_matrix_wo_outliers(strcmp(huge_merge_matrix_wo_outliers.Hand,hands(hand)) & huge_merge_matrix_wo_outliers.Day == days_list(day),15:end) = ...
fillmissing(huge_merge_matrix_wo_outliers(strcmp(huge_merge_matrix_wo_outliers.Hand,hands(hand)) & huge_merge_matrix_wo_outliers.Day == days_list(day),15:end),'movmean',outlier_window);
end
end

slips_table = readtable(''); %separate slips table after post-processing via MouseReach App, or:
%slips_table = groupsummary(huge_merge_matrix_wo_strings(:,1:14),["Day","Mouse","Hand","Trial","Grab"],"mean"); %grouped by grab
slips_matrix = slips_table(slips_table.Grab == 2,:); slips_grouped = groupsummary(slips_matrix(:,2:15),["Day","Mouse","Hand","Trial","Grab"],"mean");

huge_merge_matrix_wo_strings(huge_merge_matrix_wo_strings.Grab == 2,:) = [];
huge_merge_matrix_wo_outliers(huge_merge_matrix_wo_outliers.Grab == 2,:) = []; %exclude slips (after defining slip_table)

%reduce kinematics only to certain pellets (optional)
%huge_merge_matrix_wo_outliers = huge_merge_matrix_wo_outliers(ismember(huge_merge_matrix_wo_outliers.Pellet,3),:);

summary_table = groupsummary(huge_merge_matrix_wo_outliers,["Day","Mouse","Hand","Trial"],"mean"); %std %huge_merge_matrix_wo_outliers
summary_table = summary_table(summary_table.GroupCount > 5,:); %consider only mice that have a representative number of reach events
summary_table = summary_table(:,[1:4,16:end]); %main table

success_table = groupsummary(huge_merge_matrix_wo_strings(:,1:14),["Day","Mouse","Hand","Trial","Success"],"mean"); %grouped by success

%add success ratio (all successful reaches/all reaches in one session per mouse)
for day=1:size(days_list,1)
for mouse=1:size(mouse_list,1)
for hand=1:length(hands)

successful_reaches = success_table.GroupCount(success_table.Day == days_list(day) & strcmp(success_table.Hand,hands(hand)) & success_table.Mouse == mouse_list(mouse) & success_table.Success == 1);
unsuccessful_reaches = success_table.GroupCount(success_table.Day == days_list(day) & strcmp(success_table.Hand,hands(hand)) & success_table.Mouse == mouse_list(mouse) & success_table.Success == 0);
if isempty(successful_reaches), successful_reaches = 0; end; if isempty(unsuccessful_reaches), unsuccessful_reaches = 0; end

%all_reaches = sum(success_table.GroupCount(success_table.Day == days_list(day) & strcmp(success_table.Hand,hands(hand)) & success_table.Mouse == mouse_list(mouse) & success_table.Success ~= 2));
all_reaches = unsuccessful_reaches + successful_reaches; %without empty reaches

if all_reaches > 0 %if denominator > 0
mouse_success_ratio = successful_reaches^2/all_reaches;
else
mouse_success_ratio = 0; %if no reaches at all
end

%find corresponding mouse in the summary_table
target_row = summary_table(summary_table.Day == days_list(day) & summary_table.Mouse == mouse_list(mouse) & strcmp(summary_table.Hand,hands(hand)),:);
if ~isempty(target_row)
summary_table.SuccessRatio(summary_table.Day == days_list(day) & summary_table.Mouse == mouse_list(mouse) & strcmp(summary_table.Hand,hands(hand))) = mouse_success_ratio;
summary_table.SuccessEvents(summary_table.Day == days_list(day) & summary_table.Mouse == mouse_list(mouse) & strcmp(summary_table.Hand,hands(hand))) = successful_reaches;
else %if not there, create a new row
new_row = array2table([days_list(day), mouse_list(mouse), NaN, 1, NaN(1,49), 0, 0]);

% new_row.Properties.VariableNames = summary_table.Properties.VariableNames;
if length(new_row.Properties.VariableNames) == length(summary_table.Properties.VariableNames)
new_row.Properties.VariableNames = summary_table.Properties.VariableNames;
else
new_row.Properties.VariableNames = [summary_table.Properties.VariableNames,'SuccessRatio','SuccessEvents'];
summary_table.SuccessRatio(:) = NaN; summary_table.SuccessEvents(:) = NaN;
end
new_row.Hand = hands(hand);

summary_table = [summary_table; new_row]; summary_table = sortrows(summary_table,{'Day','Mouse'}); %#ok<AGROW>
end

end
end
end


%add grabs and pellets count (sum of all grabs/pellets removed per mouse)
% summary_table.ReachesCount(:) = 0; summary_table.PelletsCount(:) = 0;
% 
% for day=1:size(days_list,1)
% for mouse=1:size(mouse_list,1)
% for hand=1:length(hands)
% 
% if strcmp(hands(hand),'R') %reaches count
% summary_table.ReachesCount(summary_table.Day == days_list(day) & summary_table.Mouse == mouse_list(mouse) & strcmp(summary_table.Hand,hands(hand))) = total_grabs_count_r_e(mouse_list(mouse),days_list(day));
% elseif strcmp(hands(hand),'L')
% summary_table.ReachesCount(summary_table.Day == days_list(day) & summary_table.Mouse == mouse_list(mouse) & strcmp(summary_table.Hand,hands(hand))) = total_grabs_count_l_e(mouse_list(mouse),days_list(day));
% end
% 
% if strcmp(hands(hand),'R') %pellets count
% summary_table.PelletsCount(summary_table.Day == days_list(day) & summary_table.Mouse == mouse_list(mouse) & strcmp(summary_table.Hand,hands(hand))) = total_pellets_count_r_e(mouse_list(mouse),days_list(day));
% elseif strcmp(hands(hand),'L')
% summary_table.PelletsCount(summary_table.Day == days_list(day) & summary_table.Mouse == mouse_list(mouse) & strcmp(summary_table.Hand,hands(hand))) = total_pellets_count_l_e(mouse_list(mouse),days_list(day));
% end
% 
% end
% end
% end

%add grabs and pellets from separate tables
reach_table = groupsummary(huge_merge_matrix_wo_outliers,["Day","Mouse","Hand"]); %trial, tongue and slips have been already removed
auto_pellets_right = readtable('pellet_table1.xlsx'); auto_pellets_right = table2array(auto_pellets_right);
auto_pellets_left = readtable('pellet_table2.xlsx'); auto_pellets_left = table2array(auto_pellets_left);
auto_sum_right = sum(auto_pellets_right); auto_sum_left = sum(auto_pellets_left);
summary_table.ReachesCount(:) = 0; summary_table.PelletsCount(:) = 0;

for day=1:size(days_list,1)
for mouse=1:size(mouse_list,1)
for hand=1:length(hands)

%reaches count
try
summary_table.ReachesCount(summary_table.Day == days_list(day) & summary_table.Mouse == mouse_list(mouse) & strcmp(summary_table.Hand,hands(hand))) = ...
reach_table.GroupCount(strcmp(hands(hand),reach_table.Hand) & reach_table.Mouse == mouse_list(mouse) & reach_table.Day == days_list(day));
catch
summary_table.ReachesCount(summary_table.Day == days_list(day) & summary_table.Mouse == mouse_list(mouse) & strcmp(summary_table.Hand,hands(hand))) = 0;
end

%pellets_count
if strcmp(hands(hand),'R')
summary_table.PelletsCount(summary_table.Day == days_list(day) & summary_table.Mouse == mouse_list(mouse) & strcmp(summary_table.Hand,hands(hand))) = auto_pellets_right(mouse,days_list(day));
elseif strcmp(hands(hand),'L')
summary_table.PelletsCount(summary_table.Day == days_list(day) & summary_table.Mouse == mouse_list(mouse) & strcmp(summary_table.Hand,hands(hand))) = auto_pellets_left(mouse,days_list(day));
end

end
end
end

%add slips
for day=1:size(days_list,1)
for mouse=1:size(mouse_list,1)
for hand=1:length(hands)

mouse_slips = slips_grouped.GroupCount(slips_grouped.Day == days_list(day) & slips_grouped.Mouse == mouse_list(mouse) & strcmp(slips_grouped.Hand,hands(hand)) & slips_grouped.Grab == 2);
if isempty(mouse_slips), mouse_slips = 0; end

summary_table.SlipsCount(summary_table.Day == days_list(day) & summary_table.Mouse == mouse_list(mouse) & strcmp(summary_table.Hand,hands(hand))) = mouse_slips;
end
end
end

%add time grabbed (not used anymore)
% PT_grabbed = readtable('');
% 
% %outliers in tracking of GrabbedObj (optional)
% PT_grabbed(:,5:6) = filloutliers(PT_grabbed(:,5:6),NaN,'percentiles', [1 99]);
% 
% for day = 1:size(days_list,1)
% for hand = 1:length(hands)
% time_window = size(PT_grabbed(strcmp(PT_grabbed.Hand,hands(hand)) & PT_grabbed.Day == days_list(day),5:6),1);
% PT_grabbed(strcmp(PT_grabbed.Hand,hands(hand)) & PT_grabbed.Day == days_list(day),5:6) = ...
% fillmissing(PT_grabbed(strcmp(PT_grabbed.Hand,hands(hand)) & PT_grabbed.Day == days_list(day),5:6),'movmean',time_window);
% end
% end
% 
% %add Grabbed Time to summary_table
% PT_time = groupsummary(PT_grabbed,["Day","Mouse","Hand"],"mean"); PT_events = groupsummary(PT_grabbed,["Day","Mouse","Hand"],"sum"); 
% for day=1:size(days_list,1)
% for mouse=1:size(mouse_list,1)
% for hand=1:length(hands)
% 
% mean_time = PT_time.mean_Time(PT_time.Day == days_list(day) & PT_time.Mouse == mouse_list(mouse) & strcmp(PT_time.Hand, hands(hand)));
% if isempty(mean_time), mean_time = NaN; end
% sum_events = PT_events.sum_Events(PT_events.Day == days_list(day) & PT_events.Mouse == mouse_list(mouse) & strcmp(PT_events.Hand, hands(hand)));
% if isempty(sum_events), sum_events = 0; end
% 
% summary_table.GrabbedTime(summary_table.Day == days_list(day) & summary_table.Mouse == mouse_list(mouse) & strcmp(summary_table.Hand,hands(hand))) = mean_time;
% summary_table.GrabbedEvents(summary_table.Day == days_list(day) & summary_table.Mouse == mouse_list(mouse) & strcmp(summary_table.Hand,hands(hand))) = sum_events;
% 
% end
% end
% end

%impute non-reachers (optional)
for v1 = 57:60
summary_table{summary_table.ReachesCount < 5,v1} = NaN;
end
for v2 = 5:56 %reaches count last 54:56
summary_table{summary_table.ReachesCount < 5,v2} = NaN;
end

%fill missing mean values (optional)
for day = 1:size(days_list,1)
for hand = 1:length(hands)
mm_window = size(summary_table(strcmp(summary_table.Hand,hands(hand)) & summary_table.Day == days_list(day),5:end),1);
summary_table(strcmp(summary_table.Hand,hands(hand)) & summary_table.Day == days_list(day),5:end) = ...
fillmissing(summary_table(strcmp(summary_table.Hand,hands(hand)) & summary_table.Day == days_list(day),5:end),'movmean',mm_window); %replace missing values as the average value of that particular session and body side
end
end

%plotting a single experiment
% hand = 'R';
% scattering_variable = 0.4*rand(size(summary_table(strcmp(summary_table.Hand,hand),:),1),1)-0.2;
% for i = 50:60%5:size(summary_table,2) %54 success ratio | 57,58 grabbed events
% %figure
% %figure('Position',[1000 1000 550 400]);
% figure('Position',[400 1000 550 400]);
% 
% col_name = summary_table.Properties.VariableNames(i);
% k_variable = [summary_table.Day(strcmp(summary_table.Hand,hand)) summary_table{(strcmp(summary_table.Hand,hand)),col_name}];
% %k_variable = [reach_table.Day reach_table.mean_AvgSpeedTotal]; %change to wished parameter
% 
% scatter(k_variable(:,1)+scattering_variable, k_variable(:,2),'.'); hold on;
% e = errorbar([1 2 3 4],...
% [mean(k_variable(k_variable(:,1) == 1, 2),'omitnan')...
% mean(k_variable(k_variable(:,1) == 2, 2),'omitnan')...
% mean(k_variable(k_variable(:,1) == 3, 2),'omitnan')...
% mean(k_variable(k_variable(:,1) == 4, 2),'omitnan')],...
% [std(k_variable(k_variable(:,1) == 1, 2),'omitnan')/sqrt(length(k_variable(k_variable(:,1) == 1, 2)))...
% std(k_variable(k_variable(:,1) == 2, 2),'omitnan')/sqrt(length(k_variable(k_variable(:,1) == 2, 2)))...
% std(k_variable(k_variable(:,1) == 3, 2),'omitnan')/sqrt(length(k_variable(k_variable(:,1) == 3, 2)))...
% std(k_variable(k_variable(:,1) == 4, 2),'omitnan')/sqrt(length(k_variable(k_variable(:,1) == 4, 2)))]);
% 
% legend(e,{[hand,' Hand']});
% title(col_name{1}(1:end)); %6:end
% 
% end

%writetable(reach_table,'');
