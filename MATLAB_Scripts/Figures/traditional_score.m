clear
close all
yes_export = 0; %if 1, export automatically to PDF

%plot layout
M_bcolor = '#1A85FF'; PT_bcolor = '#c20064'; 
eb_linewidth = 2;
ticks_font = 8; axes_font = 10; marker_size = 4;

%figure parameters
publication_size = [300 220];
current_size = publication_size;

bcolor = M_bcolor;
%MCAO
%TRADITIONAL (success events vs. leftover pellets) 
traditional_table = readtable('','Sheet','Sheet1'); %manual table
traditional_table = traditional_table(:,["Day","pellets_eaten_right","pellets_eaten_left"]);

success_sum = readtable(''); %automated table
success_events = groupsummary(success_sum,["Day","Hand"],"mean");
success_std = groupsummary(success_sum,["Day","Hand"],"std");
success_std.std_GroupCount = success_std.std_GroupCount./sqrt(success_std.GroupCount); %SEM

success_traditional = groupsummary(traditional_table,"Day","mean"); trad_std = groupsummary(traditional_table,"Day","std");
trad_std.std_pellets_eaten_right = trad_std.std_pellets_eaten_right./sqrt(trad_std.GroupCount); %SEM
trad_std.std_pellets_eaten_left = trad_std.std_pellets_eaten_left./sqrt(trad_std.GroupCount); %SEM

figure('Position',[400 1000 current_size],'Color','w'); hold on;

%right
errorbar(success_events.Day(strcmp(success_events.Hand,'R')),success_events.mean_GroupCount(strcmp(success_events.Hand,'R')),success_std.std_GroupCount(strcmp(success_std.Hand,'R')),'LineStyle',':','LineWidth',eb_linewidth,'Color',bcolor,'Marker','o','MarkerSize',marker_size)
errorbar(success_traditional.Day,success_traditional.mean_pellets_eaten_right,trad_std.std_pellets_eaten_right,'LineStyle','-','LineWidth',eb_linewidth,'Color',bcolor,'Marker','o','MarkerSize',marker_size);
%xlabel('Days','FontSize',axes_font); ylabel('Staircase Score','FontSize',axes_font); xticks([1 2 3 4]); xticklabels({'-4','7','14','21'}); xlim([0.5 4.5]); title('Right Hand: Staircase Score'); 

%left
%figure; hold on;
errorbar(success_events.Day(strcmp(success_events.Hand,'L')),success_events.mean_GroupCount(strcmp(success_events.Hand,'L')),success_std.std_GroupCount(strcmp(success_std.Hand,'L')),'LineStyle',':','LineWidth',eb_linewidth,'Color',bcolor,'Marker','none')
errorbar(success_traditional.Day,success_traditional.mean_pellets_eaten_left,trad_std.std_pellets_eaten_left,'LineStyle','-','LineWidth',eb_linewidth,'Color',bcolor,'Marker','none');

ax = gca; ax.FontSize = ticks_font;
xlabel('Days','FontSize',axes_font); ylabel('Traditional Score','FontSize',axes_font); xticks([1 2 3 4]);
xticklabels({'-4','7','14','21'}); xlim([0.5 4.5]); ylim([1.8 6]); %title('Left Hand: Staircase Score'); 

legend({'Automated (Right)','Visual (Right)','Automated (Left)','Visual (Left)'},'TextColor','k','FontSize',ticks_font);
current_gca1 = gca; current_gcf1 = gcf; 

bcolor = PT_bcolor;
%PHOTOTHROMBOSIS
traditional_table = readtable('','Sheet','Sheet1'); %manual table
traditional_table = traditional_table(:,["Day","pellets_right","pellets_left"]);

success_sum = readtable(''); %automated table
success_events = groupsummary(success_sum,["Day","Hand"],"mean");
success_std = groupsummary(success_sum,["Day","Hand"],"std");
success_std.std_GroupCount = success_std.std_GroupCount./sqrt(success_std.GroupCount); %SEM

success_traditional = groupsummary(traditional_table,"Day","mean"); trad_std = groupsummary(traditional_table,"Day","std");
trad_std.std_pellets_right = trad_std.std_pellets_right./sqrt(trad_std.GroupCount); %SEM
trad_std.std_pellets_left = trad_std.std_pellets_left./sqrt(trad_std.GroupCount); %SEM

figure('Position',[1000 1000 current_size],'Color','w'); hold on;

%right
errorbar(success_events.Day(strcmp(success_events.Hand,'R')),success_events.mean_GroupCount(strcmp(success_events.Hand,'R')),success_std.std_GroupCount(strcmp(success_std.Hand,'R')),'LineStyle',':','LineWidth',eb_linewidth,'Color',bcolor,'Marker','o','MarkerSize',marker_size)
errorbar(success_traditional.Day,success_traditional.mean_pellets_right,trad_std.std_pellets_right,'LineStyle','-','LineWidth',eb_linewidth,'Color',bcolor,'Marker','o','MarkerSize',marker_size); 
%xlabel('Days'); xticks([1 2 3 4]); xticklabels({'-4','7','14','21'}); xlim([0.5 4.5]); %title('Right Hand: Staircase Score');

%left
errorbar(success_events.Day(strcmp(success_events.Hand,'L')),success_events.mean_GroupCount(strcmp(success_events.Hand,'L')),success_std.std_GroupCount(strcmp(success_std.Hand,'L')),'LineStyle',':','LineWidth',eb_linewidth,'Color',bcolor,'Marker','none')
errorbar(success_traditional.Day,success_traditional.mean_pellets_left,trad_std.std_pellets_left,'LineStyle','-','LineWidth',eb_linewidth,'Color',bcolor,'Marker','none');

ax = gca; ax.FontSize = ticks_font;
xlabel('Days','FontSize',axes_font); ylabel('Traditional Score','FontSize',axes_font); xticks([1 2 3 4]);
xticklabels({'-4','7','14','21'}); xlim([0.5 4.5]); %title('Left Hand: Staircase Score'); 

%legend({'Automated (Right)','Visual (Right)','Automated (Left)','Visual (Left)'},'Location','north');
current_gca2 = gca; current_gcf2 = gcf;

%equalize axes
if current_gca1.YLim(1) < current_gca2.YLim(1), current_gca2.YLim(1) = current_gca1.YLim(1); else, current_gca1.YLim(1) = current_gca2.YLim(1); end
if current_gca1.YLim(2) > current_gca2.YLim(2), current_gca2.YLim(2) = current_gca1.YLim(2); else, current_gca1.YLim(2) = current_gca2.YLim(2); end

my_yticks = current_gca1.YTick; divider = floor(length(my_yticks)/4); %find the division factor of denominator 4 and lower it to first full integer
idx_yticks = 1:divider:length(my_yticks); current_gca1.YTick = my_yticks(idx_yticks); current_gca2.YTick = my_yticks(idx_yticks); %use that integer to divide the y-axis

%export figures
% if yes_export == 1
% export_fig(current_gcf1,'/home/nikolaus/Desktop/Matlab_Scripts/Plots/plots','-pdf','-append')
% export_fig(current_gcf2,'/home/nikolaus/Desktop/Matlab_Scripts/Plots/plots','-pdf','-append')
% end

if yes_export == 1
my_figures = findobj('Type','Figure');
for f = 1:length(my_figures)
n = my_figures(f).Number;
switch n
case 1, figname = "traditional_MCAO";
case 2, figname = "traditional_PT";
end
print(my_figures(f),strcat('/home/nikolaus/Desktop/Matlab_Scripts/Plots/',figname), '-dsvg')
end
end


