clear
close all
yes_export = 0;

hands = ['R','L'];
lesion = {'M','PT'};

%kinematic tables
M_summary = readtable(''); M_summary(M_summary.Mouse == 34,:) = [];
PT_summary = readtable(''); %summary
% M_summary(:,{'SlipDepth','SlipTime','GrabDepth','GrabTime'}) = fillmissing(M_summary(:,{'SlipDepth','SlipTime','GrabDepth','GrabTime'}),'constant',0);
% PT_summary(:,{'SlipDepth','SlipTime','GrabDepth','GrabTime'}) = fillmissing(PT_summary(:,{'SlipDepth','SlipTime','GrabDepth','GrabTime'}),'constant',0);

%NEW: 19/04/2023 traditional score
trad_M = readtable(''); trad_M = sortrows(trad_M,["Day","Mouse","Hand"]); trad_M(trad_M.Mouse == 34,:) = []; %table with traditional score
trad_PT = readtable(''); trad_PT = sortrows(trad_PT,["Day","Mouse","Hand"]);
M_summary.Traditional = trad_M.GroupCount; PT_summary.Traditional = trad_PT.GroupCount;

oldnames = {'mean_TotalDur','mean_FlexDur','mean_ExtDur','mean_FlexDurPer','mean_ExtDurPer','mean_PathLen','mean_ReachDist','mean_AvgSpeedTotal','mean_AvgSpeedFlex','mean_AvgSpeedExt',...
'mean_MaxSpeedTotal','mean_MaxSpeedFlex','mean_MaxSpeedExt','mean_AvgAccTotal','mean_AvgAccFlex','mean_AvgAccExt','mean_MaxAccTotal','mean_MaxAccFlex','mean_MaxAccExt',...
'mean_AvgDecTotal','mean_AvgDecFlex','mean_AvgDecExt', 'mean_MaxDecTotal','mean_MaxDecFlex','mean_MaxDecExt','mean_T_MaxSpeedTotal','mean_T_MaxSpeedFlex','mean_T_MaxSpeedExt',...
'mean_T_MaxAccTotal','mean_T_MaxAccFlex','mean_T_MaxAccExt','mean_T_MaxDecTotal','mean_T_MaxDecFlex','mean_T_MaxDecExt','mean_TPerc_MaxSpeedTotal','mean_TPerc_MaxSpeedFlex',...
'mean_TPerc_MaxSpeedExt','mean_TPerc_MaxAccTotal','mean_TPerc_MaxAccFlex','mean_T_PercMaxAccExt','mean_TPerc_MaxDecTotal','mean_TPerc_MaxDecFlex','mean_TPerc_MaxDecExt',...
'mean_OnsetSpeedFlex','mean_OnsetSpeedExt','mean_OnsetAccFlex','mean_OnsetAccExt','mean_OnsetDecFlex','mean_OnsetDecExt','SuccessRatio','SuccessEvents','ReachesCount',...
'PelletsCount','SlipsCount','SlipDepth','SlipTime','GrabDepth','GrabTime','Traditional'};

