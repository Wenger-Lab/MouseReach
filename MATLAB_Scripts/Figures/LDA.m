clear
close all
yes_export = 0; %if 1, export automatically to PDF

%https://en.wikipedia.org/wiki/Linear_discriminant_analysis
%https://vitalflux.com/pca-vs-lda-differences-plots-examples
%https://de.mathworks.com/help/stats/create-and-visualize-discriminant-analysis-classifier.html
%https://de.mathworks.com/matlabcentral/answers/563678-how-to-interpret-the-coefficients-of-the-lda-function-fitcdiscr-for-dimensionality-reduction
%towardsai.net/p/data-science/lda-vs-pca

%COEFF: Rows of coeff contain the coefficients for the ingredient variables, and its columns correspond to principal components.
%SCORE: Rows of score correspond to observations, and columns correspond to components.

%plot layout
ticks_font = 8; axes_font = 10; marker_sz = 25; marker_alpha = 0.8; % sz 30 al 0.9
days_color = [hex2rgb('#ACAABA'); hex2rgb('#5DD9C1'); hex2rgb('#345995'); hex2rgb('#12474A'); ...
hex2rgb('#C2948A'); hex2rgb('#F7717D'); hex2rgb('#92374D'); hex2rgb('#7F2982')];
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

%variables for analysis
chosen_vars = {'Day','Mouse','Hand','mean_TotalDur','mean_FlexDur','mean_ExtDur','mean_PathLen','mean_ReachDist',...
'mean_AvgSpeedTotal','mean_AvgSpeedFlex','mean_AvgSpeedExt','mean_AvgAccTotal','mean_AvgAccFlex','mean_AvgAccExt','mean_TPerc_MaxSpeedTotal',...
'mean_TPerc_MaxSpeedFlex','mean_TPerc_MaxSpeedExt','mean_TPerc_MaxAccTotal','mean_TPerc_MaxAccFlex','mean_T_PercMaxAccExt',...
'mean_OnsetSpeedFlex','mean_OnsetSpeedExt','mean_OnsetAccFlex','mean_OnsetAccExt'...
'SuccessRatio','SuccessEvents','ReachesCount','PelletsCount','SlipsCount','SlipDepth','SlipTime','GrabDepth','GrabTime'}; %top 3, 30 param

M_summary = M_summary(:,chosen_vars); PT_summary = PT_summary(:,chosen_vars);

%build groups and datatables for LDA
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

LDA_table_R = [table2array(M_summary(strcmp(M_summary.Hand,'R'),4:end)); table2array(PT_summary(strcmp(PT_summary.Hand,'R'),4:end))];
LDA_table_L = [table2array(M_summary(strcmp(M_summary.Hand,'L'),4:end)); table2array(PT_summary(strcmp(PT_summary.Hand,'L'),4:end))];

%normalize data before LDA
LDA_table_R = normalize(LDA_table_R); LDA_table_L = normalize(LDA_table_L);

%LDA
MdlR = fitcdiscr(LDA_table_R,groups_R);
MdlL = fitcdiscr(LDA_table_L,groups_L);

%calculate scores
[eig_vec_R,eig_val_D_R] = eig(MdlR.BetweenSigma, MdlR.Sigma); %Must be in the right order! 
eig_val_R = diag(eig_val_D_R);
[eig_val_R, SortOrder_R] = sort(eig_val_R, 'descend');
eig_vec_R = eig_vec_R(:, SortOrder_R);
score_R = LDA_table_R*eig_vec_R;

[eig_vec_L,eig_val_D_L] = eig(MdlL.BetweenSigma, MdlL.Sigma); %Must be in the right order! 
eig_val_L = diag(eig_val_D_L);
[eig_val_L, SortOrder_L] = sort(eig_val_L, 'descend');
eig_vec_L = eig_vec_L(:, SortOrder_L);
score_L = LDA_table_L*eig_vec_L;

%calculate explained
explained_R = eig_val_R./sum(eig_val_R)*100;
explained_L = eig_val_L./sum(eig_val_L)*100;

%calculated coeffs
coeff_R = eig_vec_R;
coeff_L = eig_vec_L;

