%spss-tutorials.com/spss-kolmogorov-smirnov-test-for-normality/
%spss-tutorials.com/kruskal-wallis-test/

clear
close all
yes_export = 0; %export_fig -append

M_summary = readtable(''); M_summary(M_summary.Mouse == 34,:) = [];
PT_summary = readtable(''); %summary table
M_summary(:,{'SlipDepth','SlipTime','GrabDepth','GrabTime'}) = fillmissing(M_summary(:,{'SlipDepth','SlipTime','GrabDepth','GrabTime'}),'constant',0);
PT_summary(:,{'SlipDepth','SlipTime','GrabDepth','GrabTime'}) = fillmissing(PT_summary(:,{'SlipDepth','SlipTime','GrabDepth','GrabTime'}),'constant',0);

%NEW: 19/04/2023 traditional score
trad_M = readtable(''); trad_M = sortrows(trad_M,["Day","Mouse","Hand"]); trad_M(trad_M.Mouse == 34,:) = [];
trad_PT = readtable(''); trad_PT = sortrows(trad_PT,["Day","Mouse","Hand"]);
M_summary.Traditional = trad_M.GroupCount; PT_summary.Traditional = trad_PT.GroupCount;

%variable name change
oldnames = {'mean_TotalDur','mean_FlexDur','mean_ExtDur','mean_FlexDurPer','mean_ExtDurPer','mean_PathLen','mean_ReachDist','mean_AvgSpeedTotal','mean_AvgSpeedFlex','mean_AvgSpeedExt',...
'mean_MaxSpeedTotal','mean_MaxSpeedFlex','mean_MaxSpeedExt','mean_AvgAccTotal','mean_AvgAccFlex','mean_AvgAccExt','mean_MaxAccTotal','mean_MaxAccFlex','mean_MaxAccExt',...
'mean_AvgDecTotal','mean_AvgDecFlex','mean_AvgDecExt', 'mean_MaxDecTotal','mean_MaxDecFlex','mean_MaxDecExt','mean_T_MaxSpeedTotal','mean_T_MaxSpeedFlex','mean_T_MaxSpeedExt',...
'mean_T_MaxAccTotal','mean_T_MaxAccFlex','mean_T_MaxAccExt','mean_T_MaxDecTotal','mean_T_MaxDecFlex','mean_T_MaxDecExt','mean_TPerc_MaxSpeedTotal','mean_TPerc_MaxSpeedFlex',...
'mean_TPerc_MaxSpeedExt','mean_TPerc_MaxAccTotal','mean_TPerc_MaxAccFlex','mean_T_PercMaxAccExt','mean_TPerc_MaxDecTotal','mean_TPerc_MaxDecFlex','mean_TPerc_MaxDecExt',...
'mean_OnsetSpeedFlex','mean_OnsetSpeedExt','mean_OnsetAccFlex','mean_OnsetAccExt','mean_OnsetDecFlex','mean_OnsetDecExt','SuccessRatio','SuccessEvents','ReachesCount',...
'PelletsCount','SlipsCount','SlipDepth','SlipTime','GrabDepth','GrabTime','Traditional'};

