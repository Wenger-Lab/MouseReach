clear all
table = readtable(''); %big_merge_matrix%
%table.Folder = strrep(table.Folder, '', '');

for i = 1:size(table,1)
folder = table.Folder(i); file = table.Video(i); csv_name = strcat(file,'.csv');
%csv_loc = strrep(folder, '', ''); 
csv_loc = char(strcat(csv_loc,'/',csv_name));
csv = readtable(csv_loc);

frame = table.Frame(i);
pellet = table.Pellet(i); pellet = strcat('Pellet',string(pellet));
box = table.Box(i);
likelihood = max(csv.likelihood((csv.frames >= frame-30 & csv.frames <= frame-10) & strcmp(csv.bodyparts, pellet) & csv.box == box));

if likelihood >= 0.9, table.Pocket(i) = {'full'}; else, table.Pocket(i) = {'empty'}; end

end

writetable(table,'');