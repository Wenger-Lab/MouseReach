clear
close all
yes_export = 0;

%plot parameters
M_bcolor = "#1A85FF"; PT_bcolor = "#c20064"; bar_alpha = 0.8; %0.9
bwidth = 0.4; swidth = bwidth/4; small_pos = bwidth/2-swidth/2;
pos_M1 = 1; pos_M2 = 2.5;
d = 0.25; spacer = 0.5; hangle = 60; hdens = 40;
ticks_font = 8; axes_font = 10; 

%figure parameters
publication_size = [300 250]; %default y is 220
current_size = publication_size;

%https://davidmathlogic.com/colorblind/#%23D81B60-%231E88E5-%23FFC107-%23004D40
%coolors.co

%SLIPS
%MCAO (mouse 21) 
slips_auto_RM = readtable('/mnt/66E0A3E3E0A3B827/Matej_Metamizol/Validation/Slips_auto_M_R_Mouse21.xlsx'); slips_auto_RM = table2array(slips_auto_RM);
slips_auto_LM = readtable('/mnt/66E0A3E3E0A3B827/Matej_Metamizol/Validation/Slips_auto_M_L_Mouse21.xlsx'); slips_auto_LM = table2array(slips_auto_LM); %slips_auto_LM(1) = 0.1; %just for graph display
slips_manual_M = readtable('/mnt/66E0A3E3E0A3B827/Matej_Metamizol/Validation/Slips_check_manual_Mouse21.xlsx');
sum_SARM = sum(slips_auto_RM); sum_SALM = sum(slips_auto_LM); sum_SMRM = sum(slips_manual_M.right); sum_SMLM = sum(slips_manual_M.left);

slips_auto_M = slips_auto_RM+slips_auto_LM; slips_man_M = sum(table2array(slips_manual_M),2);
sum_SAM = sum(slips_auto_M); sum_SMM = sum(slips_man_M);

figure; hold on;

%stacked bar
MA_stack = bar(pos_M1-d,slips_auto_M,'stacked','BarWidth',bwidth,'FaceColor','flat','FaceAlpha',bar_alpha);
MA_stack(1).CData = hex2rgb('#A7A7A7'); MA_stack(2).CData = hex2rgb('#4d4d4d'); MA_stack(3).CData = hex2rgb('#A7A7A7'); MA_stack(4).CData = hex2rgb('#4d4d4d');
%'#D35FB7','#DC3220','#D41159','#5D3A9B'
MM_stack = bar(pos_M1+d,slips_man_M,'stacked','BarWidth',bwidth,'FaceColor','flat','FaceAlpha',bar_alpha);
MM_stack(1).CData = hex2rgb('#A7A7A7'); MM_stack(2).CData = hex2rgb('#4d4d4d'); MM_stack(3).CData = hex2rgb('#A7A7A7'); MM_stack(4).CData = hex2rgb('#4d4d4d');
hatchfill2(MM_stack,'single','HatchAngle',hangle,'hatchcolor','black','HatchDensity',hdens);

%PT (mouse 3)
slips_auto_RPT = readtable('/mnt/66E0A3E3E0A3B827/Photothrombosis_Feb_2022/Validation/Slips_auto_PT_R_Mouse3.xlsx'); slips_auto_RPT = table2array(slips_auto_RPT);
slips_auto_LPT = readtable('/mnt/66E0A3E3E0A3B827/Photothrombosis_Feb_2022/Validation/Slips_auto_PT_L_Mouse3.xlsx'); slips_auto_LPT = table2array(slips_auto_LPT);
slips_manual_PT = readtable('/mnt/66E0A3E3E0A3B827/Photothrombosis_Feb_2022/Validation/Slips_check_manual_Mouse3.xlsx');
sum_SARPT = sum(slips_auto_RPT); sum_SALPT = sum(slips_auto_LPT); sum_SMRPT = sum(slips_manual_PT.right); sum_SMLPT = sum(slips_manual_PT.left);

slips_auto_PT = slips_auto_RPT+slips_auto_LPT; slips_man_PT = sum(table2array(slips_manual_PT),2);
sum_SAPT = sum(slips_auto_PT); sum_SMPT = sum(slips_man_PT);

