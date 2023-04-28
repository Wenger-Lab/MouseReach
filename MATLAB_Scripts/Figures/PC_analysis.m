%builtin.com/data-science/step-step-explanation-principal-component-analysis
%strata.uga.edu/8370/lecturenotes/principalComponents.html
%theanalysisfactor.com/principal-component-analysis-negative-loadings/

clear
close all
yes_export = 0; %if 1, export automatically to PDF

%plot layout
%M_bcolor = '#1A85FF'; PT_bcolor = '#c20064'; S_bcolor = "#A7A7A7";
ticks_font = 8; axes_font = 10; marker_sz = 25; marker_alpha = 0.8;
day4_color = hex2rgb('#A7A7A7'); day7_color = hex2rgb('#D62246'); day14_color = hex2rgb('#3066BE'); day21_color = hex2rgb('#000505');
%day4_color = hex2rgb('#A7A7A7'); day7_color = hex2rgb('#D41159'); day14_color = hex2rgb('#40B0A6'); day21_color = hex2rgb('#434446');

%figure parameters
publication_size = [300 300]; %default size [330 220]
current_size = publication_size;

%load tables
M_summary = readtable(''); %summary table
PT_summary = readtable('');
%S_summary = readtable('');

%relativize values for individual mice
datasets = {'MCAO';'PT'}; hands = {'R';'L'};
M_mice = unique(M_summary.Mouse); PT_mice = unique(PT_summary.Mouse);

for d = 1:size(datasets,1)

data = datasets(d);
if strcmp(data,'MCAO')
current_table = M_summary; mice = M_mice;
elseif strcmp(data,'PT')
current_table = PT_summary; mice = PT_mice;
end

for var = 5:size(current_table,2) %go through all columns %53
for i = 1:size(mice,1) %consider one mouse
mouse = mice(i);
%for j = 1:size(hands,1) %look at values for each hand individually
%hand = hands(j);

current_table{current_table.Mouse == mouse,var} = normalize(current_table{current_table.Mouse == mouse,var});
% current_table{current_table.Mouse == mouse & strcmp(current_table.Hand,hand),var} = normalize(current_table{current_table.Mouse == mouse & strcmp(current_table.Hand,hand),var});
%end
end
end
if strcmp(data,'MCAO'), M_summary = current_table; elseif strcmp(data,'PT'), PT_summary = current_table; end
end

%build groups and datatables for PCA
groups_MR = [-4*ones(size(M_summary(M_summary.Day == 1 & strcmp(M_summary.Hand,'R'),:),1),1); 7*ones(size(M_summary(M_summary.Day == 2 & strcmp(M_summary.Hand,'R'),:),1),1);...
14*ones(size(M_summary(M_summary.Day == 3 & strcmp(M_summary.Hand,'R'),:),1),1); 21*ones(size(M_summary(M_summary.Day == 4 & strcmp(M_summary.Hand,'R'),:),1),1)];
groups_ML = [-4*ones(size(M_summary(M_summary.Day == 1 & strcmp(M_summary.Hand,'L'),:),1),1); 7*ones(size(M_summary(M_summary.Day == 2 & strcmp(M_summary.Hand,'L'),:),1),1);...
14*ones(size(M_summary(M_summary.Day == 3 & strcmp(M_summary.Hand,'L'),:),1),1); 21*ones(size(M_summary(M_summary.Day == 4 & strcmp(M_summary.Hand,'L'),:),1),1)];

groups_PTR = [-4*ones(size(PT_summary(PT_summary.Day == 1 & strcmp(PT_summary.Hand,'R'),:),1),1); 7*ones(size(PT_summary(PT_summary.Day == 2 & strcmp(PT_summary.Hand,'R'),:),1),1);...
14*ones(size(PT_summary(PT_summary.Day == 3 & strcmp(PT_summary.Hand,'R'),:),1),1); 21*ones(size(PT_summary(PT_summary.Day == 4 & strcmp(PT_summary.Hand,'R'),:),1),1)];
groups_PTL = [-4*ones(size(PT_summary(PT_summary.Day == 1 & strcmp(PT_summary.Hand,'L'),:),1),1); 7*ones(size(PT_summary(PT_summary.Day == 2 & strcmp(PT_summary.Hand,'L'),:),1),1);...
14*ones(size(PT_summary(PT_summary.Day == 3 & strcmp(PT_summary.Hand,'L'),:),1),1); 21*ones(size(PT_summary(PT_summary.Day == 4 & strcmp(PT_summary.Hand,'L'),:),1),1)];

