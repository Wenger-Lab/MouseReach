clear
close all
yes_export = 1; %export_fig -append

%plot parameters
M_bcolor = '#1A85FF'; PT_bcolor = '#c20064'; S_bcolor = '#A7A7A7';
eb_linewidth = 2; eb_linestyle = '-';
ticks_font = 8; axes_font = 10; bar_alpha = 0.8;

%figure parameters
publication_size = [300 220]; %default size [330 220]
current_size = publication_size;

%define variables
M_mean = readtable(''); M_std = readtable(''); %respective summary tables with mean and std values
PT_mean = readtable(''); PT_std = readtable('');
S_mean = readtable(''); S_std = readtable('');

var_types = {'double','double','cell','double','double','double','double','double','double','double','double','double','double','double',...
'double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double', 'double', ...
'double','double','double','double','double','double','double','double','double','double','double', 'double','double','double','double','double','double','double','double','double'};
var_names = {'Day','Mouse','Hand','TotalDur','FlexDur','ExtDur','FlexDurPer','ExtDurPer','PathLen','ReachDist','AvgSpeedTotal','AvgSpeedFlex','AvgSpeedExt','MaxSpeedTotal','MaxSpeedFlex',...
'MaxSpeedExt', 'AvgAccTotal','AvgAccFlex', 'AvgAccExt','MaxAccTotal','MaxAccFlex','MaxAccExt','AvgDecTotal','AvgDecFlex','AvgDecExt', 'MaxDecTotal', 'MaxDecFlex', 'MaxDecExt',...
'T_MaxSpeedTotal','T_MaxSpeedFlex','T_MaxSpeedExt','T_MaxAccTotal', 'T_MaxAccFlex', 'T_MaxAccExt','T_MaxDecTotal', 'T_MaxDecFlex', 'T_MaxDecExt',...
'TPerc_MaxSpeedTotal','TPerc_MaxSpeedFlex','TPerc_MaxSpeedExt','TPerc_MaxAccTotal', 'TPerc_MaxAccFlex', 'T_PercMaxAccExt','TPerc_MaxDecTotal', 'TPerc_MaxDecFlex',...
'TPerc_MaxDecExt','OnsetSpeedFlex', 'OnsetSpeedExt','OnsetAccFlex','OnsetAccExt','OnsetDecFlex', 'OnsetDecExt'};

M_var_table = deal(table('Size',[size(M_mean,1),52],'VariableTypes',var_types,'VariableNames',var_names));
PT_var_table = deal(table('Size',[size(PT_mean,1),52],'VariableTypes',var_types,'VariableNames',var_names));
S_var_table = deal(table('Size',[size(S_mean,1),52],'VariableTypes',var_types,'VariableNames',var_names));

M_mean = M_mean(:,1:53); M_std = M_std(:,1:53); PT_mean = PT_mean(:,1:53); PT_std = PT_std(:,1:53); S_mean = S_mean(:,1:53); S_std = S_std(:,1:53);

%calculate coefficient of variation (RSD = SD/|mean|) of all kinematic parameters
M_var_table(:,1:3) = M_mean(:,1:3); M_var_table(:,4:52) = array2table(abs(M_std{:,5:53}./M_mean{:,5:53})); %variability tables
PT_var_table(:,1:3) = PT_mean(:,1:3); PT_var_table(:,4:52) = array2table(abs(PT_std{:,5:53}./PT_mean{:,5:53}));
S_var_table(:,1:3) = S_mean(:,1:3); S_var_table(:,4:52) = array2table(abs(S_std{:,5:53}./S_mean{:,5:53}));

%compute mean variable RSD
RSD_summary_M = groupsummary(M_var_table,["Day","Hand"],"mean");
RSD_summary_PT = groupsummary(PT_var_table,["Day","Hand"],"mean"); 
RSD_summary_S = groupsummary(S_var_table,["Day","Hand"],"mean"); 

RSD_mean_M = mean(table2array(RSD_summary_M(:,5:end)),2); RSD_std_M = std(table2array(RSD_summary_M(:,5:end)),0,2); RSD_sem_M = RSD_std_M/sqrt(49); %49 variables
RSD_mean_PT = mean(table2array(RSD_summary_PT(:,5:end)),2); RSD_std_PT = std(table2array(RSD_summary_PT(:,5:end)),0,2); RSD_sem_PT = RSD_std_PT/sqrt(49);
RSD_mean_S = mean(table2array(RSD_summary_S(:,5:end)),2); RSD_std_S = std(table2array(RSD_summary_S(:,5:end)),0,2); RSD_sem_S = RSD_std_S/sqrt(49);