%stacked bar
PTA_stack = bar(pos_M2-d,slips_auto_PT,'stacked','BarWidth',bwidth,'FaceColor','flat','FaceAlpha',bar_alpha);
PTA_stack(1).CData = hex2rgb('#A7A7A7'); PTA_stack(2).CData = hex2rgb('#4d4d4d'); PTA_stack(3).CData = hex2rgb('#A7A7A7'); PTA_stack(4).CData = hex2rgb('#4d4d4d');
%'#40B0A6','#1A85FF','#006CD1','#005AB5'
PTM_stack = bar(pos_M2+d,slips_man_PT,'stacked','BarWidth',bwidth,'FaceColor','flat','FaceAlpha',bar_alpha);
PTM_stack(1).CData = hex2rgb('#A7A7A7'); PTM_stack(2).CData = hex2rgb('#4d4d4d'); PTM_stack(3).CData = hex2rgb('#A7A7A7'); PTM_stack(4).CData = hex2rgb('#4d4d4d');
hatchfill2(PTM_stack,'single','HatchAngle',hangle,'hatchcolor','black','HatchDensity',hdens);

%plot layout
ax = gca; ax.YAxis.FontSize = ticks_font; ax.XAxis.FontSize = ticks_font+1; 
xticks([0.75 1.25 2.25 2.75]); xticklabels({'detected','visual','detected','visual'}); xtickangle(45); yticks([0 20 40 60]); 
ylabel('Slips','FontSize',axes_font); xlabel('Mouse 1         Mouse 2','FontWeight','bold','FontSize',axes_font); %title('Sum of all slips + individual days');
ylm = ylim; %text(pos_Ml-0.2,ylm(1)-5,'MCAO','FontSize',12,'FontWeight','bold'); text(pos_PTl-0.1,ylm(1)-5,'PT','FontSize',12,'FontWeight','bold');
%text(pos_Ml-0.45,ylm(1)-25,'Mouse 1','FontSize',ticks_font+1,'FontWeight','bold'); text(pos_PTl-0.45,ylm(1)-25,'Mouse 2','FontSize',ticks_font+1,'FontWeight','bold');
set(gcf,'Position',[300 1000 current_size],'Color','w'); xlim([0 3.5]); ylim([0 ylm(2)]); %reset y-axis so it starts from 0


%REACHES
%MCAO (mouse 21)
reaches_auto_RM = readtable('/mnt/66E0A3E3E0A3B827/Matej_Metamizol/Validation/Reaches_auto_M_R_Mouse21.xlsx'); reaches_auto_RM = table2array(reaches_auto_RM);
reaches_auto_LM = readtable('/mnt/66E0A3E3E0A3B827/Matej_Metamizol/Validation/Reaches_auto_M_L_Mouse21.xlsx'); reaches_auto_LM = table2array(reaches_auto_LM);
reaches_manual_M = readtable('/mnt/66E0A3E3E0A3B827/Matej_Metamizol/Validation/Reaches_check_manual_Mouse21.xlsx');

reaches_auto_M = reaches_auto_RM+reaches_auto_LM; reaches_man_M = sum(table2array(reaches_manual_M),2);
sum_RAM = sum(reaches_auto_M); sum_RMM = sum(reaches_man_M);

figure; hold on;

%stacked bar
MA_stack = bar(pos_M1-d,reaches_auto_M,'stacked','BarWidth',bwidth,'FaceColor','flat','FaceAlpha',bar_alpha);
MA_stack(1).CData = hex2rgb('#4d4d4d'); MA_stack(2).CData = hex2rgb('#A7A7A7'); MA_stack(3).CData = hex2rgb('#4d4d4d'); MA_stack(4).CData = hex2rgb('#A7A7A7');

MM_stack = bar(pos_M1+d,reaches_man_M,'stacked','BarWidth',bwidth,'FaceColor','flat','FaceAlpha',bar_alpha);
MM_stack(1).CData = hex2rgb('#4d4d4d'); MM_stack(2).CData = hex2rgb('#A7A7A7'); MM_stack(3).CData = hex2rgb('#4d4d4d'); MM_stack(4).CData = hex2rgb('#A7A7A7');
hatchfill2(MM_stack,'single','HatchAngle',hangle,'hatchcolor','black','HatchDensity',hdens);