PCA_table_MR = table2array(M_summary(strcmp(M_summary.Hand,'R'),5:end));
PCA_table_ML = table2array(M_summary(strcmp(M_summary.Hand,'L'),5:end));
PCA_table_PTR = table2array(PT_summary(strcmp(PT_summary.Hand,'R'),5:end));
PCA_table_PTL = table2array(PT_summary(strcmp(PT_summary.Hand,'L'),5:end));

%normalize data before PCA
PCA_table_MR = normalize(PCA_table_MR); PCA_table_ML = normalize(PCA_table_ML); PCA_table_PTR = normalize(PCA_table_PTR); PCA_table_PTL = normalize(PCA_table_PTL);

%PCA
[coeff_MR,score_MR,latent_MR,tsquared_MR,explained_MR] = pca(PCA_table_MR);
[coeff_ML,score_ML,latent_ML,tsquared_ML,explained_ML] = pca(PCA_table_ML);
[coeff_PTR,score_PTR,latent_PTR,tsquared_PTR,explained_PTR] = pca(PCA_table_PTR);
[coeff_PTL,score_PTL,latent_PTL,tsquared_PTL,explained_PTL] = pca(PCA_table_PTL);

%tables for plotting
table_MR = array2table([score_MR(:,1) score_MR(:,2) groups_MR]); table_MR.Properties.VariableNames = {'Score1','Score2','Groups'};
table_ML = array2table([score_ML(:,1) score_ML(:,2) groups_ML]); table_ML.Properties.VariableNames = {'Score1','Score2','Groups'};
table_PTR = array2table([score_PTR(:,1) score_PTR(:,2) groups_PTR]); table_PTR.Properties.VariableNames = {'Score1','Score2','Groups'};
table_PTL = array2table([score_PTL(:,1) score_PTL(:,2) groups_PTL]); table_PTL.Properties.VariableNames = {'Score1','Score2','Groups'};

%plot PCA
figure; scat_MR = scatterhistogram(table_MR,'Score1','Score2','GroupVariable','Groups','HistogramDisplayStyle','smooth'); ax = gca; ax.FontSize = ticks_font;
scat_MR.LineWidth = [1.5 1.5 1.5 1.5]; scat_MR.LineStyle = ["-" "--" ":" "-."]; scat_MR.MarkerFilled = 'on'; scat_MR.MarkerAlpha = marker_alpha;
scat_MR.Color = [day4_color; day7_color; day14_color; day21_color]; scat_MR.MarkerSize = [marker_sz marker_sz marker_sz marker_sz];
scat_MR.XLabel = strcat('PC1 (',string(round(explained_MR(1),1)),'% explained variance)'); scat_MR.LegendTitle = 'Days'; scat_MR.LegendVisible = 'on';
scat_MR.YLabel = strcat('PC2 (',string(round(explained_MR(2),1)),'% explained variance)'); scat_MR.Title = 'Contralesional MCAO';
set(gcf,'Position',[983 575 current_size],'Color','w'); scat_MR.XLimits = [-13 13]; scat_MR.YLimits = [-9 8]; pause(0.5) %scat_MR.XLimits = [-12.5 11.5]; scat_MR.YLimits = [-8.5 8];
if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf; end

figure; scat_ML = scatterhistogram(table_ML,'Score1','Score2','GroupVariable','Groups','HistogramDisplayStyle','smooth'); ax = gca; ax.FontSize = ticks_font;
scat_ML.LineWidth = [1.5 1.5 1.5 1.5]; scat_ML.LineStyle = ["-" "--" ":" "-."]; scat_ML.MarkerFilled = 'on'; scat_ML.MarkerAlpha = marker_alpha;
scat_ML.Color = [day4_color; day7_color; day14_color; day21_color]; scat_ML.MarkerSize = [marker_sz marker_sz marker_sz marker_sz];
scat_ML.XLabel = strcat('PC1 (',string(round(explained_ML(1),1)),'% explained variance)'); scat_ML.LegendTitle = 'Days';
scat_ML.YLabel = strcat('PC2 (',string(round(explained_ML(2),1)),'% explained variance)'); scat_ML.Title = 'Ipsilesional MCAO';
set(gcf,'Position',[488 575 current_size],'Color','w'); scat_ML.XLimits = [-13 13]; scat_ML.YLimits = [-9 8]; pause(0.5) %scat_ML.XLimits = [-13 13.5]; scat_ML.YLimits = [-9 7.5];
if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf -append; end

