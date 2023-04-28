clear
hand = 'L';

%dataset 1
big_table_PT = readtable(''); %big_merge_matrix 1
big_table_PT(isnan(big_table_PT.Grab),:) = []; big_table_PT(big_table_PT.Grab == 2,:) = [];
group_big_table_PT = groupsummary(big_table_PT(:,2:15),["Day","Mouse","Hand","Trial","Success"],"mean");
group_big_table_PT(group_big_table_PT.Trial == 0,:) = [];
mouse_list_PT = unique(group_big_table_PT.Mouse);
mice_success_ratio_PT = zeros(4,length(mouse_list_PT));

for day = 1:4
for i = 1:length(mouse_list_PT)

try %calculation differs from the one in compute average
mice_success_ratio_PT(day,i) = group_big_table_PT.GroupCount(group_big_table_PT.Day == day & strcmp(group_big_table_PT.Hand,hand) & group_big_table_PT.Mouse == mouse_list_PT(i) & group_big_table_PT.Success == 1)^2/...
(group_big_table_PT.GroupCount(group_big_table_PT.Day == day & strcmp(group_big_table_PT.Hand,hand) & group_big_table_PT.Mouse == mouse_list_PT(i) & group_big_table_PT.Success == 0)+...
group_big_table_PT.GroupCount(group_big_table_PT.Day == day & strcmp(group_big_table_PT.Hand,hand) & group_big_table_PT.Mouse == mouse_list_PT(i) & group_big_table_PT.Success == 1));
catch
mice_success_ratio_PT(day,i) = 0;
end

end
end

scattering_variable_PT = 0.4*rand(size(mice_success_ratio_PT,2),1)-0.2;
scattering_variable_PT = [1 2 3 4]+scattering_variable_PT;
scattering_variable_PT = scattering_variable_PT';

mean_success_ratio_PT = mean(mice_success_ratio_PT,2);
sem_success_ratio_PT = std(mice_success_ratio_PT,0,2)/sqrt(size(mice_success_ratio_PT,2));

errorbar_PT = errorbar(mean_success_ratio_PT, sem_success_ratio_PT,'Color','Red','LineWidth',2); hold on;
for j = 1:4, scatter(scattering_variable_PT(j,:), mice_success_ratio_PT(j,:),60,'r','.'); end


%dataset 2
big_table_M = readtable(''); %big_merge_matrix 2
group_big_table_M = groupsummary(big_table_M(:,2:15),["Day","Mouse","Hand","Trial","Success"],"mean");
group_big_table_M(strcmp(group_big_table_M.Trial,'E'),:) = [];
mouse_list_M = unique(group_big_table_M.Mouse);
mice_success_ratio_M = zeros(4,length(mouse_list_M));

for day = 1:4
for i = 1:length(mouse_list_M)

try
mice_success_ratio_M(day,i) = group_big_table_M.GroupCount(group_big_table_M.Day == day & strcmp(group_big_table_M.Hand,hand) & group_big_table_M.Mouse == mouse_list_M(i) & group_big_table_M.Success == 1)^2/...
(group_big_table_M.GroupCount(group_big_table_M.Day == day & strcmp(group_big_table_M.Hand,hand) & group_big_table_M.Mouse == mouse_list_M(i) & group_big_table_M.Success == 0)+...
group_big_table_M.GroupCount(group_big_table_M.Day == day & strcmp(group_big_table_M.Hand,hand) & group_big_table_M.Mouse == mouse_list_M(i) & group_big_table_M.Success == 1));
catch
mice_success_ratio_M(day,i) = 0;
end

end
end

scattering_variable_M = 0.4*rand(size(mice_success_ratio_M,2),1)-0.2;
scattering_variable_M = [1 2 3 4]+scattering_variable_M;
scattering_variable_M = scattering_variable_M';

mean_success_ratio_M = mean(mice_success_ratio_M,2);
sem_success_ratio_M = std(mice_success_ratio_M,0,2)/sqrt(size(mice_success_ratio_M,2));

errorbar_M = errorbar(mean_success_ratio_M, sem_success_ratio_M,'Color','Blue','LineWidth',2); hold on;
for j = 1:4, scatter(scattering_variable_M(j,:), mice_success_ratio_M(j,:),60,'b','.'); end


%title and legend
xlabel('Days after Stroke'); xticks([1 2 3 4]); xticklabels({'-4','7','14','21'}); ylabel('Successful Grabs^2/Total Grabs');
title('Success Ratio'); legend([errorbar_PT errorbar_M],{'Photothrombosis (n = 9)','MCAO (n = 12)'})

set(gca,'color',[0.9 0.9 0.9])