varnames = {'Duration [s]','Reach Duration [s]','Retraction Duration [s]','Reach Fraction [%]','Retraction Fraction [%]','Path Length [cm]','Reach Distance[cm]',...
'Speed [cm/s]','Reach Speed [cm/s]','Retraction Speed [cm/s]','Maximal Speed [cm/s]','Reach Maximal Speed [cm/s]','Retraction Maximal Speed [cm/s]',...
'Acceleration [cm/s^{2}]','Reach Acceleration [cm/s^{2}]','Retraction Acceleration [cm/s^{2}]','Maximal Acceleration [cm/s^{2}]',...
'Reach Maximal Acceleration [cm/s^{2}]','Retraction Maximal Acceleration [cm/s^{2}]','Deceleration [cm/s^{2}]','Reach Deceleration [cm/s^{2}]',...
'Retraction Deceleration [cm/s^{2}]', 'Maximal Deceleration [cm/s^{2}]', 'Reach Maximal Deceleration [cm/s^{2}]', 'Retraction Maximal Deceleration [cm/s^{2}]',...
'Maximal Speed Time [s]','Reach Maximal Speed Time [s]','Retraction Maximal Speed Time [s]','Maximal Acceleration Time [s]', 'Reach Maximal Acceleration Time [s]',...
'Retraction Maximal Acceleration Time [s]','Maximal Deceleration Time [s]','Reach Maximal Deceleration Time [s]','Retraction Maximal Deceleration Time [s]',...
'Maximal Speed Fraction[%]','Reach Maximal Speed Fraction [%]','Retraction Maximal Speed Fraction [%]','Maximal Acceleration Fraction [%]','Reach Maximal Acceleration Fraction [%]',...
'Retraction Maximal Acceleration Fraction [%]','Maximal Deceleration Fraction [%]', 'Reach Maximal Deceleration Fraction [%]','Retraction Maximal Deceleration Fraction [%]',...
'Reach Onset Speed [cm/s]', 'Retraction Onset Speed [cm/s]','Reach Onset Acceleration [cm/s^{2}]','Retraction Onset Acceleration [cm/s^{2}]','Reach Onset Deceleration [cm/s^{2}]',...
'Retraction Onset Deceleration [cm/s^{2}]','Success Coefficient', 'Success Events', 'Reach Count','Pellet Count','Slip Count','Slip Depth [cm]','Slip Time [s]','Grab Depth [cm]','Grab Time [s]','Traditional Score'};

hands = ['R','L'];
lesion = {'MCAO','PT'};

%individual scattering variables for scatter plots
M_scattering_variable = 0.4*rand(size(M_summary(strcmp(M_summary.Hand,'R'),:),1),1)-0.2; %equivalent to the number of entries for each hand
PT_scattering_variable = 0.4*rand(size(PT_summary(strcmp(PT_summary.Hand,'R'),:),1),1)-0.2;

%plot parameters
M_bcolor = '#1A85FF'; PT_bcolor = '#c20064'; S_bcolor = "#A7A7A7";
eb_linewidth = 2; eb_linestyle1 = '-'; eb_linestyle2 = '-';
ticks_font = 8; axes_font = 10; marker_size = 13; marker_line = 1.5; bar_alpha = 0.4; %80

%figure parameters
publication_size = [300 220];
current_size = publication_size;

chosen_plots = [48 49 19 51 6 7 13];

for i = 5:size(M_summary,2) %run across variables

if ~ismember(i,chosen_plots), continue; end

for j = 1%1:2
pause(1)

hand_side = hands(j);

clear h pks p tbl stats results gnames p_signrank_MCAO p_signrank_PT

col_name = M_summary.Properties.VariableNames(i); 
variable1 = [M_summary.Day(strcmp(M_summary.Hand,hand_side)) M_summary{(strcmp(M_summary.Hand,hand_side)),col_name}]; %intervention
variable2 = [PT_summary.Day(strcmp(PT_summary.Hand,hand_side)) PT_summary{(strcmp(PT_summary.Hand,hand_side)),col_name}];

disp(col_name)
%test for normality across subpopulations
[h1,h2] = deal(zeros(4,1)); [pks1,pks2] = deal(zeros(4,1)); 
for day=1:4
[h1(day),pks1(day)] = kstest(variable1(variable1(:,1) == day));
[h2(day),pks2(day)] = kstest(variable2(variable2(:,1) == day));
end
test_pks = [pks1 pks2] > 0.05; if all(test_pks), disp('Normal distribution. Use a parametric test!'); end

% %non-parametric test for 3+ groups followed by individual comparison
% [p1,tbl1,stats1] = kruskalwallis(variable1(:,2),variable1(:,1),'off'); %'Display','off'
% [p2,tbl2,stats2] = kruskalwallis(variable2(:,2),variable2(:,1),'off');
% if p1 < 0.05, [results1,~,~,gnames1] = multcompare(stats1,'CType','bonferroni','Display','off'); end
% if p2 < 0.05, [results2,~,~,gnames2] = multcompare(stats2,'CType','bonferroni','Display','off'); end

