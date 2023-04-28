%builtin.com/data-science/step-step-explanation-principal-component-analysis
%strata.uga.edu/8370/lecturenotes/principalComponents.html
%theanalysisfactor.com/principal-component-analysis-negative-loadings/
%https://de.mathworks.com/matlabcentral/answers/270329-how-to-select-the-components-that-show-the-most-variance-in-pca
%https://stats.stackexchange.com/questions/50537/should-one-remove-highly-correlated-variables-before-doing-pca

clear
close all
yes_export = 0; %if 1, export automatically to PDF

%plot layout
%M_bcolor = '#1A85FF'; PT_bcolor = '#c20064'; S_bcolor = "#A7A7A7";
ticks_font = 8; axes_font = 10; marker_sz = 25; marker_alpha = 0.8; % sz 30 al 0.9
%day4_color = hex2rgb('#A7A7A7'); day7_color = hex2rgb('#D62246'); day14_color = hex2rgb('#3066BE'); day21_color = hex2rgb('#000505');
%day4_color = hex2rgb('#A7A7A7'); day7_color = hex2rgb('#D41159'); day14_color = hex2rgb('#40B0A6'); day21_color = hex2rgb('#434446');
days_color = [hex2rgb('#ACAABA'); hex2rgb('#5DD9C1'); hex2rgb('#345995'); hex2rgb('#12474A'); ...
hex2rgb('#C2948A'); hex2rgb('#F7717D'); hex2rgb('#92374D'); hex2rgb('#7F2982')];
%https://coolors.co/acaaba-5dd9c1-345995-12474a-f0cf65
%https://coolors.co/c2948a-f7717d-92374d-7f2982-156064
bwidth = 0.8; bar_alpha = 0.8; eb_linewidth = 1.5;

%figure parameters
publication_size = [300 300]; %default size [330 220]
current_size = publication_size;

%variable names
oldnames = {'mean_TotalDur','mean_FlexDur','mean_ExtDur','mean_FlexDurPer','mean_ExtDurPer','mean_PathLen','mean_ReachDist','mean_AvgSpeedTotal','mean_AvgSpeedFlex','mean_AvgSpeedExt',...
'mean_MaxSpeedTotal','mean_MaxSpeedFlex','mean_MaxSpeedExt','mean_AvgAccTotal','mean_AvgAccFlex','mean_AvgAccExt','mean_MaxAccTotal','mean_MaxAccFlex','mean_MaxAccExt',...
'mean_AvgDecTotal','mean_AvgDecFlex','mean_AvgDecExt', 'mean_MaxDecTotal','mean_MaxDecFlex','mean_MaxDecExt','mean_T_MaxSpeedTotal','mean_T_MaxSpeedFlex','mean_T_MaxSpeedExt',...
'mean_T_MaxAccTotal','mean_T_MaxAccFlex','mean_T_MaxAccExt','mean_T_MaxDecTotal','mean_T_MaxDecFlex','mean_T_MaxDecExt','mean_TPerc_MaxSpeedTotal','mean_TPerc_MaxSpeedFlex',...
'mean_TPerc_MaxSpeedExt','mean_TPerc_MaxAccTotal','mean_TPerc_MaxAccFlex','mean_T_PercMaxAccExt','mean_TPerc_MaxDecTotal','mean_TPerc_MaxDecFlex','mean_TPerc_MaxDecExt',...
'mean_OnsetSpeedFlex','mean_OnsetSpeedExt','mean_OnsetAccFlex','mean_OnsetAccExt','mean_OnsetDecFlex','mean_OnsetDecExt','SuccessRatio','SuccessEvents','ReachesCount',...
'PelletsCount','SlipsCount','SlipDepth','SlipTime','GrabDepth','GrabTime'};

newnames = {'Duration','Reach Duration','Retraction Duration','Reach Fraction','Retraction Fraction','Path Length','Reach Distance',...
'Average Speed','Reach Average Speed','Retraction Average Speed','Maximal Speed','Reach Maximal Speed','Retraction Maximal Speed',...
'Average Acceleration','Reach Average Acc','Retraction Average Acc','Maximal Acceleration',...
'Reach Maximal Acc','Retraction Maximal Acc','Average Deceleration','Reach Average Dec',...
'Retraction Average Dec', 'Maximal Deceleration', 'Reach Maximal Dec', 'Retraction Maximal Dec',...
'Maximal Speed Time','Reach Maximal Speed Time','Retraction Max Speed Time','Maximal Acc Time', 'Reach Max Acc Time',...
'Retraction Max Acc Time','Maximal Dec Time','Reach Max Dec Time','Retraction Max Dec Time',...
'Maximal Speed Fraction','Reach Max Speed Fraction','Retraction Max Speed Fraction','Maximal Acc Fraction','Reach Max Acc Fraction',...
'Retraction Max Acc Fraction','Maximal Dec Fraction', 'Reach Max Dec Fraction','Retraction Max Dec Fraction',...
'Reach Onset Speed', 'Retraction Onset Speed','Reach Onset Acc','Retraction Onset Acc','Reach Onset Dec',...
'Retraction Onset Dec','Success Coefficient', 'Success Events', 'Reach Count','Pellet Count','Slip Count','Slip Depth','Slip Time','Grab Depth','Grab Time'};