%PT (mouse 3)
reaches_auto_RPT = readtable('/mnt/66E0A3E3E0A3B827/Photothrombosis_Feb_2022/Validation/Reaches_auto_PT_R_Mouse3.xlsx'); reaches_auto_RPT = table2array(reaches_auto_RPT);
reaches_auto_LPT = readtable('/mnt/66E0A3E3E0A3B827/Photothrombosis_Feb_2022/Validation/Reaches_auto_PT_L_Mouse3.xlsx'); reaches_auto_LPT = table2array(reaches_auto_LPT);
reaches_manual_PT = readtable('/mnt/66E0A3E3E0A3B827/Photothrombosis_Feb_2022/Validation/Reaches_check_manual_Mouse3.xlsx');

reaches_auto_PT = reaches_auto_RPT+reaches_auto_LPT; reaches_man_PT = sum(table2array(reaches_manual_PT),2);
sum_RAPT = sum(reaches_auto_PT); sum_RMPT = sum(reaches_man_PT);

%stacked bar
PTA_stack = bar(pos_M2-d,reaches_auto_PT,'stacked','BarWidth',bwidth,'FaceColor','flat','FaceAlpha',bar_alpha);
PTA_stack(1).CData = hex2rgb('#4d4d4d'); PTA_stack(2).CData = hex2rgb('#A7A7A7'); PTA_stack(3).CData = hex2rgb('#4d4d4d'); PTA_stack(4).CData = hex2rgb('#A7A7A7');

PTM_stack = bar(pos_M2+d,reaches_man_PT,'stacked','BarWidth',bwidth,'FaceColor','flat','FaceAlpha',bar_alpha);
PTM_stack(1).CData = hex2rgb('#4d4d4d'); PTM_stack(2).CData = hex2rgb('#A7A7A7'); PTM_stack(3).CData = hex2rgb('#4d4d4d'); PTM_stack(4).CData = hex2rgb('#A7A7A7');
hatchfill2(PTM_stack,'single','HatchAngle',hangle,'hatchcolor','black','HatchDensity',hdens);

%plot layout
ax = gca; ax.YAxis.FontSize = ticks_font; ax.XAxis.FontSize = ticks_font+1; 
xticks([0.75 1.25 2.25 2.75]); xticklabels({'detected','visual','detected','visual'}); xtickangle(45); yticks([0 200 400 600]); 
ylabel('Reaches','FontSize',axes_font); xlabel('Mouse 1         Mouse 2','FontWeight','bold','FontSize',axes_font);%xlabel({' ',' ','Mice'},'FontSize',axes_font); %title('Sum of all reaches + individual days');
ylm = ylim; %text(pos_Ml-0.2,ylm(1)-40,'MCAO','FontSize',12,'FontWeight','bold'); text(pos_PTl-0.1,ylm(1)-40,'PT','FontSize',12,'FontWeight','bold');
%text(pos_Ml-0.45,ylm(1)-200,'Mouse 1','FontSize',ticks_font,'FontWeight','bold'); text(pos_PTl-0.45,ylm(1)-200,'Mouse 2','FontSize',ticks_font,'FontWeight','bold');
set(gcf,'Position',[1000 1000 current_size],'Color','w'); xlim([0 3.5]); ylim([0 ylm(2)]); %reset y-axis so it starts from 0
%-0.45 -35 %-0.35 -6

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
case 1, figname = "slips_valid";
case 2, figname = "reaches_valid";
end
print(my_figures(f),strcat('/home/nikolaus/Desktop/Matlab_Scripts/Plots/',figname), '-dsvg')
end
end

%validation data
% mean((reaches_auto_M-reaches_man_M')./reaches_man_M')
% mean((reaches_auto_PT-reaches_man_PT')./reaches_man_PT')
% 
% mean((slips_auto_M-slips_man_M')./slips_man_M')
% mean((slips_auto_PT-slips_man_PT')./slips_man_PT')