%SPM1D non-parametric 2-way RM-ANOVA (comparison between 2 datasets)
M_table = M_summary(strcmp(M_summary.Hand,hand_side),:); M_table = sortrows(M_table,{'Mouse'}); M_table.Mouse = M_table.Mouse+10; %mice get different IDs
PT_table = PT_summary(strcmp(PT_summary.Hand,hand_side),:); PT_table = sortrows(PT_table,{'Mouse'}); %assume a certain shape

y = [M_table{:,col_name}; PT_table{:,col_name}];
A = [zeros(size(M_table,1),1); ones(size(PT_table,1),1)]; %group
B = [M_table.Day; PT_table.Day]; %time
SUBJ = [M_table.Mouse; PT_table.Mouse]; %subjects

%Conduct a non-parametric test
rng(0)
alpha      = 0.05;
iterations = 1500; %1500
FFn        = spm1d.stats.nonparam.anova2onerm(y, A, B, SUBJ);
FFni       = FFn.inference(alpha, 'iterations', iterations);
fprintf('NON-PARAMETRIC RESULTS\n')
disp_summ(FFni)

%ex_anova2onerm.m, nonparametric example -> two way RM Anova
%https://spm1d.org/doc/Stats1D/anova.html#two-way-repeated-measures-anova
%https://github.com/0todd0000/spm1d
%https://www.youtube.com/watch?v=CE4dhRLCVMI

p_group = FFni.SPMs{1}.p; p_time = FFni.SPMs{2}.p; p_grouptime = FFni.SPMs{3}.p;
p = p_grouptime; %if interaction effect grouptime significant, will perform individual pairwise tests

%POSTHOC tests between two measurements: https://www.youtube.com/watch?v=Tv8dsRjz9KM
%perform posthoc between individual cell-means only if the group:time interaction effect is significant:
%restrict testing to between-groups on a single day or to a time comparison but within one group
%time main effects allows for a posthoc comparison of time-dependent marginal means (not time effects for PT and MCAO individually!)
%group main effect significant doesn't lead to any posthoc tests since there's only one mean per group (result would be the same)

%if no significant interaction effect, but significant main effect(s): run one-way statistics model of that factor
%i.e. if time effect significant, run one-way NP ANOVA for every individual group (MCAO and PT)
%https://www.datanovia.com/en/lessons/repeated-measures-anova-in-r/#post-hoc-tests-1
if p_grouptime > 0.05 && p_time < 0.05
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
j = 1; %#ok<FXSET>
for dx = 1%:3 %first comparison day
group_dx_MCAO = y(A == 0 & B == dx);
for dnext = dx+1:4 %second comparison day
group_dnext_MCAO = y(A == 0 & B == dnext);
p_signrank_MCAO(j,3) = signrank(group_dx_MCAO,group_dnext_MCAO);
p_signrank_MCAO(j,1) = dx; p_signrank_MCAO(j,2) = dnext;
j = j+1; %#ok<FXSET>
end
end
disp('Time MCAO:'); disp(p_signrank_MCAO);
end

if p_time_PT < 0.05 
p_signrank_PT = zeros(3,3); %(6,3) possible combinations or (3,3) if day 1 vs. others
j = 1; %#ok<FXSET>
for dx = 1%:3 %first comparison day
group_dx_PT = y(A == 1 & B == dx);
for dnext = dx+1:4 %second comparison day
group_dnext_PT = y(A == 1 & B == dnext);
p_signrank_PT(j,3) = signrank(group_dx_PT,group_dnext_PT);
p_signrank_PT(j,1) = dx; p_signrank_PT(j,2) = dnext;
j = j+1; %#ok<FXSET>
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

%END statistics

%continue

%LINE PLOT
figure('Position',[400 1000 current_size],'Color','w'); hold on;
bcolor1 = M_bcolor; scattering_variable1 = M_scattering_variable;
bcolor2 = PT_bcolor; scattering_variable2 = PT_scattering_variable;

