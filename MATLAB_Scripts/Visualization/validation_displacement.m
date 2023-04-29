clear
close all
yes_export = 0;

%MCAO data
huge_merge_matrix_M = readtable('');
experimental_table_M = readtable('','Sheet','Sheet1'); %manual table
pellets_right_M = readtable(''); %automated right
pellets_left_M = readtable(''); %automated left
mouse_list_M = unique(huge_merge_matrix_M.Mouse(strcmp(huge_merge_matrix_M.Trial,'C'))); mouse_list_M(mouse_list_M == 23) = [];
idx_34 = find(mouse_list_M == 34); mouse_list_M(idx_34) = []; pellets_right_M(idx_34,:) = []; pellets_left_M(idx_34,:) = [];

%PT data
huge_merge_matrix_PT = readtable('');
experimental_table_PT = readtable(''); experimental_table_PT.ID = [];
pellets_right_PT = readtable('');
pellets_left_PT = readtable('');
mouse_list_PT = unique(huge_merge_matrix_PT.Mouse(huge_merge_matrix_PT.Trial == 1));

%Sham data
huge_merge_matrix_S = readtable('');
experimental_table_S = readtable('');
pellets_right_S = readtable('');
pellets_left_S = readtable('');
mouse_list_S = unique(huge_merge_matrix_S.Mouse(huge_merge_matrix_S.Trial == 0));

%classic automated detection
pellets_right_M = table2array(pellets_right_M); mean_right_M = mean(pellets_right_M); sem_right_M = std(pellets_right_M)/sqrt(size(pellets_right_M,1)); 
pellets_left_M = table2array(pellets_left_M); mean_left_M = mean(pellets_left_M); sem_left_M = std(pellets_left_M)/sqrt(size(pellets_left_M,1));
pellets_right_PT = table2array(pellets_right_PT); mean_right_PT = mean(pellets_right_PT); sem_right_PT = std(pellets_right_PT)/sqrt(size(pellets_right_PT,1));
pellets_left_PT = table2array(pellets_left_PT); mean_left_PT = mean(pellets_left_PT); sem_left_PT = std(pellets_left_PT)/sqrt(size(pellets_left_PT,1));
pellets_right_S = table2array(pellets_right_S); mean_right_S = mean(pellets_right_S); sem_right_S = std(pellets_right_S)/sqrt(size(pellets_right_S,1)); 
pellets_left_S = table2array(pellets_left_S); mean_left_S = mean(pellets_left_S); sem_left_S = std(pellets_left_S)/sqrt(size(pellets_left_S,1));

%pellets from manual counting
experimental_table_M = experimental_table_M(ismember(experimental_table_M.Mouse,mouse_list_M),:); experimental_table_M.Mouse = [];
experimental_table_PT = experimental_table_PT(ismember(experimental_table_PT.Mouse,mouse_list_PT),:); experimental_table_PT.Mouse = [];
experimental_table_S = experimental_table_S(ismember(experimental_table_S.Mouse,mouse_list_S),:); experimental_table_S.Mouse = [];
mean_table_M = groupsummary(experimental_table_M,"Day","mean"); sem_table_M = groupsummary(experimental_table_M,"Day","std");
mean_table_PT = groupsummary(experimental_table_PT,"Day","mean"); sem_table_PT = groupsummary(experimental_table_PT,"Day","std");
mean_table_S = groupsummary(experimental_table_S,"Day","mean"); sem_table_S = groupsummary(experimental_table_S,"Day","std");
sem_table_M.std_displaced_right = sem_table_M.std_displaced_right/sqrt(sem_table_M.GroupCount(1)); sem_table_M.std_displaced_left = sem_table_M.std_displaced_left/sqrt(sem_table_M.GroupCount(1));
sem_table_PT.std_displaced_right = sem_table_PT.std_displaced_right/sqrt(sem_table_PT.GroupCount(1)); sem_table_PT.std_displaced_left = sem_table_PT.std_displaced_left/sqrt(sem_table_PT.GroupCount(1));
sem_table_S.std_visual_corr_r = sem_table_S.std_visual_corr_r/sqrt(sem_table_S.GroupCount(1)); sem_table_S.std_visual_corr_l = sem_table_S.std_visual_corr_l/sqrt(sem_table_S.GroupCount(1));