%tables for plotting
table_R = array2table([score_R(:,1) score_R(:,2)]); table_R.Var3 = groups_R; table_R.Properties.VariableNames = {'Score1','Score2','Groups'};
table_L = array2table([score_L(:,1) score_L(:,2)]); table_L.Var3 = groups_L; table_L.Properties.VariableNames = {'Score1','Score2','Groups'};

%plot PCA
figure; scat_R = scatterhistogram(table_R,'Score1','Score2','GroupVariable','Groups','HistogramDisplayStyle','smooth'); ax = gca; ax.FontSize = ticks_font;
scat_R.LineWidth = [1.5 1.5 1.5 1.5]; scat_R.LineStyle = ["-" "-" "-" "-" "--" "--" "--" "--"]; scat_R.MarkerFilled = 'on'; scat_R.MarkerAlpha = marker_alpha;
scat_R.Color = days_color; scat_R.MarkerSize = [marker_sz marker_sz marker_sz marker_sz];
scat_R.XLabel = strcat('LD1 (',string(round(explained_R(1),1)),'% explained variance)'); scat_R.LegendTitle = 'Days'; scat_R.LegendVisible = 'on';
scat_R.YLabel = strcat('LD2 (',string(round(explained_R(2),1)),'% explained variance)'); scat_R.Title = 'Contralesional Hand';
set(gcf,'Position',[983 575 current_size],'Color','w'); scat_R.XLimits = [-7.8 5]; scat_R.YLimits = [-6 5]; %pause(0.5) %scat_MR.XLimits = [-12.5 11.5]; scat_MR.YLimits = [-8.5 8];
if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf; end

figure; scat_L = scatterhistogram(table_L,'Score1','Score2','GroupVariable','Groups','HistogramDisplayStyle','smooth'); ax = gca; ax.FontSize = ticks_font;
scat_L.LineWidth = [1.5 1.5 1.5 1.5]; scat_L.LineStyle = ["-" "-" "-" "-" "--" "--" "--" "--"]; scat_L.MarkerFilled = 'on'; scat_L.MarkerAlpha = marker_alpha;
scat_L.Color = days_color; scat_L.MarkerSize = [marker_sz marker_sz marker_sz marker_sz];
scat_L.XLabel = strcat('LD1 (',string(round(explained_L(1),1)),'% explained variation)'); scat_L.LegendTitle = 'Days';
scat_L.YLabel = strcat('LD2 (',string(round(explained_L(2),1)),'% explained variation)'); scat_L.Title = 'Ipsilesional Hand';
set(gcf,'Position',[488 575 current_size],'Color','w'); scat_L.XLimits = [-7.5 7]; scat_L.YLimits = [-5 4.8]; %pause(0.5) %scat_ML.XLimits = [-13 13.5]; scat_ML.YLimits = [-9 7.5];
if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf -append; end

%create custom colormap
custom_colormap = [0.2314 0.7686 1; 1 1 1; 0.7412 0.2588 1]; %custom_colormap = [0 1 1; 1 1 1; 1 0 1];
%NEW
steps = 0.01; whites = 30; %x indices for interpolation
barmin_R = min(min(coeff_R(:,1:3))); barmax_R = max(max(coeff_R(:,1:3)));
ratio_max = 2*barmax_R/(abs(barmax_R)+abs(barmin_R)); ratio_min = 2*abs(barmin_R)/(abs(barmax_R)+abs(barmin_R)); %if symmetrical = 1
part1 = interp1(1:2,custom_colormap(1:2,:),1:steps/ratio_min:2,'linear'); %transition first color (cyan) to white
%part2 = repmat([1 1 1],round((1/steps)*ratio),1); %white
if ratio_max > 1, part2 = repmat([1 1 1],round(whites*ratio_min),1); else, part2 = repmat([1 1 1],round(whites*ratio_max),1); end
part3 = interp1(2:3,custom_colormap(2:3,:),2:steps/ratio_max:3,'linear'); %transition white to second color (lila)
custom_colormap_R = [part1; part2; part3];