for chosen_row = 3:4 %day 7, left or right hand

if chosen_row == 3, figure('Position',[400 1000 current_size],'Color','w'); elseif chosen_row == 4, figure('Position',[1000 1000 current_size],'Color','w'); end
my_boxplot = boxplot([RSD_summary_M{chosen_row,5:53} RSD_summary_PT{chosen_row,5:53} RSD_summary_S{chosen_row,5:53}]*100,[ones(1,49) 2*ones(1,49) 3*ones(1,49)],...
'BoxStyle','outline','Colors',[hex2rgb(M_bcolor);hex2rgb(PT_bcolor);hex2rgb(S_bcolor)]);
[p,tbl,stats] = kruskalwallis([RSD_summary_M{chosen_row,5:53} RSD_summary_PT{chosen_row,5:53} RSD_summary_S{chosen_row,5:53}],[ones(1,49) 2*ones(1,49) 3*ones(1,49)],'off');

ax = gca; ax.FontSize = ticks_font;
if chosen_row == 3, title('Acute stroke: Ipsilesional hand','FontSize',axes_font), elseif chosen_row == 4, title('Acute stroke: Contralesional hand','FontSize',axes_font); end
xlabel({'Groups'},'FontSize',axes_font); xticks([1 2 3]); xlim([0 4]); xticklabels({'MCAO','PT','Sham'}); ylim([10 90]); %Day 7
yticks([20 40 60 80]); ytickformat('percentage'); xtickangle(45); ylabel('Coefficient of Variation','FontSize',axes_font); 
xlm = xlim; ylm = ylim; x_offset = 0.015*(xlm(2)-xlm(1)); y_offset = 0.045*(ylm(2)-ylm(1));

%fill in boxes
h = findobj(gca,'Tag','Box');
patch(get(h(1),'XData'),get(h(1),'YData'),hex2rgb(S_bcolor),'FaceAlpha',bar_alpha); h(1).LineWidth = 2;
patch(get(h(2),'XData'),get(h(2),'YData'),hex2rgb(PT_bcolor),'FaceAlpha',bar_alpha); h(2).LineWidth = 2;
patch(get(h(3),'XData'),get(h(3),'YData'),hex2rgb(M_bcolor),'FaceAlpha',bar_alpha); h(3).LineWidth = 2;

%change specific line width
m = findobj(gca,'Tag','Median');
line(m(1).XData,m(1).YData,'LineWidth',3,'Color','k'); line(m(2).XData,m(2).YData,'LineWidth',3,'Color','k'); line(m(3).XData,m(3).YData,'LineWidth',3,'Color','k');

uw = findobj(gca,'Tag','Upper Whisker');
uw(1).LineWidth = 1.5; uw(2).LineWidth = 1.5; uw(3).LineWidth = 1.5;

lw = findobj(gca,'Tag','Lower Whisker');
lw(1).LineWidth = 1.5; lw(2).LineWidth = 1.5; lw(3).LineWidth = 1.5;

uav = findobj(gca,'Tag','Upper Adjacent Value');
uav(1).LineWidth = 1.5; uav(2).LineWidth = 1.5; uav(3).LineWidth = 1.5;

lav = findobj(gca,'Tag','Lower Adjacent Value');
lav(1).LineWidth = 1.5; lav(2).LineWidth = 1.5; lav(3).LineWidth = 1.5;

if p < 0.05, text(ax,xlm(1)+x_offset,ylm(1)+y_offset,strcat('p = ',string(p)),'FontSize',ticks_font,'FontWeight','bold'); end

end

if yes_export == 1
my_figures = findobj('Type','Figure');
for f = 1:length(my_figures)
export_fig(my_figures(f),'/home/nikolaus/Desktop/Matlab_Scripts/Plots/plots','-pdf','-append')
end
end

return