varnames = {'Duration [s]','Reach Duration [s]','Retraction Duration [s]','Reach Fraction [%]','Retraction Fraction [%]','Path Length [cm]','Reach Distance[cm]',...
'Average Speed [cm/s]','Reach Average Speed [cm/s]','Retraction Average Speed [cm/s]','Maximal Speed [cm/s]','Reach Maximal Speed [cm/s]','Retraction Maximal Speed [cm/s]',...
'Average Acceleration [cm/s^{2}]','Reach Average Acceleration [cm/s^{2}]','Retraction Average Acceleration [cm/s^{2}]','Maximal Acceleration [cm/s^{2}]',...
'Reach Maximal Acceleration [cm/s^{2}]','Retraction Maximal Acceleration [cm/s^{2}]','Average Deceleration [cm/s^{2}]','Reach Average Deceleration [cm/s^{2}]',...
'Retraction Average Deceleration [cm/s^{2}]', 'Maximal Deceleration [cm/s^{2}]', 'Reach Maximal Deceleration [cm/s^{2}]', 'Retraction Maximal Deceleration [cm/s^{2}]',...
'Maximal Speed Time [s]','Reach Maximal Speed Time [s]','Retraction Maximal Speed Time [s]','Maximal Acceleration Time [s]', 'Reach Maximal Acceleration Time [s]',...
'Retraction Maximal Acceleration Time [s]','Maximal Deceleration Time [s]','Reach Maximal Deceleration Time [s]','Retraction Maximal Deceleration Time [s]',...
'Maximal Speed Fraction[%]','Reach Maximal Speed Fraction [%]','Retraction Maximal Speed Fraction [%]','Maximal Acceleration Fraction [%]','Reach Maximal Acceleration Fraction [%]',...
'Retraction Maximal Acceleration Fraction [%]','Maximal Deceleration Fraction [%]', 'Reach Maximal Deceleration Fraction [%]','Retraction Maximal Deceleration Fraction [%]',...
'Reach Onset Speed [cm/s]', 'Retraction Onset Speed [cm/s]','Reach Onset Acceleration [cm/s^{2}]','Retraction Onset Acceleration [cm/s^{2}]','Reach Onset Deceleration [cm/s^{2}]',...
'Retraction Onset Deceleration [cm/s^{2}]','Success Coefficient', 'Success Events', 'Reach Count','Pellet Count','Slip Count','Slip Depth [cm]','Slip Time [s]','Grab Depth [cm]','Grab Time [s]','Traditional Score'};

areas = {'Mouse','SomatomotorAreas','SomatosensoryAreas','Striatum','Isocortex','PrimaryMotorArea','SecondaryMotorArea',...
'PrimarySomatosensoryAreaUpperLimb','fiberTracts','x_brainvol','x_maskvol'};

%M volume percentages
M_volumes = readtable(''); %volume table
M_volumes = rows2vars(M_volumes,'VariableNamesSource','Var1'); M_volumes.OriginalVariableNames = []; M_volumes.Properties.VariableNames(1) = {'Mouse'};
M_volumes = M_volumes(:,areas); M_volumes.Properties.VariableNames(end) = {'Total'}; %rename masked volume into total (stroke) volume
M_volumes.Properties.VariableNames(end-1) = {'Brain'}; %for calculating the residuum

M_volumes.SensorymotorAreas = sum([M_volumes.SomatomotorAreas,M_volumes.SomatosensoryAreas],2); %calculate percentage for the whole SM area
%M_volumes(:,2:end) = array2table(M_volumes{:,2:end}.*2); %correct values to one hemisphere only; NOT HERE, bc absolute volume
M_volumes = movevars(M_volumes,'SensorymotorAreas','Before','Brain');

M_volumes(M_volumes.Mouse == 34,:) = []; %exclude mouse 34 because no reaches

%PT volume percentages
PT_volumes = readtable(''); %total absolute volume
PT_volumes = rows2vars(PT_volumes,'VariableNamesSource','Var1'); PT_volumes.OriginalVariableNames = []; PT_volumes.Properties.VariableNames(1) = {'Mouse'};
PT_volumes = PT_volumes(:,areas); PT_volumes.Properties.VariableNames(end) = {'Total'}; %rename masked volume into total volume
PT_volumes.Properties.VariableNames(end-1) = {'Brain'}; %for calculating the residuum

PT_volumes.SensorymotorAreas = sum([PT_volumes.SomatomotorAreas,PT_volumes.SomatosensoryAreas],2); %calculate percentage for the whole SM area
%PT_volumes(:,2:end) = array2table(PT_volumes{:,2:end}.*2); %correct values to one hemisphere only; NOT HERE, bc absolute volume
PT_volumes = movevars(PT_volumes,'SensorymotorAreas','Before','Total');

%NEW: absolute volume references
volumes_ref = readtable(''); %volume reference table

