clear
close all
yes_export = 0;

M_volumes = readtable(''); %volumes table
PT_volumes = readtable('');
M_volumes(M_volumes.AnimalMRI_ID == 34,:) = []; 

%define variables 
M_vol = M_volumes.LesionVolumeCorr_mm3_; PT_vol = PT_volumes.LesionVolumeCorr_mm3_; %volumes
M_mean = mean(M_vol); PT_mean = mean(PT_vol);
M_sem = std(M_vol)/sqrt(size(M_volumes,1)); PT_sem = std(PT_vol)/sqrt(size(PT_volumes,1));
Rs = []; Ps = [];

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
bar(pos_M,M_mean,'BarWidth',bwidth,'FaceColor',M_bcolor,'FaceAlpha',bar_alpha);
bar(pos_PT,PT_mean,'BarWidth',bwidth,'FaceColor',PT_bcolor,'FaceAlpha',bar_alpha);

%plot sem
errorbar(pos_M,M_mean,[],M_sem,'Color',M_bcolor,'LineWidth',eb_linewidth);
errorbar(pos_PT,PT_mean,[],PT_sem,'Color',PT_bcolor,'LineWidth',eb_linewidth);

%scatter individual variables
M_scattering = 0.3*(rand(size(M_volumes,1),1)-0.5); %add. scatter in x-direction
PT_scattering = 0.3*(rand(size(PT_volumes,1),1)-0.5);

scatter(pos_M+M_scattering,M_vol,marker_sz,hex2rgb(M_bcolor),'filled','MarkerFaceAlpha',marker_alpha)
scatter(pos_M+M_scattering,M_vol,marker_sz,'k',marker,'LineWidth',marker_line)
scatter(pos_PT+PT_scattering,PT_vol,marker_sz,hex2rgb(PT_bcolor),'filled','MarkerFaceAlpha',marker_alpha)
scatter(pos_PT+PT_scattering,PT_vol,marker_sz,'k',marker,'LineWidth',marker_line)

%plot style
ax = gca; ax.YAxis.FontSize = ticks_font; ax.XAxis.FontSize = ticks_font+1;
ylabel('Infarct volume [mm^{3}]','FontSize',axes_font); xlabel({'Stroke type'},'FontSize',axes_font); yticks([10 30 50]);
xticks([pos_M pos_PT]); xticklabels({'\bf MCAO','\bf PT'}); xtickangle(45); xlim([0.4 2.55]) %2.75
set(gcf,'Position',[849 223 flip(current_size)],'Color','w');

return
%correlations in another script

%CORRELATIONS
M_summary = readtable(''); M_summary(M_summary.Mouse == 34,:) = [];
PT_summary = readtable(''); %summary table
M_summary(:,{'SlipDepth','SlipTime','GrabDepth','GrabTime'}) = fillmissing(M_summary(:,{'SlipDepth','SlipTime','GrabDepth','GrabTime'}),'constant',0);
PT_summary(:,{'SlipDepth','SlipTime','GrabDepth','GrabTime'}) = fillmissing(PT_summary(:,{'SlipDepth','SlipTime','GrabDepth','GrabTime'}),'constant',0);

%plot and check correlation for all variables vs. stroke volume
hands = ['R','L'];
lesion = {'M','PT'};

for t = 1:length(lesion) %separates MCAO and PT
type = lesion(t);

for i = 5:size(M_summary,2)

for j = 1%1:2
hand_side = hands(j);

if strcmp(type,'M')
col_name = M_summary.Properties.VariableNames(i); vol = M_vol; bcolor = M_bcolor;
variable = M_summary{ismember(M_summary.Mouse,M_volumes.AnimalMRI_ID) & strcmp(M_summary.Hand,hand_side) & M_summary.Day == 2,col_name};
elseif strcmp(type,'PT')
col_name = PT_summary.Properties.VariableNames(i); vol = PT_vol; bcolor = PT_bcolor;
variable = PT_summary{ismember(PT_summary.Mouse,PT_volumes.AnimalMRI_ID) & strcmp(PT_summary.Hand,hand_side) & PT_summary.Day == 2,col_name};
end

%calculate correlation
[R,P] = corrcoef(vol,variable); %R2_M = linfit_M.Rsquared.Ordinary; P_M = linfit_M.Coefficients.pValue(2); %alternative
linfit = fitlm(vol,variable); b = linfit.Coefficients.Estimate(2); %linear fit, slope
intercept = linfit.Coefficients.Estimate(1); y_calc = b*vol+intercept; %intercept, y of linear fit