%load tables
M_summary = readtable(''); M_summary(M_summary.Mouse == 34,:) = [];
PT_summary = readtable(''); %summary table
M_summary(:,{'SlipDepth','SlipTime','GrabDepth','GrabTime'}) = fillmissing(M_summary(:,{'SlipDepth','SlipTime','GrabDepth','GrabTime'}),'constant',0);
PT_summary(:,{'SlipDepth','SlipTime','GrabDepth','GrabTime'}) = fillmissing(PT_summary(:,{'SlipDepth','SlipTime','GrabDepth','GrabTime'}),'constant',0);

chosen_vars = {'Day','Mouse','Hand','mean_TotalDur','mean_FlexDur','mean_ExtDur','mean_FlexDurPer','mean_ExtDurPer','mean_PathLen','mean_ReachDist','mean_AvgSpeedTotal','mean_AvgSpeedFlex','mean_AvgSpeedExt',...
'mean_MaxSpeedTotal','mean_MaxSpeedFlex','mean_MaxSpeedExt','mean_AvgAccTotal','mean_AvgAccFlex','mean_AvgAccExt','mean_MaxAccTotal','mean_MaxAccFlex','mean_MaxAccExt',...
'mean_AvgDecTotal','mean_AvgDecFlex','mean_AvgDecExt', 'mean_MaxDecTotal','mean_MaxDecFlex','mean_MaxDecExt','mean_T_MaxSpeedTotal','mean_T_MaxSpeedFlex','mean_T_MaxSpeedExt',...
'mean_T_MaxAccTotal','mean_T_MaxAccFlex','mean_T_MaxAccExt','mean_T_MaxDecTotal','mean_T_MaxDecFlex','mean_T_MaxDecExt','mean_TPerc_MaxSpeedTotal','mean_TPerc_MaxSpeedFlex',...
'mean_TPerc_MaxSpeedExt','mean_TPerc_MaxAccTotal','mean_TPerc_MaxAccFlex','mean_T_PercMaxAccExt','mean_TPerc_MaxDecTotal','mean_TPerc_MaxDecFlex','mean_TPerc_MaxDecExt',...
'mean_OnsetSpeedFlex','mean_OnsetSpeedExt','mean_OnsetAccFlex','mean_OnsetAccExt','mean_OnsetDecFlex','mean_OnsetDecExt','SuccessRatio','SuccessEvents','ReachesCount',...
'PelletsCount','SlipsCount','SlipDepth','SlipTime','GrabDepth','GrabTime'};

M_summary = M_summary(:,chosen_vars); PT_summary = PT_summary(:,chosen_vars);

%relativize values for individual mice (optional)
datasets = {'MCAO';'PT'}; hands = {'R';'L'};
M_mice = unique(M_summary.Mouse); PT_mice = unique(PT_summary.Mouse);

% for d = 1:size(datasets,1)
% 
% data = datasets(d);
% if strcmp(data,'MCAO')
% current_table = M_summary; mice = M_mice;
% elseif strcmp(data,'PT')
% current_table = PT_summary; mice = PT_mice;
% end
% 
% for var = 5:size(current_table,2) %go through all columns %53
% for i = 1:size(mice,1) %consider one mouse
% mouse = mice(i);
% %for j = 1:size(hands,1) %look at values for each hand individually
% %hand = hands(j);
% 
% current_table{current_table.Mouse == mouse,var} = normalize(current_table{current_table.Mouse == mouse,var});
% % current_table{current_table.Mouse == mouse & strcmp(current_table.Hand,hand),var} = normalize(current_table{current_table.Mouse == mouse & strcmp(current_table.Hand,hand),var});
% %end
% end
% end
% if strcmp(data,'MCAO'), M_summary = current_table; elseif strcmp(data,'PT'), PT_summary = current_table; end
% end