% %sensorymotor and striatal stroke percentage
% PT_volumes.SMPerc = 100*PT_volumes.SensorymotorAreas./PT_volumes.Total; PT_volumes.STPerc = 100*PT_volumes.Striatum./PT_volumes.Total; %percentage of stroke in SM and Str
% M_volumes.SMPerc = 100*M_volumes.SensorymotorAreas./M_volumes.Total; M_volumes.STPerc = 100*M_volumes.Striatum./M_volumes.Total;
% %somatosensory and motor area (split) stroke percentage
% PT_volumes.SSPerc = 100*PT_volumes.SomatosensoryAreas./PT_volumes.Total; PT_volumes.MPerc = 100*PT_volumes.SomatomotorAreas./PT_volumes.Total;
% M_volumes.SSPerc = 100*M_volumes.SomatosensoryAreas./M_volumes.Total; M_volumes.MPerc = 100*M_volumes.SomatomotorAreas./M_volumes.Total;
% %primary sensory upper limb and primary motor area percentage
% PT_volumes.PSUPerc = 100*PT_volumes.PrimarySomatosensoryAreaUpperLimb./PT_volumes.Total; PT_volumes.PMAPerc = 100*PT_volumes.PrimaryMotorArea./PT_volumes.Total;
% M_volumes.PSUPerc = 100*M_volumes.PrimarySomatosensoryAreaUpperLimb./M_volumes.Total; M_volumes.PMAPerc = 100*M_volumes.PrimaryMotorArea./M_volumes.Total;
% %isocortex percentage and secondary motor area percentage
% PT_volumes.ICPerc = 100*PT_volumes.Isocortex./PT_volumes.Total; PT_volumes.SMAPerc = 100*PT_volumes.SecondaryMotorArea./PT_volumes.Total;
% M_volumes.ICPerc = 100*M_volumes.Isocortex./M_volumes.Total; M_volumes.SMAPerc = 100*M_volumes.SecondaryMotorArea./M_volumes.Total;
%NEW: residuum (absolute stroke volume in residuum divided by absolute reference volume of the residuum)
PT_volumes.ResPerc = 100*(PT_volumes.Total-(PT_volumes.Isocortex+PT_volumes.Striatum))./(volumes_ref.Brain-(volumes_ref.Isocortex+volumes_ref.Striatum));
M_volumes.ResPerc = 100*(M_volumes.Total-(M_volumes.Isocortex+M_volumes.Striatum))./(volumes_ref.Brain-(volumes_ref.Isocortex+volumes_ref.Striatum));
PT_volumes.ResPerc = PT_volumes.ResPerc*2; M_volumes.ResPerc = M_volumes.ResPerc*2; %correct to one hemisphere

%define variables 
M_vol = M_volumes.ResPerc;
%M_vol = M_volumes.Striatum;
PT_vol = PT_volumes.ResPerc; 
%PT_vol = PT_volumes.Striatum; 
M_vol_mean = mean(M_vol); PT_vol_mean = mean(PT_vol);
M_vol_sem = std(M_vol)/sqrt(size(M_volumes,1)); PT_vol_sem = std(PT_vol)/sqrt(size(PT_volumes,1));
Rs = []; Ps = [];