%intervention setting 1 (plot lines over scatter)
mean_var1 = [mean(variable1(variable1(:,1) == 1, 2),'omitnan')...
mean(variable1(variable1(:,1) == 2, 2),'omitnan')...
mean(variable1(variable1(:,1) == 3, 2),'omitnan')...
mean(variable1(variable1(:,1) == 4, 2),'omitnan')];
sem_var1 = [std(variable1(variable1(:,1) == 1, 2),'omitnan')/sqrt(length(variable1(variable1(:,1) == 1, 2)))...
std(variable1(variable1(:,1) == 2, 2),'omitnan')/sqrt(length(variable1(variable1(:,1) == 2, 2)))...
std(variable1(variable1(:,1) == 3, 2),'omitnan')/sqrt(length(variable1(variable1(:,1) == 3, 2)))...
std(variable1(variable1(:,1) == 4, 2),'omitnan')/sqrt(length(variable1(variable1(:,1) == 4, 2)))];

current_errorbar1 = errorbar([1 2 3 4],mean_var1,sem_var1,'Color',bcolor1,'LineWidth',eb_linewidth,'LineStyle',eb_linestyle1);

%intervention setting 2 (plot over control)
mean_var2 = [mean(variable2(variable2(:,1) == 1, 2),'omitnan')...
mean(variable2(variable2(:,1) == 2, 2),'omitnan')...
mean(variable2(variable2(:,1) == 3, 2),'omitnan')...
mean(variable2(variable2(:,1) == 4, 2),'omitnan')];
sem_var2 = [std(variable2(variable2(:,1) == 1, 2),'omitnan')/sqrt(length(variable2(variable2(:,1) == 1, 2)))...
std(variable2(variable2(:,1) == 2, 2),'omitnan')/sqrt(length(variable2(variable2(:,1) == 2, 2)))...
std(variable2(variable2(:,1) == 3, 2),'omitnan')/sqrt(length(variable2(variable2(:,1) == 3, 2)))...
std(variable2(variable2(:,1) == 4, 2),'omitnan')/sqrt(length(variable2(variable2(:,1) == 4, 2)))];

current_errorbar2 = errorbar([1 2 3 4],mean_var2,sem_var2,'Color',bcolor2,'LineWidth',eb_linewidth,'LineStyle',eb_linestyle2);

old_ylim = ylim; ax = gca; ax.FontSize = ticks_font; ylim(old_ylim); %xline(1.2); %old_ylim currently redundant due to move
[~,where] = ismember(col_name,oldnames); ylabel(varnames(where),'FontSize',axes_font);
xlabel('Days','FontSize',axes_font); xticks([1 2 3 4]); xlim([0.5 4.5]); xticklabels({'-4','7','14','21'});
xlm = xlim; ylm = ylim; x_offset = 0.015*(xlm(2)-xlm(1)); y_offset = 0.045*(ylm(2)-ylm(1));
current_gca1 = gca; current_gcf1 = gcf;

%plot significance
% if p < 0.05
% text(ax,xlm(1)+x_offset,ylm(1)+y_offset,strcat('p = ',string(round(p,4))),'FontSize',ticks_font,'FontWeight','bold');
% end

%BOX PLOT
figure('Position',[1000 1000 current_size],'Color','w'); hold on;

% my_boxplot = boxplot([RSD_summary_M{chosen_row,5:53} RSD_summary_PT{chosen_row,5:53} RSD_summary_S{chosen_row,5:53}]*100,[ones(1,49) 2*ones(1,49) 3*ones(1,49)],...
% 'BoxStyle','outline','Colors',[hex2rgb(M_bcolor);hex2rgb(PT_bcolor);hex2rgb(S_bcolor)]);

var1_ones = ones(length(variable1(variable1(:,1) == 1, 1)),1); var2_ones = ones(length(variable2(variable2(:,1) == 1, 1)),1);

