clear
close all
yes_export = 0;

%MCAO data (first dataset)
huge_merge_matrix_M = readtable(''); %huge merge matrix
experimental_table_M = readtable('','Sheet','Sheet1'); %visual (manual) table
pellets_right_M = readtable(''); %automated table pellets count right
pellets_left_M = readtable(''); %automated table pellets count left
mouse_list_M = unique(huge_merge_matrix_M.Mouse(strcmp(huge_merge_matrix_M.Trial,'C'))); mouse_list_M(mouse_list_M == 23) = [];

%PT data (second dataset)
huge_merge_matrix_PT = readtable('');
experimental_table_PT = readtable(''); experimental_table_PT.ID = [];
pellets_right_PT = readtable('');
pellets_left_PT = readtable('');
mouse_list_PT = unique(huge_merge_matrix_PT.Mouse(huge_merge_matrix_PT.Trial == 1));

%Sham data (third dataset)
huge_merge_matrix_S = readtable('');
experimental_table_S = readtable('');
pellets_right_S = readtable('');
pellets_left_S = readtable('');
mouse_list_S = unique(huge_merge_matrix_S.Mouse(huge_merge_matrix_S.Trial == 0));

%classic automated detection
pellets_right_M = table2array(pellets_right_M); pellets_left_M = table2array(pellets_left_M);
pellets_right_PT = table2array(pellets_right_PT); pellets_left_PT = table2array(pellets_left_PT);
pellets_right_S = table2array(pellets_right_S); pellets_left_S = table2array(pellets_left_S);

%pellets from manual counting
experimental_table_M = experimental_table_M(ismember(experimental_table_M.Mouse,mouse_list_M),:); experimental_table_M.Mouse = [];
experimental_table_PT = experimental_table_PT(ismember(experimental_table_PT.Mouse,mouse_list_PT),:); experimental_table_PT.Mouse = [];
experimental_table_S = experimental_table_S(ismember(experimental_table_S.Mouse,mouse_list_S),:); %experimental_table_S.Mouse = [];

%calculate difference in scores (the error)
error_right_M = zeros(size(pellets_right_M(:,1),1),1); error_left_M = zeros(size(pellets_left_M(:,1),1),1);
error_right_PT = zeros(size(pellets_right_PT(:,1),1),1); error_left_PT = zeros(size(pellets_left_PT(:,1),1),1);
error_right_S = zeros(size(pellets_right_S(:,1),1),1); error_left_S = zeros(size(pellets_left_S(:,1),1),1);

for day = 1:4
error_right_M(:,day) = pellets_right_M(:,day) - experimental_table_M.displaced_right(experimental_table_M.Day == day,:);
error_left_M(:,day) = pellets_left_M(:,day) - experimental_table_M.displaced_left(experimental_table_M.Day == day,:);
error_right_PT(:,day) = pellets_right_PT(:,day) - experimental_table_PT.displaced_right(experimental_table_PT.Day == day,:);
error_left_PT(:,day) = pellets_left_PT(:,day) - experimental_table_PT.displaced_left(experimental_table_PT.Day == day,:);
error_right_S(:,day) = pellets_right_S(:,day) - experimental_table_S.visual_corr_r(experimental_table_S.Day == day,:);
error_left_S(:,day) = pellets_left_S(:,day) - experimental_table_S.visual_corr_l(experimental_table_S.Day == day,:);
end

error_M = [reshape(error_right_M,[],1); reshape(error_left_M,[],1)]; %total errors M
error_PT = [reshape(error_right_PT,[],1); reshape(error_left_PT,[],1)]; %total errors PT
error_S = [reshape(error_right_S,[],1); reshape(error_left_S,[],1)];
[err_occurrence_M, err_type_M] = groupcounts(error_M); err_occurrence_M = err_occurrence_M/sum(err_occurrence_M); %count errors %normalize
[err_occurrence_PT, err_type_PT] = groupcounts(error_PT); err_occurrence_PT = err_occurrence_PT/sum(err_occurrence_PT);
[err_occurrence_S, err_type_S] = groupcounts(error_S); err_occurrence_S = err_occurrence_S/sum(err_occurrence_S);

pd_M = fitdist(error_M,'Normal'); pdfEst_M = pdf(pd_M,-3:0.05:3);
pd_PT = fitdist(error_PT,'Normal'); pdfEst_PT = pdf(pd_PT,-3:0.05:3);
pd_S = fitdist(error_S,'Normal'); pdfEst_S = pdf(pd_S,-3:0.05:3);

%plot data
M_bcolor = "#1A85FF"; PT_bcolor = "#c20064"; S_bcolor = "#A7A7A7"; bar_alpha = 0.8;
ticks_font = 8; axes_font = 10; 

%figure parameters
publication_size = [300 220];
current_size = publication_size;

figure('Position',[100 1000 current_size],'Color','w'); hold on;
b1 = bar(err_type_M,err_occurrence_M*100,'BarWidth',1,'FaceAlpha',bar_alpha); c1 = plot(-3:0.05:3,pdfEst_M*100,'k','LineWidth',2);
ytickformat('percentage'); ax = gca; ax.FontSize = ticks_font; 
ylabel('Occurrence','FontSize',axes_font); xlabel('Pellets miscounted','FontSize',axes_font);
b1.FaceColor = M_bcolor; yticks([0 25 50 75 100]); xlim([-2.5 2.5]); %title('Error rate: MCAO (all days)');

figure('Position',[700 1000 current_size],'Color','w'); hold on;
b2 = bar(err_type_PT,err_occurrence_PT*100,'BarWidth',1,'FaceAlpha',bar_alpha); plot(-3:0.05:3,pdfEst_PT*100,'k','LineWidth',2);
ytickformat('percentage'); ax = gca; ax.FontSize = ticks_font;
ylabel('Occurrence','FontSize',axes_font); xlabel('Pellets miscounted','FontSize',axes_font);
b2.FaceColor = PT_bcolor; yticks([0 25 50 75 100]); xlim([-2.5 2.5]); %title('Error rate: PT (all days)');

figure('Position',[1300 1000 current_size],'Color','w'); hold on;
b3 = bar(err_type_S,err_occurrence_S*100,'BarWidth',1,'FaceAlpha',bar_alpha); plot(-3:0.05:3,pdfEst_S*100,'k','LineWidth',2);
ytickformat('percentage'); ax = gca; ax.FontSize = ticks_font;
ylabel('Occurrence','FontSize',axes_font); xlabel('Pellets miscounted','FontSize',axes_font);
b3.FaceColor = S_bcolor; yticks([0 25 50 75 100]); ylim([0 100]); xlim([-2.5 2.5]); %title('Error rate: Sham (all days)'); 

%export all figures
% if yes_export == 1
% my_figures = findobj('Type','Figure');
% for f = 1:length(my_figures)
% export_fig(my_figures(f),'/home/nikolaus/Desktop/Matlab_Scripts/Plots/plots','-pdf','-append')
% end
% end

if yes_export == 1
my_figures = findobj('Type','Figure');
for f = 1:length(my_figures)
n = my_figures(f).Number;
switch n
case 1, figname = "errorrate_MCAO";
case 2, figname = "errorrate_PT";
end
print(my_figures(f),strcat('/home/nikolaus/Desktop/Matlab_Scripts/Plots/',figname), '-dsvg')
end
end