%build groups and datatables for PCA
size_M1 = size(M_summary(M_summary.Day == 1 & strcmp(M_summary.Hand,'R'),:),1);
size_M2 = size(M_summary(M_summary.Day == 2 & strcmp(M_summary.Hand,'R'),:),1);
size_M3 = size(M_summary(M_summary.Day == 3 & strcmp(M_summary.Hand,'R'),:),1);
size_M4 = size(M_summary(M_summary.Day == 4 & strcmp(M_summary.Hand,'R'),:),1);

size_PT1 = size(PT_summary(PT_summary.Day == 1 & strcmp(PT_summary.Hand,'R'),:),1);
size_PT2 = size(PT_summary(PT_summary.Day == 2 & strcmp(PT_summary.Hand,'R'),:),1);
size_PT3 = size(PT_summary(PT_summary.Day == 3 & strcmp(PT_summary.Hand,'R'),:),1);
size_PT4 = size(PT_summary(PT_summary.Day == 4 & strcmp(PT_summary.Hand,'R'),:),1);

groups_R = [repmat({'MCAO -4'},size_M1,1); repmat({'MCAO 7'},size_M2,1); repmat({'MCAO 14'},size_M3,1); repmat({'MCAO 21'},size_M4,1); ...
repmat({'PT -4'},size_PT1,1); repmat({'PT 7'},size_PT2,1); repmat({'PT 14'},size_PT3,1); repmat({'PT 21'},size_PT4,1)];
groups_L = groups_R; %same number of animals, same number of groups

PCA_table_R = [table2array(M_summary(strcmp(M_summary.Hand,'R'),4:end)); table2array(PT_summary(strcmp(PT_summary.Hand,'R'),4:end))];
PCA_table_L = [table2array(M_summary(strcmp(M_summary.Hand,'L'),4:end)); table2array(PT_summary(strcmp(PT_summary.Hand,'L'),4:end))];

%normalize data before PCA
PCA_table_R = normalize(PCA_table_R); PCA_table_L = normalize(PCA_table_L);

%PCA
[coeff_R,score_R,latent_R,tsquared_R,explained_R] = pca(PCA_table_R);
[coeff_L,score_L,latent_L,tsquared_L,explained_L] = pca(PCA_table_L);