% my_boxplot = boxplot([variable1(variable1(:,1) == 1, 2); variable2(variable2(:,1) == 1, 2);... %values
% variable1(variable1(:,1) == 2, 2); variable2(variable2(:,1) == 2, 2);...
% variable1(variable1(:,1) == 3, 2); variable2(variable2(:,1) == 3, 2);...
% variable1(variable1(:,1) == 4, 2); variable2(variable2(:,1) == 4, 2)],...
% [1*var1_ones; 2*var2_ones; 3*var1_ones; 4*var2_ones; 5*var1_ones; 6*var2_ones; 7*var1_ones; 8*var2_ones],... %groups 
% 'BoxStyle','outline','Colors',[hex2rgb(M_bcolor);hex2rgb(PT_bcolor);hex2rgb(M_bcolor);hex2rgb(PT_bcolor);hex2rgb(M_bcolor);hex2rgb(PT_bcolor);hex2rgb(M_bcolor);hex2rgb(PT_bcolor)]);

my_boxplot = boxplot([variable1(variable1(:,1) == 1, 2); variable1(variable1(:,1) == 2, 2);...
variable1(variable1(:,1) == 3, 2); variable1(variable1(:,1) == 4, 2);... %values
NaN; ... %dummy to make distance in plot between the groups
variable2(variable2(:,1) == 1, 2); variable2(variable2(:,1) == 2, 2);...
variable2(variable2(:,1) == 3, 2); variable2(variable2(:,1) == 4, 2)],...
[1*var1_ones; 2*var1_ones; 3*var1_ones; 4*var1_ones; 5; 6*var2_ones; 7*var2_ones; 8*var2_ones; 9*var2_ones],... %groups 
'BoxStyle','outline','Colors',[hex2rgb(M_bcolor);hex2rgb(M_bcolor);hex2rgb(M_bcolor);hex2rgb(M_bcolor);[1 1 1];hex2rgb(PT_bcolor);hex2rgb(PT_bcolor);hex2rgb(PT_bcolor);hex2rgb(PT_bcolor)]);

%change box layout
h = findobj(gca,'Tag','Box'); m = findobj(gca,'Tag','Median'); uw = findobj(gca,'Tag','Upper Whisker'); o = findobj(gca,'Tag','Outliers');
lw = findobj(gca,'Tag','Lower Whisker'); uav = findobj(gca,'Tag','Upper Adjacent Value'); lav = findobj(gca,'Tag','Lower Adjacent Value');
for b = 1:length(h)
%if b == 5, patch(get(h(b),'XData'),get(h(b),'YData'),[1 1 1],'FaceAlpha',1,'LineWidth',1,'EdgeColor',[1 1 1]); continue; end %separation
%if rem(b,2) == 0, chosen_col = M_bcolor; else, chosen_col = PT_bcolor; end
if b > 4, chosen_col = M_bcolor; else, chosen_col = PT_bcolor; end %reversed
patch(get(h(b),'XData'),get(h(b),'YData'),hex2rgb(chosen_col),'FaceAlpha',bar_alpha,'LineWidth',1); %h(b).LineWidth = eb_linewidth;

line(m(b).XData,m(b).YData,'LineWidth',2,'Color','k');
uw(b).LineWidth = 1.5; lw(b).LineWidth = 1.5; uav(b).LineWidth = 1.5; lav(b).LineWidth = 1.5;
uw(b).LineStyle = '-'; lw(b).LineStyle = '-'; o(b).Marker = 'none';
end

%plot dots
% scatter([1*var1_ones; 3*var1_ones; 5*var1_ones; 7*var1_ones]+scattering_variable1, variable1(:,2),marker_size,'o','MarkerEdgeColor',bcolor1,'LineWidth',marker_line); %intervention 1
% scatter([2*var2_ones; 4*var2_ones; 6*var2_ones; 8*var2_ones]+scattering_variable2, variable2(:,2),marker_size,'o','MarkerEdgeColor',bcolor2,'LineWidth',marker_line); %intervention 2
scatter([1*var1_ones; 2*var1_ones; 3*var1_ones; 4*var1_ones]+scattering_variable1, variable1(:,2),marker_size,'o','MarkerEdgeColor',bcolor1,'LineWidth',marker_line); %intervention 1
scatter([6*var2_ones; 7*var2_ones; 8*var2_ones; 9*var2_ones]+scattering_variable2, variable2(:,2),marker_size,'o','MarkerEdgeColor',bcolor2,'LineWidth',marker_line); %intervention 2