barmin_L = min(min(coeff_L(:,1:3))); barmax_L = max(max(coeff_L(:,1:3)));
ratio_max = 2*barmax_L/(abs(barmax_L)+abs(barmin_L)); ratio_min = 2*abs(barmin_L)/(abs(barmax_L)+abs(barmin_L)); %if symmetrical = 1
part1 = interp1(1:2,custom_colormap(1:2,:),1:steps/ratio_min:2,'linear'); %transition first color (cyan) to white
if ratio_max > 1, part2 = repmat([1 1 1],round(whites*ratio_min),1); else, part2 = repmat([1 1 1],round(whites*ratio_max),1); end
part3 = interp1(2:3,custom_colormap(2:3,:),2:steps/ratio_max:3,'linear'); %transition white to second color (lila)
custom_colormap_L = [part1; part2; part3];

% part1 = interp1(1:2,custom_colormap(1:2,:),1:0.01:2,'linear'); %transition first color to white
% part2 = repmat([1 1 1],100,1); %white
% part3 = interp1(2:3,custom_colormap(2:3,:),2:0.01:3,'linear'); %transition white to second color
% custom_colormap = [part1; part2; part3];
%OLD: custom_colormap = interp1(1:size(custom_colormap,1),custom_colormap,1:0.01:2:0.01:3,'linear');  %#ok<M3COL>
custom_colormap_R = brighten(custom_colormap_R,-0.2); custom_colormap_L = brighten(custom_colormap_L,-0.2);

%variable names
[~,where] = ismember(chosen_vars,oldnames); targets = where(where>0); %only existing indices
varnames = newnames(targets);

%create heatmaps
figure; hmap_R = heatmap(coeff_R(:,1:3),'Colormap',custom_colormap_R,'XLabel','Linear Discriminants','YLabel','Variables','CellLabelColor','none'); %brighten(cool,-0.2)
hmap_R.FontSize = axes_font; title('Contralesional Hand'); set(gcf,'Position',[498 -33 400 600],'Color','w'); pause(0.5) %hmap_MR.ColorScaling = 'scaledcolumns'; 
hmap_R.YDisplayLabels = varnames; sorty(hmap_R,{'1','2'},'descend'); %hmap_R.ColorLimits = [-0.3 0.3]; %set y-bar limits
%if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf -append; end

figure; hmap_L = heatmap(coeff_L(:,1:3),'Colormap',custom_colormap_L,'XLabel','Linear Discriminants','YLabel','Variables','CellLabelColor','none');
hmap_L.FontSize = axes_font; title('Ipsilesional Hand'); set(gcf,'Position',[76 1 400 600],'Color','w'); pause(0.5) %hmap_ML.ColorScaling = 'scaledcolumns'; 
hmap_L.YDisplayLabels = varnames; sorty(hmap_L,{'1','2'},'descend'); %hmap_L.ColorLimits = [-0.3 0.3];
%if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf -append; end