%connecting individual markers with a line (automated vs. manual; full)
col_len_M = length(experimental_table_M.Day(experimental_table_M.Day == 1));
col_len_PT = length(experimental_table_PT.Day(experimental_table_PT.Day == 1));
col_len_S = length(experimental_table_S.Day(experimental_table_S.Day == 1));
% separator_M = round(length(jet)/col_len_M)-5; cmap_M = jet; cmap_M = cmap_M(1:separator_M:end,:); %take continuous values from a color palette
% separator_PT = round(length(jet)/col_len_PT)-5; cmap_PT = jet; cmap_PT = cmap_PT(1:separator_PT:end,:);

% %original color setup
% short_jetl = round(length(jet)/2); %short jet length
% separator_M = round(short_jetl/col_len_M); cmap_M = jet; cmap_M = cmap_M(end-short_jetl-20:end-20,:); cmap_M = cmap_M(1:separator_M:end,:); %take continuous values from a color palette
% separator_PT = round(short_jetl/col_len_PT); cmap_PT = jet; cmap_PT = cmap_PT(1+40:short_jetl+40,:); cmap_PT = cmap_PT(1:separator_PT:end,:);

%alternate color setup
short_parula = round(length(parula)/2); short_cool = round(length(cool)/2); short_gray = round(length(gray)/2); %short colormap length
separator_M = round(short_parula/col_len_M); cmap_M = parula; cmap_M = cmap_M(1:1+short_parula,:); cmap_M = brighten(cmap_M(1:separator_M:end,:),-0.2); %take continuous values from a color palette
separator_PT = round(short_cool/col_len_PT); cmap_PT = cool; cmap_PT = cmap_PT(end-short_cool:end,:); cmap_PT = brighten(cmap_PT(1:separator_PT:end,:),-0.4); %additionally darken the color palette
separator_S = round(short_gray/col_len_S); cmap_S = gray; cmap_S = cmap_S(1:1+short_gray,:); cmap_S = brighten(cmap_S(1:separator_S:end,:),0.2);

marker_color_M = repmat(cmap_M(1:col_len_M,:),4,1); marker_color_PT = repmat(cmap_PT(1:col_len_PT,:),4,1); marker_color_S = repmat(cmap_S(1:col_len_S,:),4,1);

%calculate individual markers for day 7 only
right_M_d7 = pellets_right_M(:,3); left_M_d7 = pellets_left_M(:,3);
manual_M_d7 = experimental_table_M(experimental_table_M.Day == 3,:);
right_PT_d7 = pellets_right_PT(:,3); left_PT_d7 = pellets_left_PT(:,3);
manual_PT_d7 = experimental_table_PT(experimental_table_PT.Day == 3,:);
right_S_d7 = pellets_right_S(:,3); left_S_d7 = pellets_left_S(:,3);
manual_S_d7 = experimental_table_S(experimental_table_S.Day == 3,:);

%model marker colors in the same order as pellets removed
marker_M_d7 = marker_color_M(1:size(right_M_d7,1),:); %change direction of color change with flip(optional)
marker_PT_d7 = marker_color_PT(1:size(right_PT_d7,1),:); 
marker_S_d7 = marker_color_S(1:size(right_S_d7,1),:);