%variable name change
old_names = var_names(4:end);
new_names = {'Total Duration','Reach Duration','Retraction Duration','Reach Duration [%]','Retraction Duration [%]','Path Length','Reach Distance','Total Average Speed',...
'Reach Average Speed','Retraction Average Speed','Total Max Speed','Reach Max Speed','Retraction Max Speed', 'Total Average Acceleration','Reach Average Acceleration',...
'Retraction Average Acceleration','Total Max Acceleration','Reach Max Acceleration','Retraction Max Acceleration','Total Average Deceleration','Reach Average Deceleration',...
'Retraction Average Deceleleration', 'Total Max Deceleration', 'Reach Max Deceleration', 'Retraction Max Deceleration','Total Max Speed [t]','Reach Max Speed [t]',...
'Retraction Max Speed [t]','Total Max Acceleration [t]', 'Reach Max Acceleration [t]', 'Retraction Max Acceleration [t]','Total Max Deceleration [t]','Reach Max Deceleration [t]',...
'Retraction Max Deceleration [t]','Total Max Speed [t%]','Reach Max Speed [t%]','Retraction Max Speed [t%]','Total Max Acceleration [t%]','Reach Max Acceleration [t%]',...
'Retraction Max Acceleration [t%]','Total Max Deceleration [t%]', 'Reach Max Deceleration [t%]','Retraction Max Deceleration [t%]','Reach Onset Speed', 'Retraction Onset Speed',...
'Reach Onset Acceleration','Retraction Onset Acceleration','Reach Onset Deceleration', 'Retraction Onset Deceleration'};

hands = ['R','L'];
lesion = {'M','PT','S'};

%individual scattering variables for scatter plots
M_scattering_variable = 0.4*rand(size(M_var_table(strcmp(M_var_table.Hand,'R'),:),1),1)-0.2; %equivalent to the number of entries for each hand
PT_scattering_variable = 0.4*rand(size(PT_var_table(strcmp(PT_var_table.Hand,'R'),:),1),1)-0.2;
S_scattering_variable = 0.4*rand(size(S_var_table(strcmp(S_var_table.Hand,'R'),:),1),1)-0.2;

chosen_plots = [10 18 21 24 25 30 51]; 
%RSD RIGHT HAND: 10=R.Dist,18=ReachAvgAcc,21=ReachMaxAcc,24=ReachAvgDecel,25=RetAvgDecel,30=ReachMaxSpeed[t],51=ReachOnsetDec
%param in figures; RIGHT: 10=R.Dist,18=ReachAvgAcc,30=ReachMaxSpeed[t],51=ReachOnsetDec


for i = 4:size(M_var_table,2) %run across variables

%if ~ismember(i,chosen_plots), continue; end

for t = 1:3%length(lesion) %separates MCAO, PT and Sham
type = lesion(t);

for j = 1%1:2
hand_side = hands(j);

clear h pks p tbl stats results gnames

if strcmp(type,'M')
col_name = M_var_table.Properties.VariableNames(i); 
variable = [M_var_table.Day(strcmp(M_var_table.Hand,hand_side)) M_var_table{(strcmp(M_var_table.Hand,hand_side)),col_name}];
elseif strcmp(type,'PT')
col_name = PT_var_table.Properties.VariableNames(i); 
variable = [PT_var_table.Day(strcmp(PT_var_table.Hand,hand_side)) PT_var_table{(strcmp(PT_var_table.Hand,hand_side)),col_name}];
elseif strcmp(type,'S')
col_name = S_var_table.Properties.VariableNames(i); 
variable = [S_var_table.Day(strcmp(S_var_table.Hand,hand_side)) S_var_table{(strcmp(S_var_table.Hand,hand_side)),col_name}];
end

disp(col_name)
%test for normality across subpopulations
h = zeros(4,1); pks = zeros(4,1);
for day=1:4
[h(day),pks(day)] = kstest(variable(variable(:,1) == day));
end
test_pks = pks > 0.05; if all(test_pks), disp('Normal distribution. Use a parametric test!'); end

%non-parametric test for 3+ groups followed by individual comparison
[p,tbl,stats] = kruskalwallis(variable(:,2),variable(:,1),'off'); %'Display','off'
if p < 0.05, [results,~,~,gnames] = multcompare(stats,'CType','bonferroni','Display','off'); end %figure

if strcmp(type,'M')
figure('Position',[400 1000 550 400],'Color','w'); bcolor = M_bcolor; scattering_variable = M_scattering_variable;
elseif strcmp(type,'PT')
figure('Position',[1000 1000 550 400],'Color','w'); bcolor = PT_bcolor; scattering_variable = PT_scattering_variable;
elseif strcmp(type,'S')
figure('Position',[700 100 550 400],'Color','w'); bcolor = S_bcolor; scattering_variable = S_scattering_variable;
end