% %add VARIABILITY column to summary tables
% M_var_mean = readtable('/home/nikolaus/Desktop/Matlab_Scripts/M_summary_March23.xlsx'); M_var_std = readtable('/home/nikolaus/Desktop/Matlab_Scripts/M_std_March23.xlsx');
% PT_var_mean = readtable('/home/nikolaus/Desktop/Matlab_Scripts/PT_summary_March23.xlsx'); PT_var_std = readtable('/home/nikolaus/Desktop/Matlab_Scripts/PT_std_March23.xlsx');
% S_var_mean = readtable('/home/nikolaus/Desktop/Matlab_Scripts/Sham_summary_March23.xlsx'); S_var_std = readtable('/home/nikolaus/Desktop/Matlab_Scripts/Sham_std_March23.xlsx');
% 
% var_types = {'double','double','cell','double','double','double','double','double','double','double','double','double','double','double',...
% 'double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double', 'double', ...
% 'double','double','double','double','double','double','double','double','double','double','double', 'double','double','double','double','double','double','double','double','double'};
% var_names = {'Day','Mouse','Hand','TotalDur','FlexDur','ExtDur','FlexDurPer','ExtDurPer','PathLen','ReachDist','AvgSpeedTotal','AvgSpeedFlex','AvgSpeedExt','MaxSpeedTotal','MaxSpeedFlex',...
% 'MaxSpeedExt', 'AvgAccTotal','AvgAccFlex', 'AvgAccExt','MaxAccTotal','MaxAccFlex','MaxAccExt','AvgDecTotal','AvgDecFlex','AvgDecExt', 'MaxDecTotal', 'MaxDecFlex', 'MaxDecExt',...
% 'T_MaxSpeedTotal','T_MaxSpeedFlex','T_MaxSpeedExt','T_MaxAccTotal', 'T_MaxAccFlex', 'T_MaxAccExt','T_MaxDecTotal', 'T_MaxDecFlex', 'T_MaxDecExt',...
% 'TPerc_MaxSpeedTotal','TPerc_MaxSpeedFlex','TPerc_MaxSpeedExt','TPerc_MaxAccTotal', 'TPerc_MaxAccFlex', 'T_PercMaxAccExt','TPerc_MaxDecTotal', 'TPerc_MaxDecFlex',...
% 'TPerc_MaxDecExt','OnsetSpeedFlex', 'OnsetSpeedExt','OnsetAccFlex','OnsetAccExt','OnsetDecFlex', 'OnsetDecExt'};
% 
% M_var_table = deal(table('Size',[size(M_var_mean,1),52],'VariableTypes',var_types,'VariableNames',var_names));
% PT_var_table = deal(table('Size',[size(PT_var_mean,1),52],'VariableTypes',var_types,'VariableNames',var_names));
% S_var_table = deal(table('Size',[size(S_var_mean,1),52],'VariableTypes',var_types,'VariableNames',var_names));
% 
% M_var_mean = M_var_mean(:,1:53); M_var_std = M_var_std(:,1:53); PT_var_mean = PT_var_mean(:,1:53); PT_var_std = PT_var_std(:,1:53); S_var_mean = S_var_mean(:,1:53); S_var_std = S_var_std(:,1:53);
% 
% %calculate coefficient of variation (RSD = SD/|mean|) of all kinematic parameters
% M_var_table(:,1:3) = M_var_mean(:,1:3); M_var_table(:,4:52) = array2table(abs(M_var_std{:,5:53}./M_var_mean{:,5:53})); %variability tables
% PT_var_table(:,1:3) = PT_var_mean(:,1:3); PT_var_table(:,4:52) = array2table(abs(PT_var_std{:,5:53}./PT_var_mean{:,5:53}));
% S_var_table(:,1:3) = S_var_mean(:,1:3); S_var_table(:,4:52) = array2table(abs(S_var_std{:,5:53}./S_var_mean{:,5:53}));
% 
% %add the new column
% M_summary.Variability = mean(M_var_table{:,4:end},2);
% PT_summary.Variability = mean(PT_var_table{:,4:end},2);

%plot parameters
M_bcolor = '#1A85FF'; PT_bcolor = '#c20064'; %''
bwidth = 0.4; swidth = bwidth/4; small_pos = bwidth/2-swidth/2;
pos_M = 1; pos_PT = 1.75;
d = 0.25; spacer = 0.5; hangle = 60; hdens = 100;
eb_linewidth = 2; marker_sz = 30; marker_alpha = 0.3; marker = 'o'; marker_line = 1.5;
bar_alpha = 0.8; ticks_font = 8; axes_font = 10;

%figure parameters
publication_size = [300 220];
current_size = publication_size;

%plot means
figure; hold on;
bar(pos_M,M_vol_mean,'BarWidth',bwidth,'FaceColor',M_bcolor,'FaceAlpha',bar_alpha);
bar(pos_PT,PT_vol_mean,'BarWidth',bwidth,'FaceColor',PT_bcolor,'FaceAlpha',bar_alpha);

%plot sem
errorbar(pos_M,M_vol_mean,[],M_vol_sem,'Color',M_bcolor,'LineWidth',eb_linewidth);
errorbar(pos_PT,PT_vol_mean,[],PT_vol_sem,'Color',PT_bcolor,'LineWidth',eb_linewidth);

%scatter individual variables
M_scattering = 0.3*(rand(size(M_volumes,1),1)-0.5); %add. scatter in x-direction
PT_scattering = 0.3*(rand(size(PT_volumes,1),1)-0.5);