%additional horizontal heatmaps
figure; hmap_R = heatmap(coeff_R(:,1)','Colormap',custom_colormap_R,'XLabel','Variables','YLabel','LD1'); %brighten(cool,-0.2)
hmap_R.FontSize = axes_font; title('Contralesional Hand'); set(gcf,'Position',[498 -33 861 102],'Color','w'); pause(0.5) %hmap_MR.ColorScaling = 'scaledcolumns'; 
sortx(hmap_R,'1','descend'); hmap_R.YDisplayLabels = ''; %hmap_R.ColorLimits = [-0.3 0.3]; %set y-bar limits
s_R = struct(hmap_R); s_R.XAxis.TickLabelRotation = 0; %s_R.ColorDisplayData;

figure; hmap_L = heatmap(coeff_L(:,1)','Colormap',custom_colormap_L,'XLabel','Variables','YLabel','LD1'); %brighten(cool,-0.2)
hmap_L.FontSize = axes_font; title('Ipsilesional Hand'); set(gcf,'Position',[76 1 861 102],'Color','w'); pause(0.5) %hmap_MR.ColorScaling = 'scaledcolumns'; 
sortx(hmap_L,'1','descend'); hmap_L.YDisplayLabels = ''; %hmap_R.ColorLimits = [-0.3 0.3]; %set y-bar limits
s_L = struct(hmap_L); s_L.XAxis.TickLabelRotation = 0; %s_L.ColorDisplayData;

%plot individual components (right hand only)
table_Re = table_R; table_Re.Score3 = score_R(:,3); table_Re = movevars(table_Re,'Score3','Before','Groups');
table_Le = table_L; table_Le.Score3 = score_L(:,3); table_Le = movevars(table_Le,'Score3','Before','Groups');

%calculate PCs for CL or IL?
table_A = table_Re; %table to be analyzed, left or right paw
hand_A = 'R'; %hand to be analyzed

%additional tables for 2-way repeated measures NP ANOVA
stat_table = table_A; stat_table.Groups = [];
stat_table.Day = [M_summary.Day(strcmp(M_summary.Hand,hand_A)); PT_summary.Day(strcmp(PT_summary.Hand,hand_A))];
stat_table.Mouse = [M_summary.Mouse(strcmp(M_summary.Hand,hand_A))+10; PT_summary.Mouse(strcmp(PT_summary.Hand,hand_A))];
stat_table.Group = [zeros(size(M_summary(strcmp(M_summary.Hand,hand_A),:),1),1); ones(size(PT_summary(strcmp(PT_summary.Hand,hand_A),:),1),1)];

for PC = 1:3 %plot first 3 PCs
clear p_signrank_MCAO p_signrank_PT

switch PC
case 1, chosen_score = 'Score1'; figure('Position',[300 1000 current_size],'Color','w');
case 2, chosen_score = 'Score2'; figure('Position',[600 1000 current_size],'Color','w');
case 3, chosen_score = 'Score3'; figure('Position',[900 1000 current_size],'Color','w');
end

s_M4_var = table_A{strcmp(table_A.Groups,'MCAO -4'),chosen_score}; s_M4_mean = mean(s_M4_var); s_M4_sem = std(s_M4_var)/sqrt(length(s_M4_var));
s_M7_var = table_A{strcmp(table_A.Groups,'MCAO 7'),chosen_score}; s_M7_mean = mean(s_M7_var); s_M7_sem = std(s_M7_var)/sqrt(length(s_M7_var));
s_M14_var = table_A{strcmp(table_A.Groups,'MCAO 14'),chosen_score}; s_M14_mean = mean(s_M14_var); s_M14_sem = std(s_M14_var)/sqrt(length(s_M14_var));
s_M21_var = table_A{strcmp(table_A.Groups,'MCAO 21'),chosen_score}; s_M21_mean = mean(s_M21_var); s_M21_sem = std(s_M21_var)/sqrt(length(s_M21_var));

s_PT4_var = table_A{strcmp(table_A.Groups,'PT -4'),chosen_score}; s_PT4_mean = mean(s_PT4_var); s_PT4_sem = std(s_PT4_var)/sqrt(length(s_PT4_var));
s_PT7_var = table_A{strcmp(table_A.Groups,'PT 7'),chosen_score}; s_PT7_mean = mean(s_PT7_var); s_PT7_sem = std(s_PT7_var)/sqrt(length(s_PT7_var));
s_PT14_var = table_A{strcmp(table_A.Groups,'PT 14'),chosen_score}; s_PT14_mean = mean(s_PT14_var); s_PT14_sem = std(s_PT14_var)/sqrt(length(s_PT14_var));
s_PT21_var = table_A{strcmp(table_A.Groups,'PT 21'),chosen_score}; s_PT21_mean = mean(s_PT21_var); s_PT21_sem = std(s_PT21_var)/sqrt(length(s_PT21_var));

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

title(strcat('CL Hand: Linear Discriminant',{' '},string(PC)),'FontSize',axes_font); ax = gca; ax.FontSize = ticks_font;
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

%STATISTICS proper
y = stat_table{:,PC};
A = stat_table.Group; %group
B = stat_table.Day; %time
SUBJ = stat_table.Mouse; %subjects

%Conduct a non-parametric test
rng(0)
alpha      = 0.05;
iterations = 1500; %1500
FFn        = spm1d.stats.nonparam.anova2onerm(y, A, B, SUBJ);
FFni       = FFn.inference(alpha, 'iterations', iterations);
fprintf('NON-PARAMETRIC RESULTS\n')
disp_summ(FFni)

p_group = FFni.SPMs{1}.p; p_time = FFni.SPMs{2}.p; p_grouptime = FFni.SPMs{3}.p;
p = p_grouptime; %if interaction effect grouptime significant, will perform individual pairwise tests

%Post-hoc
if p_grouptime > 0.05 && p_time < 0.05 %re-calculate main effect time if no interaction
anova_time_MCAO = spm1d.stats.nonparam.anova1rm(y(A == 0), B(A == 0), SUBJ(A == 0));
anova_time_PT = spm1d.stats.nonparam.anova1rm(y(A == 1), B(A == 1), SUBJ(A == 1));
anova_time_stat_MCAO = anova_time_MCAO.inference(alpha, 'iterations', iterations);
anova_time_stat_PT = anova_time_PT.inference(alpha, 'iterations', iterations);
p_time_MCAO = anova_time_stat_MCAO.p; p_time_PT = anova_time_stat_PT.p;
else
p_time_MCAO = p_grouptime; p_time_PT = p_grouptime; %if p_grouptime < 0.05, comparison possible anyway
end

%for within-subjects, use Wilcoxon signed rank test -> dependent measurements (time comparisons, single group)
if p_time < 0.05 || p_grouptime < 0.05

if p_time_MCAO < 0.05 %either individual p_time or interaction p allows posthoc
p_signrank_MCAO = zeros(3,3); %(6,3) for full; positions of compared data, p-value
j = 1; 
for dx = 1%:3 %first comparison day
group_dx_MCAO = y(A == 0 & B == dx);
for dnext = dx+1:4 %second comparison day
group_dnext_MCAO = y(A == 0 & B == dnext);
p_signrank_MCAO(j,3) = signrank(group_dx_MCAO,group_dnext_MCAO);
p_signrank_MCAO(j,1) = dx; p_signrank_MCAO(j,2) = dnext;
j = j+1; 
end
end
disp('Time MCAO:'); disp(p_signrank_MCAO);
end

if p_time_PT < 0.05 
p_signrank_PT = zeros(3,3); %(6,3) possible combinations or (3,3) if day 1 vs. others
j = 1; 
for dx = 1%:3 %first comparison day
group_dx_PT = y(A == 1 & B == dx);
for dnext = dx+1:4 %second comparison day
group_dnext_PT = y(A == 1 & B == dnext);
p_signrank_PT(j,3) = signrank(group_dx_PT,group_dnext_PT);
p_signrank_PT(j,1) = dx; p_signrank_PT(j,2) = dnext;
j = j+1; 
end
end
disp('Time PT:'); disp(p_signrank_PT);
end

end

%for between-groups, use Wilcoxon rank sum test (eq. Mann-Whitney test) -> independent measurements (between groups, on a single day)
if p_grouptime < 0.05
p_ranksum = zeros(1,4);
for dx = 1:4 %test individually for all four days
MCAO_dx = y(A == 0 & B == dx); PT_dx = y(A == 1 & B == dx); %A is group: MCAO 0 and PT 1; B is chosen day
p_ranksum(dx) = ranksum(MCAO_dx,PT_dx);
end
disp('Difference between groups:'); disp(p_ranksum)
end

%end posthoc/statistics

%individual significance stars (p_signrank_MCAO,p_signrank_PT,p_ranksum)
if exist('p_signrank_MCAO','var')
for v = 1:length(p_signrank_MCAO)
if p_signrank_MCAO(v,3) < 0.05, sigstar([p_signrank_MCAO(v,1),p_signrank_MCAO(v,2)],p_signrank_MCAO(v,3)); end
end
end

if exist('p_signrank_PT','var')
for w = 1:length(p_signrank_PT)
if p_signrank_PT(w,3) < 0.05, sigstar([p_signrank_PT(w,1)+4,p_signrank_PT(w,2)+4],p_signrank_PT(w,3)); end
end
end

% if exist('p_ranksum','var') %across groups, not displayed
% for c = 1:length(p_ranksum)
% if p_ranksum(c) < 0.05, sigstar([c,c+4],p_ranksum(c)); end
% end
% end

%if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf -append; end
end

%NEW 19/04/2023: horizontal plots of highest factor loadings
for side = 1:2
switch side
case 1
my_coeff = coeff_R; 
[c1,c1pos] = sortrows(my_coeff(:,1)); c1([25 26],1) = c1([26 25],1); c1 = [c1(1:5);c1(end-4:end)]; %include slip count
c1_names = {'a^{Average}_{Retraction}';'k^{Coefficient}_{Success}';'%^{MaxSpeed}_{Reach}';'a^{Average}_{Cycle}';...
'n^{Pellet}_{Events}';'n^{Slip}_{Events}';'t^{Duration}_{Cycle}';'n^{Success}_{Events}';...
'%^{MaxAcc}_{Reach}';'a^{Onset}_{Retraction}'};
figure('Position',[400 500 current_size],'Color','w'); hold on; 
case 2
my_coeff = coeff_L;
[c1,c1pos] = sortrows(my_coeff(:,1)); c1 = [c1(1:5);c1(end-4:end)]; 
c1_names = {'a^{Average}_{Cycle}';'d^{Path}_{Reach}';'v^{Onset}_{Retraction}';'v^{Average}_{Cycle}';...
'%^{MaxAcc}_{Cycle}';'a^{Onset}_{Retraction}';'a^{Average}_{Retraction}';'a^{Onset}_{Reach}';
't^{Duration}_{Cycle}';'v^{Average}_{Retraction}'};
figure('Position',[1000 500 current_size],'Color','w'); hold on;
end
% c1_names = varnames(c1pos)'; c1_names([25 26],1) = c1_names([26 25],1); c1_names = [c1_names(1:5);c1_names(end-4:end)]; %if c1_names not defined

horbar = barh(c1,'BaseValue',0,'FaceColor',hex2rgb('#A7A7A7'),'FaceAlpha',bar_alpha);

%write variable names
x_R = [0.07 0.07 0.07 0.07 0.07 -1 -1.15 -1.1 -1.15 -1.38]; x_L = [0.07 0.07 0.07 0.07 0.07 -1.85 -1.85 -1.25 -1.6 -1.85]; 
for barnr = 1:length(horbar.YData)
if side == 1
text(x_R(barnr),barnr,strcat('{\it',c1_names(barnr),'}'),'FontSize',ticks_font,'FontWeight','bold'); %'_{',my_hands(barnr),'}' %0.05 -0.25
elseif side == 2
text(x_L(barnr),barnr,strcat('{\it',c1_names(barnr),'}'),'FontSize',ticks_font,'FontWeight','bold')
end
end

%horizontal bar style
my_yticks = yticks; yticks([]); %yticks(my_yticks(2:2:end));
my_xticks = xticks; %xticks([-0.9 -0.6 -0.3 0 0.3 0.6 0.9]); xlim([-1 1]) %xticks(my_xticks(1:2:end)); 
if side == 1, xlim([-2.5 2.7]); title('CL Hand'); else, xlim([-3 4]); title('IL Hand'); end
ax = gca; ax.XAxis.FontSize = ticks_font;
ylabel('Parameters','FontSize',axes_font); xlabel('Factor loadings (LD1)','FontSize',axes_font);

end

if yes_export == 2
my_figures = findobj('Type','Figure');
for f = 1:length(my_figures)
n = my_figures(f).Number;
switch n
case 11, figname = "IL_factors";
case 10, figname = "CL_factors";
case 9, figname = "CL_PC3";
case 8, figname = "CL_PC2"; %IL_PC2
case 7, figname = "CL_PC1"; %IL_PC1
case 6, figname = "IL_loadings_hor";
case 5, figname = "CL_loadings_hor";
case 4, figname = "IL_loadings";
case 3, figname = "CL_loadings";
case 2, figname = "IL_scores";
case 1, figname = "CL_scores";
end

print(my_figures(f),strcat('/home/nikolaus/Desktop/Matlab_Scripts/Plots/',figname), '-dsvg')
end
end