p_level = 0.05; %significance level
if P(2,1)>p_level, continue; end %if significance too low, skip

%plot variables
switch hand_side %change figure position
case 'R', figure('Position',[1000 1000 current_size],'Color','w');
case 'L', figure('Position',[400 1000 current_size],'Color','w');
end

hold on;
scatter(vol,variable,marker_sz,hex2rgb(bcolor),'filled','MarkerFaceAlpha',marker_alpha); %filling
scat = scatter(vol,variable,marker_sz,hex2rgb(bcolor),marker,'LineWidth',marker_line); %circle

%visualize linear regression
[ypred,yci] = predict(linfit,(min(vol):0.5:max(vol))'); %default is alpha = 0.05 => 95% confidence interval
if P(2,1) < p_level
plot(vol,y_calc,'Color',bcolor,'LineWidth',eb_linewidth); %fit
plot((min(vol):0.5:max(vol))',yci,'.','Color',bcolor,'MarkerSize',4.5); %confidence intervals
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

if t == 1, xlim([0 45]); elseif t == 2, xlim([20 55]); end
%my_xticks = xticks; xticks(my_xticks(1:2:end));
ylabel(plot_name,'FontSize',axes_font); xlabel('Infarct volume [mm^{3}]','FontSize',axes_font); 


% %plot R and P
% xlm = xlim; x_offset = 0.02*(xlm(2)-xlm(1)); ylm = ylim; offset = 0.025*(ylm(2)-ylm(1)); separator = 0.05*(ylm(2)-ylm(1));
% 
% if strcmp(type,'M')
% 
% M_string1 = strcat("R_{MCAO} = ",num2str(R(2,1))); M_string2 = strcat("P_{MCAO} = ",num2str(P(2,1))); %R & P
% if P(2,1) < p_level
% text(xlm(1)+x_offset,ylm(2)-offset,M_string1,'FontSize',9,'FontWeight','bold'); %MCAO R
% text(xlm(1)+x_offset,ylm(2)-offset-separator,M_string2,'FontSize',9,'FontWeight','bold'); %MCAO P
% end
% 
% elseif strcmp(type,'PT')
% 
% PT_string1 = strcat("R_{PT} = ",num2str(R(2,1))); PT_string2 = strcat("P_{PT} = ",num2str(P(2,1)));
% if P(2,1) < p_level
% text(xlm(1)+x_offset,ylm(2)-offset,PT_string1,'FontSize',9,'FontWeight','bold'); %PT R
% text(xlm(1)+x_offset,ylm(2)-offset-separator,PT_string2,'FontSize',9,'FontWeight','bold'); %PT P
% end
% end

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
end


%plotting coefficients at custom locations
% %names = {'T_MaxAccTotal','T_MaxAccFlex','OnsetSpeedFlex','OnsetSpeedExt','FlexDurPer','T_MaxAccTotal','T_MaxAccExt','TPerc_MaxDecFlex'};
% names = {'IL Max. Acceleration Time [s]','CL Onset Reach Speed [cm/s]','CL Onset Retr. Speed [cm/s]',...
% 'IL Reach Phase [%]','CL Max. Acceleration Time [s]','CL Max. Retr. Accel. Time [s]','CL Onset Reach Speed [cm/s]'};
% 
% trials = {'M' 'M' 'M' 'PT' 'PT' 'PT' 'PT'}; %trials = {'PT' 'PT' 'M' 'M' 'PT' 'PT' 'M' 'M'};
% 
% % Rs = [0.7440,0.6067,0.7381,0.6872,0.6832,-0.8019,-0.7380,-0.7013];
% % Ps = [0.0087,0.0478,0.0095,0.0195,0.0425,0.0093,0.0232,0.0353];
% Rs = round(Rs,4); Ps = round(Ps,4);
% 
% %ylims = [2.4500,2.2000,2.3000,3.4000,0.5100,2.2000,2.5000,0.2300]; ytix = [2.3000,2.1000,2.1000,2.8000,0.4800,1.9000,2,0.2100];
% 
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
case 1, figname = "infarct_volume";
end
print(my_figures(f),strcat('/home/nikolaus/Desktop/Matlab_Scripts/Plots/',figname), '-dsvg')
end
end