scatter(pos_M+M_scattering,M_vol,marker_sz,hex2rgb(M_bcolor),'filled','MarkerFaceAlpha',marker_alpha)
scatter(pos_M+M_scattering,M_vol,marker_sz,'k',marker,'LineWidth',marker_line)
scatter(pos_PT+PT_scattering,PT_vol,marker_sz,hex2rgb(PT_bcolor),'filled','MarkerFaceAlpha',marker_alpha)
scatter(pos_PT+PT_scattering,PT_vol,marker_sz,'k',marker,'LineWidth',marker_line)

%plot style
ax = gca; ax.YAxis.FontSize = ticks_font; ax.XAxis.FontSize = ticks_font+1;
ylabel('% of occluded residual brain','FontSize',axes_font); xlabel({'Stroke type'},'FontSize',axes_font); yticks([10 30 50 70]);
xticks([pos_M pos_PT]); xticklabels({'\bf MCAO','\bf PT'}); xtickangle(45); xlim([0.4 2.55]); ylim([0 70]); %2.75
set(gcf,'Position',[849 223 flip(current_size)],'Color','w');

%NEW 19/04/2023: corrected total absolute volume
alt_voltable_M = readtable('/home/nikolaus/Desktop/Matlab_Scripts/Lesion Volumes/MCAO_corr_lesion_volumes.xlsx');
alt_voltable_PT = readtable('/home/nikolaus/Desktop/Matlab_Scripts/Lesion Volumes/PT_corr_lesion_volumes.xlsx');
alt_voltable_M.Properties.VariableNames(1) = {'Mouse'}; alt_voltable_M.Properties.VariableNames(end) = {'stroke_volume'};
alt_voltable_M(alt_voltable_M.Mouse == 34,:) = [];
alt_voltable_PT.Properties.VariableNames(1) = {'Mouse'}; alt_voltable_PT.Properties.VariableNames(end) = {'stroke_volume'};
alt_voltable_M = alt_voltable_M(:,["Mouse","stroke_volume"]); alt_voltable_PT = alt_voltable_PT(:,["Mouse","stroke_volume"]);
M_vol = alt_voltable_M.stroke_volume; PT_vol = alt_voltable_PT.stroke_volume;

chosen_plots = [63 54 59];
chosen_day = 4;

for i = 5:size(M_summary,2) %run across columns %58 = slips count, 56 = reaches count

if ~ismember(i,chosen_plots), continue; end

for j = 1%1:2
hand_side = hands(j);

vol = [M_vol; PT_vol];

col_name = M_summary.Properties.VariableNames(i);
M_variable = M_summary{ismember(M_summary.Mouse,M_volumes.Mouse) & strcmp(M_summary.Hand,hand_side) & M_summary.Day == chosen_day,col_name};
PT_variable = PT_summary{ismember(PT_summary.Mouse,PT_volumes.Mouse) & strcmp(PT_summary.Hand,hand_side) & PT_summary.Day == chosen_day,col_name};

%(optional) normalize by day 1
% M_day1 = M_summary{ismember(M_summary.Mouse,M_volumes.Mouse) & strcmp(M_summary.Hand,hand_side) & M_summary.Day == 1,col_name};
% PT_day1 =  PT_summary{ismember(PT_summary.Mouse,PT_volumes.Mouse) & strcmp(PT_summary.Hand,hand_side) & PT_summary.Day == 1,col_name};
% M_variable = M_variable./M_day1; PT_variable = PT_variable./PT_day1;

variable = [M_variable; PT_variable];

%calculate correlation
[R,P] = corrcoef(vol,variable); %R2_M = linfit_M.Rsquared.Ordinary; P_M = linfit_M.Coefficients.pValue(2); %alternative
linfit = fitlm(vol,variable); b = linfit.Coefficients.Estimate(2); %linear fit, slope
intercept = linfit.Coefficients.Estimate(1); y_calc = b*vol+intercept; %intercept, y of linear fit

p_level = 10;%0.05; %significance level
if P(2,1)>p_level, continue; end %if significance too low, skip

%plot variables
switch hand_side %change figure position
case 'R', figure('Position',[1000 1000 current_size],'Color','w');
case 'L', figure('Position',[400 1000 current_size],'Color','w');
end