ax = gca; ax.FontSize = ticks_font; set(gca,'box','off');
xlabel({'Days'},'FontSize',axes_font);
%xticklabels({'MCAO D -4','PT D -4','MCAO D7','PT D7','MCAO D14','PT D14','MCAO D21','PT D21'}); xtickangle(45); 
xticks([1 2 3 4 6 7 8 9]); xticklabels({'pre','7','14','21','pre','7','14','21'}); %xticks([1.5 3.5 5.5 7.5]); xticklabels({'-4','7','14','21'});
ylabel('Coefficient of Variation','FontSize',axes_font); ylabel(varnames(where),'FontSize',axes_font);
current_gca2 = gca; current_gcf2 = gcf; %xlm = xlim; ylm = ylim;

%plot layout (won't equalize axes bc of not displaying line plots)
if current_gca1.YLim(1) < current_gca2.YLim(1), current_gca2.YLim(1) = current_gca1.YLim(1); else, current_gca1.YLim(1) = current_gca2.YLim(1); end
if current_gca1.YLim(2) > current_gca2.YLim(2), current_gca2.YLim(2) = current_gca1.YLim(2); else, current_gca1.YLim(2) = current_gca2.YLim(2); end

my_yticks = current_gca2.YTick; divider = ceil(length(my_yticks)/4); %find the division factor of denominator 4 and lower it to first full integer
idx_yticks = 1:divider:length(my_yticks); current_gca1.YTick = my_yticks(idx_yticks); current_gca2.YTick = my_yticks(idx_yticks); %use that integer to divide the y-axis


%plot significance
% if p < 0.05
% if strcmp(col_name,'SlipsCount') || strcmp(col_name,'mean_MaxDecTotal') || strcmp(col_name,'mean_TPerc_MaxDecExt') || strcmp(col_name,'mean_TotalDur') || strcmp(col_name,'mean_OnsetSpeedFlex')
% text(ax,xlm(2)+-16*x_offset,ylm(1)+y_offset,strcat('p = ',string(round(p,4))),'FontSize',ticks_font,'FontWeight','bold');
% else
% text(ax,xlm(1)+x_offset,ylm(1)+y_offset,strcat('p = ',string(round(p,4))),'FontSize',ticks_font,'FontWeight','bold');
% end
% end

%adjust significance position on first plot (in case axes moved)
% if t == 2
% p_text = findobj(current_gca1,'Type','Text');
% if ~isempty(p_text)
% p_text(end).Position = [xlm(1)+x_offset ylm(1)+y_offset 0];
% end
% end

%individual significance stars (p_signrank_MCAO,p_signrank_PT,p_ranksum)
if exist('p_signrank_MCAO','var')
for v = 1:length(p_signrank_MCAO)
if p_signrank_MCAO(v,3) < 0.05, sigstar([p_signrank_MCAO(v,1),p_signrank_MCAO(v,2)],p_signrank_MCAO(v,3)); end
end
end

if exist('p_signrank_PT','var')
for w = 1:length(p_signrank_PT)
if p_signrank_PT(w,3) < 0.05, sigstar([p_signrank_PT(w,1)+5,p_signrank_PT(w,2)+5],p_signrank_PT(w,3)); end
end
end

% if exist('p_ranksum','var') %across groups, not displayed
% for c = 1:length(p_ranksum)
% if p_ranksum(c) < 0.05, sigstar([c,c+5],p_ranksum(c)); end
% end
% end

% if exist('results','var')
% for c = 1:size(results,1)
% if results(c,6) < 0.05
% sigstar([results(c,1),results(c,2)],results(c,6));
% end
% end
% end

end %end outer loops
end

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
figname = char(strrep(my_figures(f).Children.YLabel.String,' ','')); figname = figname(1:end-10);
if strcmp(my_figures(f).Children.Box,'on'), figname = strcat(figname,'_box'); else, figname = strcat(figname,'_box'); end %lines

print(my_figures(f),strcat('/home/nikolaus/Desktop/Matlab_Scripts/Plots/',figname), '-dsvg')
end
end