%right
rMd7_unique = [(1:length(right_M_d7))' right_M_d7]; rMd7_unique = sortrows(rMd7_unique,2); %now colors change from bottom to top
rmMd7_unique = [rMd7_unique(:,1) marker_M_d7]; rmMd7_unique = sortrows(rmMd7_unique,1); marker_M_d7r = rmMd7_unique(:,2:end);
rPTd7_unique = [(1:length(right_PT_d7))' right_PT_d7]; rPTd7_unique = sortrows(rPTd7_unique,2);
rmPTd7_unique = [rPTd7_unique(:,1) marker_PT_d7]; rmPTd7_unique = sortrows(rmPTd7_unique,1); marker_PT_d7r = rmPTd7_unique(:,2:end); 
rSd7_unique = [(1:length(right_S_d7))' right_S_d7]; rSd7_unique = sortrows(rSd7_unique,2);
rmSd7_unique = [rSd7_unique(:,1) marker_S_d7]; rmSd7_unique = sortrows(rmSd7_unique,1); marker_S_d7r = rmSd7_unique(:,2:end);
%left
lMd7_unique = [(1:length(left_M_d7))' left_M_d7]; lMd7_unique = sortrows(lMd7_unique,2); %now colors change from bottom to top
lmMd7_unique = [lMd7_unique(:,1) marker_M_d7]; lmMd7_unique = sortrows(lmMd7_unique,1); marker_M_d7l = lmMd7_unique(:,2:end);
lPTd7_unique = [(1:length(left_PT_d7))' left_PT_d7]; lPTd7_unique = sortrows(lPTd7_unique,2);
lmPTd7_unique = [lPTd7_unique(:,1) marker_PT_d7]; lmPTd7_unique = sortrows(lmPTd7_unique,1); marker_PT_d7l = lmPTd7_unique(:,2:end);
lSd7_unique = [(1:length(left_S_d7))' left_S_d7]; lSd7_unique = sortrows(lSd7_unique,2);
lmSd7_unique = [lSd7_unique(:,1) marker_S_d7]; lmSd7_unique = sortrows(lmSd7_unique,1); marker_S_d7l = lmSd7_unique(:,2:end);

%plot parameters
pos_Mr = 4.5*ones(size(right_M_d7,1),1); pos_Ml = 1*ones(size(right_M_d7,1),1); %dataset positions on x-axis
pos_PTr = 6*ones(size(right_PT_d7,1),1); pos_PTl = 2.5*ones(size(right_PT_d7,1),1); %6 8 10 and 1 3 5
% pos_Sr = 9*ones(size(right_S_d7,1),1); pos_Sl = 4*ones(size(right_S_d7,1),1); %pos_Mr = 6; pos_PTR = 7.5; with sham
d = 0.25; %distance from center
bwidth = 0.4; hangle = 78; bline = '-'; %bline = 'none'; 
M_bcolor = "#1A85FF"; PT_bcolor = "#c20064"; S_bcolor = "#A7A7A7"; %BLUE MAGENTA
%M_bcolor = "#004c64"; PT_bcolor = "#f45c43"; GREEN ORANGE %M_bcolor = "#0d7eb1"; PT_bcolor = "#02d1bc"; GREEN CYAN %M_bcolor = "#1A85FF"; PT_bcolor = "#D41159"; BLUE RED
marker = 'o'; marker_sz = 12; marker_alpha = 0.3; marker_line = 1.2;
hdens = 80; eb_linewidth = 2; bar_alpha = 0.8; %not the same hdens and hangle as in reaches and slips due to size!
ticks_font = 8; axes_font = 10; 

%figure parameters
publication_size = [510 300]; %default [300 220] or 8x6 cm
current_size = publication_size;

%plot BAR and ERRORBAR
hold on;
%right hand
%MCAO
b_auto_Mr = bar(pos_Mr(1)-d,mean_right_M(3)); b_auto_Mr.FaceColor = M_bcolor; b_auto_Mr.BarWidth = bwidth; b_auto_Mr.LineStyle = bline; b_auto_Mr.FaceAlpha = bar_alpha;
b_man_Mr = bar(pos_Mr(1)+d,mean_table_M.mean_displaced_right(mean_table_M.Day == 3)); b_man_Mr.FaceColor = M_bcolor; b_man_Mr.BarWidth = bwidth; b_man_Mr.LineStyle = bline;
b_man_Mr.FaceAlpha = bar_alpha; hatchfill2(b_man_Mr,'single','HatchAngle',hangle,'hatchcolor','black','HatchDensity',hdens);
eb_auto_Mr = errorbar(pos_Mr(1)-d,mean_right_M(3),[],sem_right_M(3)); eb_auto_Mr.Color = M_bcolor; eb_auto_Mr.LineWidth = eb_linewidth;
eb_man_Mr = errorbar(pos_Mr(1)+d,mean_table_M.mean_displaced_right(mean_table_M.Day == 3),[],sem_table_M.std_displaced_right(sem_table_M.Day == 3)); eb_man_Mr.Color = M_bcolor; eb_man_Mr.LineWidth = eb_linewidth;
%PT
b_auto_PTr = bar(pos_PTr(1)-d,mean_right_PT(3)); b_auto_PTr.FaceColor = PT_bcolor; b_auto_PTr.BarWidth = bwidth; b_auto_PTr.LineStyle = bline; b_auto_PTr.FaceAlpha = bar_alpha;
b_man_PTr = bar(pos_PTr(1)+d,mean_table_PT.mean_displaced_right(mean_table_PT.Day == 3)); b_man_PTr.FaceColor = PT_bcolor; b_man_PTr.BarWidth = bwidth; b_man_PTr.LineStyle = bline;
b_man_PTr.FaceAlpha = bar_alpha; hatchfill2(b_man_PTr,'single','HatchAngle',hangle,'hatchcolor','black','HatchDensity',hdens);
eb_auto_PTr = errorbar(pos_PTr(1)-d,mean_right_PT(3),[],sem_right_PT(3)); eb_auto_PTr.Color = PT_bcolor; eb_auto_PTr.LineWidth = eb_linewidth;
eb_man_PTr = errorbar(pos_PTr(1)+d,mean_table_PT.mean_displaced_right(mean_table_PT.Day == 3),[],sem_table_PT.std_displaced_right(sem_table_PT.Day == 3)); eb_man_PTr.Color = PT_bcolor; eb_man_PTr.LineWidth = eb_linewidth;
%Sham
% b_auto_Sr = bar(pos_Sr(1)-d,mean_right_S(3)); b_auto_Sr.FaceColor = S_bcolor; b_auto_Sr.BarWidth = bwidth; b_auto_Sr.LineStyle = bline; b_auto_Sr.FaceAlpha = bar_alpha;
% b_man_Sr = bar(pos_Sr(1)+d,mean_table_S.mean_visual_corr_r(mean_table_S.Day == 3)); b_man_Sr.FaceColor = S_bcolor; b_man_Sr.BarWidth = bwidth; b_man_Sr.LineStyle = bline;
% b_man_Sr.FaceAlpha = bar_alpha; hatchfill2(b_man_Sr,'single','HatchAngle',hangle,'hatchcolor','black','HatchDensity',hdens);
% eb_auto_Sr = errorbar(pos_Sr(1)-d,mean_right_S(3),[],sem_right_S(3)); eb_auto_Sr.Color = S_bcolor; eb_auto_Sr.LineWidth = eb_linewidth;
% eb_man_Sr = errorbar(pos_Sr(1)+d,mean_table_S.mean_visual_corr_r(mean_table_S.Day == 3),[],sem_table_S.std_visual_corr_r(sem_table_S.Day == 3)); eb_man_Sr.Color = S_bcolor; eb_man_Sr.LineWidth = eb_linewidth;

%left hand
%MCAO
b_auto_Ml = bar(pos_Ml(1)-d,mean_left_M(3)); b_auto_Ml.FaceColor = M_bcolor; b_auto_Ml.BarWidth = bwidth; b_auto_Ml.LineStyle = bline; b_auto_Ml.FaceAlpha = bar_alpha;
b_man_Ml = bar(pos_Ml(1)+d,mean_table_M.mean_displaced_left(mean_table_M.Day == 3)); b_man_Ml.FaceColor = M_bcolor; b_man_Ml.BarWidth = bwidth; b_man_Ml.LineStyle = bline;
b_man_Ml.FaceAlpha = bar_alpha; hatchfill2(b_man_Ml,'single','HatchAngle',hangle,'hatchcolor','black','HatchDensity',hdens);
eb_auto_Ml = errorbar(pos_Ml(1)-d,mean_left_M(3),[],sem_left_M(3)); eb_auto_Ml.Color = M_bcolor; eb_auto_Ml.LineWidth = eb_linewidth;
eb_man_Ml = errorbar(pos_Ml(1)+d,mean_table_M.mean_displaced_left(mean_table_M.Day == 3),[],sem_table_M.std_displaced_left(sem_table_M.Day == 3)); eb_man_Ml.Color = M_bcolor; eb_man_Ml.LineWidth = eb_linewidth;
%PT
b_auto_PTl = bar(pos_PTl(1)-d,mean_left_PT(3)); b_auto_PTl.FaceColor = PT_bcolor; b_auto_PTl.BarWidth = bwidth; b_auto_PTl.LineStyle = bline; b_auto_PTl.FaceAlpha = bar_alpha;
b_man_PTl = bar(pos_PTl(1)+d,mean_table_PT.mean_displaced_left(mean_table_PT.Day == 3)); b_man_PTl.FaceColor = PT_bcolor; b_man_PTl.BarWidth = bwidth; b_man_PTl.LineStyle = bline;
b_man_PTl.FaceAlpha = bar_alpha; hatchfill2(b_man_PTl,'single','HatchAngle',hangle,'hatchcolor','black','HatchDensity',hdens);
eb_auto_PTl = errorbar(pos_PTl(1)-d,mean_left_PT(3),[],sem_left_PT(3)); eb_auto_PTl.Color = PT_bcolor; eb_auto_PTl.LineWidth = eb_linewidth;
eb_man_PTl = errorbar(pos_PTl(1)+d,mean_table_PT.mean_displaced_left(mean_table_PT.Day == 3),[],sem_table_PT.std_displaced_left(sem_table_PT.Day == 3)); eb_man_PTl.Color = PT_bcolor; eb_man_PTl.LineWidth = eb_linewidth;
%Sham
% b_auto_Sl = bar(pos_Sl(1)-d,mean_left_S(3)); b_auto_Sl.FaceColor = S_bcolor; b_auto_Sl.BarWidth = bwidth; b_auto_Sl.LineStyle = bline; b_auto_Sl.FaceAlpha = bar_alpha;
% b_man_Sl = bar(pos_Sl(1)+d,mean_table_S.mean_visual_corr_l(mean_table_S.Day == 3)); b_man_Sl.FaceColor = S_bcolor; b_man_Sl.BarWidth = bwidth; b_man_Sl.LineStyle = bline;
% b_man_Sl.FaceAlpha = bar_alpha; hatchfill2(b_man_Sl,'single','HatchAngle',hangle,'hatchcolor','black','HatchDensity',hdens);
% eb_auto_Sl = errorbar(pos_Sl(1)-d,mean_left_S(3),[],sem_left_S(3)); eb_auto_Sl.Color = S_bcolor; eb_auto_Sl.LineWidth = eb_linewidth;
% eb_man_Sl = errorbar(pos_Sl(1)+d,mean_table_S.mean_visual_corr_l(mean_table_S.Day == 3),[],sem_table_S.std_visual_corr_l(sem_table_S.Day == 3)); eb_man_Sl.Color = S_bcolor; eb_man_Sl.LineWidth = eb_linewidth;

%plot INDIVIDUAL MARKERS on top
%rMd_spacing = [6 4-0.2 4 4+0.2 3-0.1 3+0.1 7-0.1 6 2 5 7+0.1]; rPTd_spacing = [4 7 6-0.2 6+0.2 3-0.1 6 5-0.1 3+0.1 5+0.1];
%lMd_spacing = [6-0.2 4-0.2 5-0.2 5 4 6 7-0.1 5+0.2 4+0.2 6+0.2 7+0.1]; lPTd_spacing = [6-0.4 6-0.2 6 7-0.2 5-0.1 7 5+0.1 6+0.2 7+0.2];
%lSd_spacing = [5-0.1 4-0.1 2-0.2 5+0.1 2 4+0.1 3-0.1 3+0.1 2+0.2 6]'; rSd_spacing = [5-0.1 4-0.1 2-0.1 6-0.1 5+0.1 3-0.1 3+0.1 4+0.1 6+0.1 2+0.1]';
rMd_spacing = [-0.1 -0.2 0 0.2 -0.1 0.1 -0.1 0.1 0 0.1]'; rPTd_spacing = [0 0 -0.2 0.2 -0.1 0 -0.1 0.1 0.1]'; rSd_spacing = [-0.1 -0.1 -0.1 -0.1 0.3 0.1 0.1 0.1 0.1 0.1]';
lMd_spacing = [-0.2 -0.2 -0.2 0 0 0 -0.1 0.2 0.2 0.1]'; lPTd_spacing = [-0.4 -0.2 0 -0.2 -0.1 0 0.1 0.2 0.2]'; lSd_spacing = [-0.1 -0.1 -0.2 0.1 0 0.3 -0.1 0.1 0.2 0]';
overlap_Mr = rMd_spacing; overlap_PTr = rPTd_spacing; overlap_Sr = rSd_spacing; overlap_Ml = lMd_spacing; overlap_PTl = lPTd_spacing; overlap_Sl = lSd_spacing;

% spacing_sample = [0.15 0.2 0.25 0.3 0.35 0.4 -0.15 -0.2 -0.25 -0.3 -0.35 -0.4];
% overlap_M = randsample(spacing_sample,size(right_M_d7,1),true)';
% overlap_PT = randsample(spacing_sample,size(right_PT_d7,1),true)';

% overlap_M = rand(size(right_M_d7,1),1)-0.5; %scattering y_variable to distinguish between overlapping points
% overlap_PT = rand(size(right_PT_d7,1),1)-0.5;

%right hand
%MCAO
scatter(pos_Mr-d,right_M_d7+overlap_Mr,marker_sz,marker_M_d7r,'filled','MarkerFaceAlpha',marker_alpha); %filling
scatter(pos_Mr-d,right_M_d7+overlap_Mr,marker_sz,marker_M_d7r,marker,'LineWidth',marker_line); %circles
scatter(pos_Mr+d,manual_M_d7.displaced_right+overlap_Mr,marker_sz,marker_M_d7r,'filled','MarkerFaceAlpha',marker_alpha); %filling
scatter(pos_Mr+d,manual_M_d7.displaced_right+overlap_Mr,marker_sz,marker_M_d7r,marker,'LineWidth',marker_line); %circles
for i = 1:size(right_M_d7,1)
line([pos_Mr-d pos_Mr+d], [right_M_d7(i)+overlap_Mr(i) manual_M_d7.displaced_right(i)+overlap_Mr(i)],'Color',marker_M_d7r(i,:))
end

%PT
scatter(pos_PTr-d,right_PT_d7+overlap_PTr,marker_sz,marker_PT_d7r,'filled','MarkerFaceAlpha',marker_alpha); 
scatter(pos_PTr-d,right_PT_d7+overlap_PTr,marker_sz,marker_PT_d7r,marker,'LineWidth',marker_line); %plot PT day 7
scatter(pos_PTr+d,manual_PT_d7.displaced_right+overlap_PTr,marker_sz,marker_PT_d7r,'filled','MarkerFaceAlpha',marker_alpha);
scatter(pos_PTr+d,manual_PT_d7.displaced_right+overlap_PTr,marker_sz,marker_PT_d7r,marker,'LineWidth',marker_line);
for i = 1:size(right_PT_d7,1)
line([pos_PTr-d pos_PTr+d], [right_PT_d7(i)+overlap_PTr(i) manual_PT_d7.displaced_right(i)+overlap_PTr(i)],'Color',marker_PT_d7r(i,:))
end

%Sham
% scatter(pos_Sr-d,right_S_d7+overlap_Sr,marker_sz,marker_S_d7r,'filled','MarkerFaceAlpha',marker_alpha); %filling
% scatter(pos_Sr-d,right_S_d7+overlap_Sr,marker_sz,marker_S_d7r,marker,'LineWidth',marker_line); %circles
% scatter(pos_Sr+d,manual_S_d7.visual_corr_r+overlap_Sr,marker_sz,marker_S_d7r,'filled','MarkerFaceAlpha',marker_alpha); %filling
% scatter(pos_Sr+d,manual_S_d7.visual_corr_r+overlap_Sr,marker_sz,marker_S_d7r,marker,'LineWidth',marker_line); %circles
% for i = 1:size(right_S_d7,1)
% line([pos_Sr-d pos_Sr+d], [right_S_d7(i)+overlap_Sr(i) manual_S_d7.visual_corr_r(i)+overlap_Sr(i)],'Color',marker_S_d7r(i,:))
% end

%left hand
%MCAO
scatter(pos_Ml-d,left_M_d7+overlap_Ml,marker_sz,marker_M_d7l,'filled','MarkerFaceAlpha',marker_alpha);
scatter(pos_Ml-d,left_M_d7+overlap_Ml,marker_sz,marker_M_d7l,marker,'LineWidth',marker_line); %plot MCAO day 7
scatter(pos_Ml+d,manual_M_d7.displaced_left+overlap_Ml,marker_sz,marker_M_d7l,'filled','MarkerFaceAlpha',marker_alpha);
scatter(pos_Ml+d,manual_M_d7.displaced_left+overlap_Ml,marker_sz,marker_M_d7l,marker,'LineWidth',marker_line);
for i = 1:size(left_M_d7,1)
line([pos_Ml-d pos_Ml+d], [left_M_d7(i)+overlap_Ml(i) manual_M_d7.displaced_left(i)+overlap_Ml(i)],'Color',marker_M_d7l(i,:))
end

%PT
scatter(pos_PTl-d,left_PT_d7+overlap_PTl,marker_sz,marker_PT_d7l,'filled','MarkerFaceAlpha',marker_alpha);
scatter(pos_PTl-d,left_PT_d7+overlap_PTl,marker_sz,marker_PT_d7l,marker,'LineWidth',marker_line); %plot PT day 7
scatter(pos_PTl+d,manual_PT_d7.displaced_left+overlap_PTl,marker_sz,marker_PT_d7l,'filled','MarkerFaceAlpha',marker_alpha);
scatter(pos_PTl+d,manual_PT_d7.displaced_left+overlap_PTl,marker_sz,marker_PT_d7l,marker,'LineWidth',marker_line);
for i = 1:size(left_PT_d7,1)
line([pos_PTl-d pos_PTl+d], [left_PT_d7(i)+overlap_PTl(i) manual_PT_d7.displaced_left(i)+overlap_PTl(i)],'Color',marker_PT_d7l(i,:))
end

%Sham
% scatter(pos_Sl-d,left_S_d7+overlap_Sl,marker_sz,marker_S_d7l,'filled','MarkerFaceAlpha',marker_alpha);
% scatter(pos_Sl-d,left_S_d7+overlap_Sl,marker_sz,marker_S_d7l,marker,'LineWidth',marker_line); %plot MCAO day 7
% scatter(pos_Sl+d,manual_S_d7.visual_corr_l+overlap_Sl,marker_sz,marker_S_d7l,'filled','MarkerFaceAlpha',marker_alpha);
% scatter(pos_Sl+d,manual_S_d7.visual_corr_l+overlap_Sl,marker_sz,marker_S_d7l,marker,'LineWidth',marker_line);
% for i = 1:size(left_S_d7,1)
% line([pos_Sl-d pos_Sl+d], [left_S_d7(i)+overlap_Sl(i) manual_S_d7.visual_corr_l(i)+overlap_Sl(i)],'Color',marker_S_d7l(i,:))
% end

ax = gca; ax.YAxis.FontSize = ticks_font; ax.XAxis.FontSize = ticks_font+1; 
ylabel('Displaced pellets','FontSize',axes_font); xlabel({' ',' '},'FontSize',axes_font); yticks([0 2 4 6 8]); xtickangle(45);
xticks([0.8 1.25 2.25 2.75 4.25 4.75 5.75 6.25]);% xticks([0.75 1.25 2.25 2.75 3.75 4.25 5.75 6.25 7.25 7.75 8.75 9.25]);
%xticklabels({'detected','visual','detected','visual','detected','visual','detected','visual','detected','visual','detected','visual'});
xticklabels({'detected','visual','detected','visual','detected','visual','detected','visual'});
xlm = xlim; ylm = ylim; %title('left hand','Position',[mean(xlm)/2 ylm(2)]); %title('right hand','Position',[mean(xlm)*1.5 ylm(2)]);
text(0.5,ylm(2)+0.4,'Ipsilesional hand','FontSize',axes_font,'FontWeight','bold'); text(4,ylm(2)+0.4,'Contralesional hand','FontSize',axes_font,'FontWeight','bold'); %upper text %with sham, 1.5 and 6.5
text(pos_Ml(1)-0.38,-4.6,'MCAO','FontSize',axes_font,'FontWeight','bold'); text(pos_Mr(1)-0.38,-4.6,'MCAO','FontSize',axes_font,'FontWeight','bold'); %lower text MCAO
text(pos_PTl(1)-0.15,-4.6,'PT','FontSize',axes_font,'FontWeight','bold'); text(pos_PTr(1)-0.15,-4.6,'PT','FontSize',axes_font,'FontWeight','bold'); %lower text PT
%text(pos_Sl(1)-0.38,-2.6,'Sham','FontSize',axes_font,'FontWeight','bold'); text(pos_Sr(1)-0.38,-2.6,'Sham','FontSize',axes_font,'FontWeight','bold'); %lower text Sham
set(gcf,'Position',[200 1000 current_size],'Color','w'); ylim([0 ylm(2)]);

%export all figures
% if yes_export == 1
% export_fig(gcf,'/home/nikolaus/Desktop/Matlab_Scripts/Plots/plots','-pdf','-append')
% end

if yes_export == 1
my_figures = findobj('Type','Figure');
for f = 1:length(my_figures)
figname = 'pellet_displ';
print(my_figures(f),strcat('/home/nikolaus/Desktop/Matlab_Scripts/Plots/',figname), '-dsvg')
end
end