hold on;
current_errorbar = errorbar([1 2 3 4],...
[mean(variable(variable(:,1) == 1, 2),'omitnan')...
mean(variable(variable(:,1) == 2, 2),'omitnan')...
mean(variable(variable(:,1) == 3, 2),'omitnan')...
mean(variable(variable(:,1) == 4, 2),'omitnan')],...
[std(variable(variable(:,1) == 1, 2),'omitnan')/sqrt(length(variable(variable(:,1) == 1, 2)))...
std(variable(variable(:,1) == 2, 2),'omitnan')/sqrt(length(variable(variable(:,1) == 2, 2)))...
std(variable(variable(:,1) == 3, 2),'omitnan')/sqrt(length(variable(variable(:,1) == 3, 2)))...
std(variable(variable(:,1) == 4, 2),'omitnan')/sqrt(length(variable(variable(:,1) == 4, 2)))],'Color',bcolor,'LineWidth',eb_linewidth,'LineStyle',eb_linestyle);

%plot dots
scatter(variable(:,1)+scattering_variable, variable(:,2),50,'.','MarkerEdgeColor',bcolor);

%plot layout
if t == 1 %equalize y axis (optional)
current_gca1 = gca; current_gcf1 = gcf; 
elseif t == 2
current_gca2 = gca;
if current_gca1.YLim(1) < current_gca2.YLim(1), current_gca2.YLim(1) = current_gca1.YLim(1); else, current_gca1.YLim(1) = current_gca2.YLim(1); end
if current_gca1.YLim(2) > current_gca2.YLim(2), current_gca2.YLim(2) = current_gca1.YLim(2); else, current_gca1.YLim(2) = current_gca2.YLim(2); end
current_gcf2 = gcf;

my_yticks = current_gca2.YTick; divider = floor(length(my_yticks)/4); %find the division factor of denominator 4 and lower it to first full integer
idx_yticks = 2:divider:length(my_yticks); current_gca1.YTick = my_yticks(idx_yticks); current_gca2.YTick = my_yticks(idx_yticks); %use that integer to divide the y-axis

elseif t == 3
current_gca3 = gca; current_gca3.YLim = current_gca2.YLim; current_gca3.YTick = current_gca2.YTick; current_gcf3 = gcf; %gcf needed for export_fig
end

ax = gca; ax.FontSize = ticks_font; %xline(1.2);
[~,where] = ismember(col_name,old_names); ylabel(new_names(where),'FontSize',axes_font);
xlabel('Days','FontSize',axes_font); xticks([1 2 3 4]); xlim([0.5 4.5]); xticklabels({'-4','7','14','21'});
title('RSD'); xlm = xlim; ylm = ylim; x_offset = 0.015*(xlm(2)-xlm(1)); y_offset = 0.035*(ylm(2)-ylm(1));

%plot significance
if p < 0.05
% if strcmp(col_name,'SlipsCount') || strcmp(col_name,'mean_MaxDecTotal') || strcmp(col_name,'mean_TPerc_MaxDecExt') || strcmp(col_name,'mean_TotalDur') || strcmp(col_name,'mean_OnsetSpeedFlex')
% text(ax,xlm(2)+-16*x_offset,ylm(1)+y_offset,strcat('p = ',string(p)),'FontSize',9,'FontWeight','bold');
% else
text(ax,xlm(1)+x_offset,ylm(1)+y_offset,strcat('p = ',string(p)),'FontSize',9,'FontWeight','bold');
% end
end

%adjust significance position on first plot (in case axes moved)
if t == 2
p_text = findobj(current_gca1,'Type','Text');
if ~isempty(p_text)
p_text(end).Position = [xlm(1)+x_offset ylm(1)+y_offset 0];
end
end

%individual significance star
if exist('results','var')
for c = 1:size(results,1)
if results(c,6) < 0.05
sigstar([results(c,1),results(c,2)],results(c,6));
end
end
end

% %export_fig
% if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf -append; end

%alternative export_fig for equalized y-axes
if t == 2 && yes_export == 1 %export both only when the MCAO and PT equalized their axes
export_fig(current_gcf1,'/home/nikolaus/Desktop/Matlab_Scripts/Plots/plots','-pdf','-append')
export_fig(current_gcf2,'/home/nikolaus/Desktop/Matlab_Scripts/Plots/plots','-pdf','-append')
end

end %end outer loops
end
end




