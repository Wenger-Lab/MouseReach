table = readtable(''); %big_merge_matrix

for i = 1:size(table,1)
folder = table.Folder(i); file = table.Video(i); vname = strcat(file,'.avi');
%video_loc = strrep(folder, '', ''); 
video_loc = VideoReader(char(strcat(video_loc,'/',vname))); %add next video name out of folder
video = read(video_loc); %update global video

try imadjust(video(:,:,:,table.Frame(i)),[0 0.8],[0 1]); catch, global_time = 0; continue; end %if cannot read global time

output_image = imadjust(video(:,:,:,table.Frame(i)),[0 0.8],[0 1]);
global_time = ReadTime(output_image); disp(global_time);
table.Time(i) = str2double(global_time);
end

%save table
writetable(table, '');