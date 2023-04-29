clear
% close all
yes_export = 0;

%define variables 
M_summary = readtable(''); %summary table
PT_summary = readtable('');

M_volumes = readtable(''); %volume table
PT_volumes = readtable('');
M_vol = M_volumes.LesionVolumeCorr_mm3_; PT_vol = PT_volumes.LesionVolumeCorr_mm3_; %volumes

my_vars = [33 48 49 8 33 35];  %selected correlations
my_hands = ['L' 'R' 'R' 'L' 'R' 'R']; 
lesion = {'M','PT'};

corr_list_M = table('Size', [1,4], 'VariableTypes', {'cell','cell','double','double'},'VariableNames', {'Name','Hand','R','P'});
corr_list_PT = table('Size', [1,4], 'VariableTypes', {'cell','cell','double','double'},'VariableNames', {'Name','Hand','R','P'});

%plot parameters
M_bcolor = '#1A85FF'; PT_bcolor = '#c20064'; %''
bwidth = 0.4; swidth = bwidth/4; small_pos = bwidth/2-swidth/2;
pos_M = 1; pos_PT = 2;
d = 0.25; spacer = 0.5; hangle = 60; hdens = 100;
eb_linewidth = 2; marker_sz = 30; marker_alpha = 0.3; marker = 'o'; marker_line = 1.5;
ticks_font = 8; axes_font = 10; bar_alpha = 0.8;

%figure parameters
publication_size = [300 220];
current_size = publication_size;

%find selected correlates
for curr_pos = 1:length(my_vars) 
i = my_vars(curr_pos); 
hand_side = my_hands(curr_pos);

M_col_name = M_summary.Properties.VariableNames(i);
PT_col_name = PT_summary.Properties.VariableNames(i);
M_variable = M_summary{ismember(M_summary.Mouse,M_volumes.AnimalMRI_ID) & strcmp(M_summary.Hand,hand_side) & M_summary.Day == 2,M_col_name};
PT_variable = PT_summary{ismember(PT_summary.Mouse,PT_volumes.AnimalMRI_ID) & strcmp(PT_summary.Hand,hand_side) & PT_summary.Day == 2,PT_col_name};

%calculate correlation
[R_M,P_M] = corrcoef(M_vol,M_variable); %R2_M = linfit_M.Rsquared.Ordinary; P_M = linfit_M.Coefficients.pValue(2); %alternative
linfit_M = fitlm(M_vol,M_variable); b_M = linfit_M.Coefficients.Estimate(2); %linear fit, slope
M_intercept = linfit_M.Coefficients.Estimate(1); y_calc_M = b_M*M_vol+M_intercept; %intercept, y of linear fit

[R_PT,P_PT] = corrcoef(PT_vol,PT_variable);
linfit_PT = fitlm(PT_vol,PT_variable); b_PT = linfit_PT.Coefficients.Estimate(2);
PT_intercept = linfit_PT.Coefficients.Estimate(1); y_calc_PT = b_PT*PT_vol+PT_intercept;

%make a list
corr_list_M(curr_pos,:) = [M_col_name hand_side R_M(2,1) P_M(2,1)];
corr_list_PT(curr_pos,:) = [PT_col_name hand_side R_PT(2,1) P_PT(2,1)];

end %end creating correlation list

[corr_list_M.Name, corr_list_PT.Name] = deal({'t^{MaxAcc}_{Total}IL';'v^{Onset}_{Reach}CL';'v^{Onset}_{Ret}CL';'fr^{Phase}_{Reach}IL';...
't^{MaxAcc}_{Total}CL';'t^{MaxAcc}_{Ret}CL'}); %change names of variables to plot

[~,positions] = sortrows(abs(corr_list_M.R));
corr_list_M = corr_list_M(positions,:); corr_list_PT = corr_list_PT(positions,:);

%plot two separate figures
for f = 1:2
if f == 1
figure('Position',[400 500 current_size],'Color','w'); hold on; 
horbar = barh(corr_list_M.R,'BaseValue',0,'FaceColor',M_bcolor,'FaceAlpha',bar_alpha); corr_list = corr_list_M;
elseif f == 2
figure('Position',[1000 500 current_size],'Color','w'); hold on;
horbar = barh(corr_list_PT.R,'BaseValue',0,'FaceColor',PT_bcolor,'FaceAlpha',bar_alpha); corr_list = corr_list_PT;
end

%write variable names
x_M = [0.03 -0.42 -0.475 -0.42 -0.445 -0.43]; x_PT = [0.03 -0.42 0.03 -0.42 -0.445 -0.43]; 
for barnr = 1:length(horbar.YData)
if f == 1
text(x_M(barnr),barnr,strcat('{\it',corr_list.Name(barnr),'}'),'FontSize',ticks_font,'FontWeight','bold'); %'_{',my_hands(barnr),'}' %0.05 -0.25
elseif f == 2
text(x_PT(barnr),barnr,strcat('{\it',corr_list.Name(barnr),'}'),'FontSize',ticks_font,'FontWeight','bold')
end
end

%plot style
my_yticks = yticks; yticks([]); %yticks(my_yticks(2:2:end));
my_xticks = xticks; xticks([-0.9 -0.6 -0.3 0 0.3 0.6 0.9]); xlim([-0.9 0.9]) %xticks(my_xticks(1:2:end)); 
ax = gca; ax.XAxis.FontSize = ticks_font;
ylabel('Features','FontSize',axes_font); xlabel('Correlation coefficient (R)','FontSize',axes_font);

if f == 1, current_gcf1 = gcf; elseif f == 2, current_gcf2 = gcf; end
end

if yes_export == 1
export_fig(current_gcf1,'/home/nikolaus/Desktop/Matlab_Scripts/Plots/plots','-pdf','-append')
export_fig(current_gcf2,'/home/nikolaus/Desktop/Matlab_Scripts/Plots/plots','-pdf','-append')
end