figure; scat_PTR = scatterhistogram(table_PTR,'Score1','Score2','GroupVariable','Groups','HistogramDisplayStyle','smooth'); ax = gca; ax.FontSize = ticks_font;
scat_PTR.LineWidth = [1.5 1.5 1.5 1.5]; scat_PTR.LineStyle = ["-" "--" ":" "-."]; scat_PTR.MarkerFilled = 'on'; scat_PTR.MarkerAlpha = marker_alpha;
scat_PTR.Color = [day4_color; day7_color; day14_color; day21_color]; scat_PTR.MarkerSize = [marker_sz marker_sz marker_sz marker_sz];
scat_PTR.XLabel = strcat('PC1 (',string(round(explained_PTR(1),1)),'% explained variance)'); scat_PTR.LegendTitle = 'Days';
scat_PTR.YLabel = strcat('PC2 (',string(round(explained_PTR(2),1)),'% explained variance)'); scat_PTR.Title = 'Contralesional PT';
set(gcf,'Position',[983 75 current_size],'Color','w'); scat_PTR.XLimits = [-13 13]; scat_PTR.YLimits = [-9 8]; pause(0.5) %scat_PTR.XLimits = [-11.5 14]; scat_PTR.YLimits = [-8.5 7]; 
if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf -append; end

figure; scat_PTL = scatterhistogram(table_PTL,'Score1','Score2','GroupVariable','Groups','HistogramDisplayStyle','smooth'); ax = gca; ax.FontSize = ticks_font;
scat_PTL.LineWidth = [1.5 1.5 1.5 1.5]; scat_PTL.LineStyle = ["-" "--" ":" "-."]; scat_PTL.MarkerFilled = 'on'; scat_PTL.MarkerAlpha = marker_alpha;
scat_PTL.Color = [day4_color; day7_color; day14_color; day21_color]; scat_PTL.MarkerSize = [marker_sz marker_sz marker_sz marker_sz];
scat_PTL.XLabel = strcat('PC1 (',string(round(explained_PTL(1),1)),'% explained variance)'); scat_PTL.LegendTitle = 'Days';
scat_PTL.YLabel = strcat('PC2 (',string(round(explained_PTL(2),1)),'% explained variance)'); scat_PTL.Title = 'Ipsilesional PT';
set(gcf,'Position',[488 75 current_size],'Color','w'); scat_PTL.XLimits = [-13 13]; scat_PTL.YLimits = [-9 8]; pause(0.5) %scat_PTL.XLimits = [-12.5 12]; scat_PTL.YLimits = [-6.5 8];
if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf -append; end

%return 

%create custom colormap
% custom_colormap = [0.9000 0.9447 0.9741; 0.1445 0.4023 0.625]; %custom_colormap = [0.9000 0.9447 0.9741; 0 0.4470 0.7410]; %default
% custom_colormap = interp1(1:size(custom_colormap,1),custom_colormap,1:0.015:size(custom_colormap,1),'linear'); %blue->white
% custom_colormap = brighten(cool,-0.2); 

custom_colormap = [0.2314 0.7686 1; 1 1 1; 0.7412 0.2588 1]; %custom_colormap = [0 1 1; 1 1 1; 1 0 1];
custom_colormap = interp1(1:size(custom_colormap,1),custom_colormap,1:0.01:2:0.01:3,'linear');  %#ok<M3COL>
custom_colormap = brighten(custom_colormap,-0.2);

%variable names
varnames = {'Total Duration','Reach Duration','Retraction Duration','Reach Duration [%]','Retraction Duration [%]','Path Length','Reach Distance','Total Average Speed',...
'Reach Average Speed','Retraction Average Speed','Total Max Speed','Reach Max Speed',...
'Retraction Max Speed', 'Total Average Acc','Reach Average Acc', 'Retraction Average Acc','Total Max Acc','Reach Max Acc','Retraction Max Acc',...
'Total Average Decel','Reach Average Decel','Retraction Average Decel', 'Total Max Decel', 'Reach Max Decel', 'Retraction Max Decel',...
'Total Max Speed [t]','Reach Max Speed [t]','Retraction Max Speed [t]','Total Max Acc [t]', 'Reach Max Acc [t]', 'Retraction Max Acc [t]','Total Max Dec [t]',...
'Reach Max Decel [t]', 'Retraction Max Decel [t]', 'Total Max Speed [t%]','Reach Max Speed [t%]','Retraction Max Speed [t%]','Total Max Acc [t%]',...
'Reach Max Acc [t%]', 'Retraction Max Acc [t%]','Total Max Decel [t%]', 'Reach Max Decel [t%]',...
'Retraction Max Decel [t%]','Reach Onset Speed', 'Retraction Onset Speed','Reach Onset Acc','Retraction Onset Acc','Reach Onset Dec', 'Retraction Onset Dec',...
'Success Coefficient', 'Success Events', 'Reach Count','Pellet Count', 'Slip Count', 'Grab Time','Grab Events'};