hold on;
scatter(M_vol,M_variable,marker_sz,hex2rgb(M_bcolor),'filled','MarkerFaceAlpha',marker_alpha); %filling
scatter(M_vol,M_variable,marker_sz,hex2rgb(M_bcolor),marker,'LineWidth',marker_line); %circle
scatter(PT_vol,PT_variable,marker_sz,hex2rgb(PT_bcolor),'filled','MarkerFaceAlpha',marker_alpha); %another color
scatter(PT_vol,PT_variable,marker_sz,hex2rgb(PT_bcolor),marker,'LineWidth',marker_line);

%visualize linear regression
[ypred,yci] = predict(linfit,(min(vol):1:max(vol))'); %default is alpha = 0.05 => 95% confidence interval
if P(2,1) < p_level
plot(vol,y_calc,'Color','k','LineWidth',eb_linewidth); %fit
plot((min(vol):1:max(vol))',yci,'.','Color','k','MarkerSize',3); %confidence intervals %0.5 %4.5
end

%embellish graphs
if i < 54
plot_name = col_name{1}(6:end);
else
plot_name = col_name{1};
end

%replace flexion with 'reach' and extension with 'retraction'
if contains(plot_name,'Flex')
plot_name = strrep(plot_name,'Flex','Reach');
elseif contains(plot_name,'Ext')
plot_name = strrep(plot_name,'Ext','Ret');
end

%plot style
%legend([M_scat PT_scat],{'Stroke (n)'},'Location','southeast');
ax = gca; ax.FontSize = ticks_font; 
my_yticks = yticks; divider = ceil(length(my_yticks)/4); %find the division factor of denominator 4 and lower it to first full integer
idx_yticks = 2:divider:length(my_yticks); yticks(my_yticks(idx_yticks)); %use that integer to divide the y-axis

%%%if t == 1, xlim([0 45]); elseif t == 2, xlim([45 75]); end %UNCOMMENT
%my_xticks = xticks; xticks(my_xticks(1:2:end));
[~,where] = ismember(col_name,oldnames); ylabel(varnames(where),'FontSize',axes_font);
xlabel('Infarct volume [mm^{3}]','FontSize',axes_font);
%percOverlap: % of region occluded
%volPercBrain: % of stroke in the region

%adjust axis for traditional score
%ylim([0 5]); yticks([1 3 5]); %d21

%adjust axis for success coeff
%ylim([-1 4]); yticks([0 2 4]);
%ylim([-0.5 2]); yticks([0 1 2]); %d21

%adjust axis for normalized duration
%ylim([0.75 1.3]); yticks([0.8 1 1.2]);

%plot significance
xlm = xlim; ylm = ylim; x_offset = 0.015*(xlm(2)-xlm(1)); y_offset = 0.045*(ylm(2)-ylm(1)); separator = 0.06*(ylm(2)-ylm(1)); 
%if P(2,1) < 0.05
text(ax,xlm(1)+x_offset,ylm(1)+y_offset,strcat('p = ',string(round(P(2,1),4))),'FontSize',ticks_font,'FontWeight','bold');
text(ax,xlm(1)+x_offset,ylm(1)+y_offset+separator,strcat('r = ',string(round(R(2,1),4))),'FontSize',ticks_font,'FontWeight','bold');
%end

% switch hand_side %optional title
% case 'R', title(['Right Hand: ', plot_name]); 
% case 'L', title(['Left Hand: ', plot_name]); 
% end

%disp(i);
%disp(t)
%disp(col_name);
%disp(hand_side)
%disp(P(2,1));
Rs = [Rs R(2,1)]; Ps = [Ps P(2,1)]; %#ok<AGROW>

end
end


%fantastic eight
%names = {'T_MaxAccTotal','T_MaxAccFlex','OnsetSpeedFlex','OnsetSpeedExt','FlexDurPer','T_MaxAccTotal','T_MaxAccExt','TPerc_MaxDecFlex'};
names = {'IL Max. Acceleration Time [s]','CL Onset Reach Speed [cm/s]','CL Onset Retr. Speed [cm/s]',...
'IL Reach Phase [%]','CL Max. Acceleration Time [s]','CL Max. Retr. Accel. Time [s]','CL Onset Reach Speed [cm/s]'};

trials = {'M' 'M' 'M' 'PT' 'PT' 'PT' 'PT'}; %trials = {'PT' 'PT' 'M' 'M' 'PT' 'PT' 'M' 'M'};

% Rs = [0.7440,0.6067,0.7381,0.6872,0.6832,-0.8019,-0.7380,-0.7013];
% Ps = [0.0087,0.0478,0.0095,0.0195,0.0425,0.0093,0.0232,0.0353];
Rs = round(Rs,4); Ps = round(Ps,4);

%ylims = [2.4500,2.2000,2.3000,3.4000,0.5100,2.2000,2.5000,0.2300]; ytix = [2.3000,2.1000,2.1000,2.8000,0.4800,1.9000,2,0.2100];

% for g = 2:length(findobj('Type','Figure'))
% ax = gca(g); ax.YLabel.String = names(g-1); %ax.Title.String = names(g-1);
% 
% %display R and P values (similar to above)
% xlm = ax.XLim; x_offset = 0.02*(xlm(2)-xlm(1)); ylm = ax.YLim; my_yticks = ax.YTick; y_offset = 0.025*(ylm(2)-ylm(1)); separator = 0.06*(ylm(2)-ylm(1)); 
% if ismember(g,[2 3 4 5]) %plot to left corner
% 
% if strcmp(trials(g-1),'M')
% M_string1 = strcat("R_{MCAO} = ",num2str(Rs(g-1))); M_string2 = strcat("P_{MCAO} = ",num2str(Ps(g-1)));
% text(ax,xlm(1)+x_offset,ylm(2)-y_offset,M_string1,'FontSize',ticks_font,'FontWeight','bold'); %MCAO R
% text(ax,xlm(1)+x_offset,ylm(2)-y_offset-separator,M_string2,'FontSize',ticks_font,'FontWeight','bold'); %MCAO P
% elseif strcmp(trials(g-1),'PT')
% PT_string1 = strcat("R_{PT} = ",num2str(Rs(g-1))); PT_string2 = strcat("P_{PT} = ",num2str(Ps(g-1)));
% text(ax,xlm(1)+x_offset,ylm(2)-y_offset,PT_string1,'FontSize',ticks_font,'FontWeight','bold'); %PT R
% text(ax,xlm(1)+x_offset,ylm(2)-y_offset-separator,PT_string2,'FontSize',ticks_font,'FontWeight','bold'); %PT P
% end
% 
% else %plot to right corner (variables 7,8,9)
% 
% if strcmp(trials(g-1),'M')
% M_string1 = strcat("R_{MCAO} = ",num2str(Rs(g-1))); M_string2 = strcat("P_{MCAO} = ",num2str(Ps(g-1)));
% text(ax,35,ylm(2)-y_offset,M_string1,'FontSize',ticks_font,'FontWeight','bold'); %MCAO R
% text(ax,35,ylm(2)-y_offset-separator,M_string2,'FontSize',ticks_font,'FontWeight','bold'); %MCAO P
% elseif strcmp(trials(g-1),'PT')
% PT_string1 = strcat("R_{PT} = ",num2str(Rs(g-1))); PT_string2 = strcat("P_{PT} = ",num2str(Ps(g-1)));
% text(ax,38,ylm(2)-y_offset,PT_string1,'FontSize',ticks_font,'FontWeight','bold'); %PT R
% text(ax,38,ylm(2)-y_offset-separator,PT_string2,'FontSize',ticks_font,'FontWeight','bold'); %PT P
% end
% 
% end
% end

%export all figures
if yes_export == 1
my_figures = findobj('Type','Figure');
for f = 1:length(my_figures)
export_fig(my_figures(f),'/home/nikolaus/Desktop/Matlab_Scripts/Plots/plots','-pdf','-append')
end
end

if yes_export == 1
my_figures = findobj('Type','Figure');
for f = 1:length(my_figures)
n = my_figures(f).Number;
if n == 1, figname = "residual_occlusion"; else, figname = 'corr_'+string(n); end
print(my_figures(f),strcat('/home/nikolaus/Desktop/Matlab_Scripts/Plots/',figname), '-dsvg')
end
end