%ICA
% [score_R,coeff_R,~,~] = pcaica(PCA_table_R'); %[ic,U,pc,V]=pcaica(PCA_table_R) ic = ICA scores, U = ICA coeff, pc = PCA scores, V = PCA coeff
% [score_L,coeff_L,~,~] = pcaica(PCA_table_L'); %here each row is a variable, each column observation
% explained_R = [30; 20]; explained_L = [30; 20]; %didn't find a solution how to calculate eigenvalues
% %transpose score and coeff of ICA because of further code
% score_R = score_R'; coeff_R = coeff_R'; score_L = score_L'; coeff_L = coeff_L';

%tables for plotting
table_R = array2table([score_R(:,1) score_R(:,2)]); table_R.Var3 = groups_R; table_R.Properties.VariableNames = {'Score1','Score2','Groups'};
table_L = array2table([score_L(:,1) score_L(:,2)]); table_L.Var3 = groups_L; table_L.Properties.VariableNames = {'Score1','Score2','Groups'};

%plot PCA
figure; scat_R = scatterhistogram(table_R,'Score1','Score2','GroupVariable','Groups','HistogramDisplayStyle','smooth'); ax = gca; ax.FontSize = ticks_font;
scat_R.LineWidth = [1.5 1.5 1.5 1.5]; scat_R.LineStyle = ["-" "-" "-" "-" "--" "--" "--" "--"]; scat_R.MarkerFilled = 'on'; scat_R.MarkerAlpha = marker_alpha;
scat_R.Color = days_color; scat_R.MarkerSize = [marker_sz marker_sz marker_sz marker_sz];
scat_R.XLabel = strcat('PC1 (',string(round(explained_R(1),1)),'% explained variance)'); scat_R.LegendTitle = 'Days'; scat_R.LegendVisible = 'on';
scat_R.YLabel = strcat('PC2 (',string(round(explained_R(2),1)),'% explained variance)'); scat_R.Title = 'Contralesional Hand';
set(gcf,'Position',[983 575 current_size],'Color','w'); %scat_R.XLimits = [-13 13]; scat_R.YLimits = [-9 8]; pause(0.5) %scat_MR.XLimits = [-12.5 11.5]; scat_MR.YLimits = [-8.5 8];
if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf; end

figure; scat_L = scatterhistogram(table_L,'Score1','Score2','GroupVariable','Groups','HistogramDisplayStyle','smooth'); ax = gca; ax.FontSize = ticks_font;
scat_L.LineWidth = [1.5 1.5 1.5 1.5]; scat_L.LineStyle = ["-" "-" "-" "-" "--" "--" "--" "--"]; scat_L.MarkerFilled = 'on'; scat_L.MarkerAlpha = marker_alpha;
scat_L.Color = days_color; scat_L.MarkerSize = [marker_sz marker_sz marker_sz marker_sz];
scat_L.XLabel = strcat('PC1 (',string(round(explained_L(1),1)),'% explained variance)'); scat_L.LegendTitle = 'Days';
scat_L.YLabel = strcat('PC2 (',string(round(explained_L(2),1)),'% explained variance)'); scat_L.Title = 'Ipsilesional Hand';
set(gcf,'Position',[488 575 current_size],'Color','w'); %scat_L.XLimits = [-13 13]; scat_L.YLimits = [-9 8]; pause(0.5) %scat_ML.XLimits = [-13 13.5]; scat_ML.YLimits = [-9 7.5];
if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf -append; end



%create custom colormap
% custom_colormap = [0.9000 0.9447 0.9741; 0.1445 0.4023 0.625]; %custom_colormap = [0.9000 0.9447 0.9741; 0 0.4470 0.7410]; %default
% custom_colormap = interp1(1:size(custom_colormap,1),custom_colormap,1:0.015:size(custom_colormap,1),'linear'); %blue->white
% custom_colormap = brighten(cool,-0.2); 

custom_colormap = [0.2314 0.7686 1; 1 1 1; 0.7412 0.2588 1]; %custom_colormap = [0 1 1; 1 1 1; 1 0 1];
%NEW
part1 = interp1(1:2,custom_colormap(1:2,:),1:0.01:2,'linear'); %transition first color to white
part2 = repmat([1 1 1],100,1); %white
part3 = interp1(2:3,custom_colormap(2:3,:),2:0.01:3,'linear'); %transition white to second color
custom_colormap = [part1; part2; part3];
%OLD: custom_colormap = interp1(1:size(custom_colormap,1),custom_colormap,1:0.01:2:0.01:3,'linear');  %#ok<M3COL>
custom_colormap = brighten(custom_colormap,-0.2);

%variable names
[~,where] = ismember(chosen_vars,oldnames); targets = where(where>0); %only existing indices
varnames = newnames(targets);

%create heatmaps
figure; hmap_R = heatmap(coeff_R(:,1:3),'Colormap',custom_colormap,'XLabel','Principal Components','YLabel','Variables','CellLabelColor','none'); %brighten(cool,-0.2)
hmap_R.FontSize = axes_font; title('Contralesional Hand'); set(gcf,'Position',[498 -33 400 600],'Color','w'); pause(0.5) %hmap_MR.ColorScaling = 'scaledcolumns'; 
hmap_R.YDisplayLabels = varnames; sorty(hmap_R,{'1','2'},'descend'); %hmap_R.ColorLimits = [-0.3 0.3]; %set y-bar limits
if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf -append; end

figure; hmap_L = heatmap(coeff_L(:,1:3),'Colormap',custom_colormap,'XLabel','Principal Components','YLabel','Variables','CellLabelColor','none');
hmap_L.FontSize = axes_font; title('Ipsilesional Hand'); set(gcf,'Position',[76 1 400 600],'Color','w'); pause(0.5) %hmap_ML.ColorScaling = 'scaledcolumns'; 
hmap_L.YDisplayLabels = varnames; sorty(hmap_L,{'1','2'},'descend'); %hmap_L.ColorLimits = [-0.3 0.3];
if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf -append; end


%plot individual components
table_Re = table_R; table_Re.Score3 = score_R(:,3); table_Re = movevars(table_Re,'Score3','Before','Groups');
table_Le = table_L; table_Le.Score3 = score_L(:,3); table_Le = movevars(table_Le,'Score3','Before','Groups');
return
for PC = 1:3 %plot first 3 PCs

switch PC
case 1, chosen_score = 'Score1'; figure('Position',[300 1000 current_size],'Color','w');
case 2, chosen_score = 'Score2'; figure('Position',[600 1000 current_size],'Color','w');
case 3, chosen_score = 'Score3'; figure('Position',[900 1000 current_size],'Color','w');
end

s_M4_var = table_Re{strcmp(table_Re.Groups,'MCAO -4'),chosen_score}; s_M4_mean = mean(s_M4_var); s_M4_sem = std(s_M4_var)/sqrt(length(s_M4_var));
s_M7_var = table_Re{strcmp(table_Re.Groups,'MCAO 7'),chosen_score}; s_M7_mean = mean(s_M7_var); s_M7_sem = std(s_M7_var)/sqrt(length(s_M7_var));
s_M14_var = table_Re{strcmp(table_Re.Groups,'MCAO 14'),chosen_score}; s_M14_mean = mean(s_M14_var); s_M14_sem = std(s_M14_var)/sqrt(length(s_M14_var));
s_M21_var = table_Re{strcmp(table_Re.Groups,'MCAO 21'),chosen_score}; s_M21_mean = mean(s_M21_var); s_M21_sem = std(s_M21_var)/sqrt(length(s_M21_var));

s_PT4_var = table_Re{strcmp(table_Re.Groups,'PT -4'),chosen_score}; s_PT4_mean = mean(s_PT4_var); s_PT4_sem = std(s_PT4_var)/sqrt(length(s_PT4_var));
s_PT7_var = table_Re{strcmp(table_Re.Groups,'PT 7'),chosen_score}; s_PT7_mean = mean(s_PT7_var); s_PT7_sem = std(s_PT7_var)/sqrt(length(s_PT7_var));
s_PT14_var = table_Re{strcmp(table_Re.Groups,'PT 14'),chosen_score}; s_PT14_mean = mean(s_PT14_var); s_PT14_sem = std(s_PT14_var)/sqrt(length(s_PT14_var));
s_PT21_var = table_Re{strcmp(table_Re.Groups,'PT 21'),chosen_score}; s_PT21_mean = mean(s_PT21_var); s_PT21_sem = std(s_PT21_var)/sqrt(length(s_PT21_var));

hold on;
bar(1,s_M4_mean,'FaceColor',days_color(1,:),'BarWidth',bwidth,'FaceAlpha',bar_alpha);
bar(2,s_M7_mean,'FaceColor',days_color(2,:),'BarWidth',bwidth,'FaceAlpha',bar_alpha);
bar(3,s_M14_mean,'FaceColor',days_color(3,:),'BarWidth',bwidth,'FaceAlpha',bar_alpha);
bar(4,s_M21_mean,'FaceColor',days_color(4,:),'BarWidth',bwidth,'FaceAlpha',bar_alpha);
bar(5,s_PT4_mean,'FaceColor',days_color(5,:),'BarWidth',bwidth,'FaceAlpha',bar_alpha);
bar(6,s_PT7_mean,'FaceColor',days_color(6,:),'BarWidth',bwidth,'FaceAlpha',bar_alpha);
bar(7,s_PT14_mean,'FaceColor',days_color(7,:),'BarWidth',bwidth,'FaceAlpha',bar_alpha);
bar(8,s_PT21_mean,'FaceColor',days_color(8,:),'BarWidth',bwidth,'FaceAlpha',bar_alpha);

mean_all = [s_M4_mean s_M7_mean s_M14_mean s_M21_mean s_PT4_mean s_PT7_mean s_PT14_mean s_PT21_mean];
sem_all = [s_M4_sem s_M7_sem s_M14_sem s_M21_sem s_PT4_sem s_PT7_sem s_PT14_sem s_PT21_sem];
[~,idx_pos] = find(mean_all > 0); [~,idx_neg] = find(mean_all < 0);
sem_pos = NaN(1,length(mean_all)); sem_neg = NaN(1,length(mean_all));
sem_pos(idx_pos) = sem_all(idx_pos); sem_neg(idx_neg) = sem_all(idx_neg);

errorbar(1:size(unique(groups_R),1),mean_all,sem_neg,sem_pos,'Color','k','LineStyle','none','LineWidth',eb_linewidth)

title(strcat('CL Hand: Principal Component',{' '},string(PC)),'FontSize',axes_font); ax = gca; ax.FontSize = ticks_font;
xlabel('Groups','FontSize',axes_font); ylabel('Average Score','FontSize',axes_font); xtickangle(45);
xticks(1:8); xticklabels({'MCAO -4','MCAO 7','MCAO 14','MCAO 21','PT -4','PT 7','PT 14','PT 21'});

%statistics
% h = zeros(4,1); pks = zeros(4,1); my_groups = unique(table_Re.Groups);
% for group=1:length(my_groups), [h(group),pks(group)] = kstest(table_Re{strcmp(table_Re.Groups,my_groups(group)),chosen_score}); end
% if pks > 0.05, disp('Normal distribution. Use a parametric test!'); end
% 
% [p,tbl,stats] = kruskalwallis(table_Re{:,chosen_score},table_Re.Groups,'off');
% if p < 0.05, [results,~,~,gnames] = multcompare(stats,'CType','bonferroni','Display','off'); end
% 
% if exist('results','var')
% for c = 1:size(results,1)
% if results(c,6) < 0.05
% sigstar([results(c,1),results(c,2)],results(c,6));
% end
% end
% end

if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf -append; end
end