%create heatmaps
figure; hmap_MR = heatmap(coeff_MR(:,1:3),'Colormap',custom_colormap,'XLabel','Principal Components','YLabel','Variables','CellLabelColor','none'); %brighten(cool,-0.2)
hmap_MR.FontSize = axes_font; title('Contralesional MCAO'); set(gcf,'Position',[498 -33 407 943],'Color','w'); pause(0.5) %hmap_MR.ColorScaling = 'scaledcolumns'; 
hmap_MR.YDisplayLabels = varnames; sorty(hmap_MR,{'1','2'},'descend'); hmap_MR.ColorLimits = [-0.3 0.3]; %set y-bar limits
if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf -append; end

figure; hmap_ML = heatmap(coeff_ML(:,1:3),'Colormap',custom_colormap,'XLabel','Principal Components','YLabel','Variables','CellLabelColor','none');
hmap_ML.FontSize = axes_font; title('Ipsilesional MCAO'); set(gcf,'Position',[76 1 407 943],'Color','w'); pause(0.5) %hmap_ML.ColorScaling = 'scaledcolumns'; 
hmap_ML.YDisplayLabels = varnames; sorty(hmap_ML,{'1','2'},'descend'); hmap_ML.ColorLimits = [-0.3 0.3];
if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf -append; end

figure; hmap_PTR = heatmap(coeff_PTR(:,1:3),'Colormap',custom_colormap,'XLabel','Principal Components','YLabel','Variables','CellLabelColor','none');
hmap_PTR.FontSize = axes_font; title('Contralesional PT'); set(gcf,'Position',[1500 1 407 943],'Color','w'); pause(0.5) %hmap_PTR.ColorScaling = 'scaledcolumns'; 
hmap_PTR.YDisplayLabels = varnames; sorty(hmap_PTR,{'1','2'},'descend'); hmap_PTR.ColorLimits = [-0.3 0.3];
if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf -append; end

figure; hmap_PTL = heatmap(coeff_PTL(:,1:3),'Colormap',custom_colormap,'XLabel','Principal Components','YLabel','Variables','CellLabelColor','none');
hmap_PTL.FontSize = axes_font; title('Ipsilesional PT'); set(gcf,'Position',[1078 1 407 943],'Color','w'); pause(0.5) %hmap_PTL.ColorScaling = 'scaledcolumns'; 
hmap_PTL.YDisplayLabels = varnames; sorty(hmap_PTL,{'1','2'},'descend'); hmap_PTL.ColorLimits = [-0.3 0.3];
if yes_export == 1, export_fig /home/nikolaus/Desktop/Matlab_Scripts/Plots/plots -pdf -append; end

%OLD STUFF
%biplot(coeff_R(:,1:2))

% view(3); grid on; hold on;
% for i = 1:size(PCA_table,1)
% switch PCA_table(i,1), case 1, dot_color = 'blue'; case 2, dot_color = 'yellow'; case 3, dot_color = 'red'; case 4, dot_color = 'green'; end
% plot3(score(i,1),score(i,2),score(i,3),'.','color',dot_color,'MarkerSize',20);
% end
% legend('Day -4', 'Day 7', 'Day 14', 'Day 21')

%scatter3(score(:,1),score(:,2),score(:,3), 23, PCA_table_PT(:,1),'filled'); colormap([0.8500 0.3250 0.0980; 0.3010 0.7450 0.9330; 0.4660 0.6740 0.1880; 0.4940 0.1840 0.5560]);
%colorbar('Location','WestOutside','YTickLabel',{'Day -4', 'Day 7', 'Day 14', 'Day 21'},'YTick',[1 2 3 4]); axis equal
%ax = gca; set(ax,'FontSize',20); box off; xlabel('PC1'); ylabel('PC2'); zlabel('PC3');
%exportgraphics(ax,'pca.png','Resolution',300)