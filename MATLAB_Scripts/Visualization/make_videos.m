clear
close all

%path
video_loc = ''; %video location
csv_loc = ''; %csv location

%video
video_file = VideoReader(video_loc); %add next video name out of folder
video = read(video_file); 

%csv
csv_file = readtable(csv_loc); %find video csv file

%pellets
pellet_coords = zeros(8,3,4); pellet_coords(1:8,1,1:4) = repmat([1;2;3;4;5;6;7;8],1,4);
cup = zeros(4,2); cdown = zeros(4,2); cdown_t = zeros(4,1);
corr_value = 10; %+corr_value because length of pellet pocket is ca. 5 pixels away from corner

for box = 1:4
%calculate average upper and lower corner vars
cup_index = find(strcmp(csv_file.bodyparts,'CornerUp') & csv_file.likelihood > 0.999 & csv_file.box == box);
cup(box,:) = [mean(csv_file.x(cup_index)), mean(csv_file.y(cup_index))];
cdown_index = find(strcmp(csv_file.bodyparts,'CornerDown') & csv_file.likelihood > 0.999 & csv_file.box == box);
cdown(box,:) = [mean(csv_file.x(cdown_index)), mean(csv_file.y(cdown_index))];
cdown_t(box) = cdown(box,2)+20; %used to position markers in a tab on screen

%determine static pellet coords to display a pellet that has low probability
if cup(box,1) > cdown(box,1) %determine orientation of box; if xup > xdown
pellet_coords(1,2,box) = cup(box,1)-corr_value; pellet_coords(1,3,box) = cup(box,2);
pellet_coords(8,2,box) = cdown(box,1)+corr_value; pellet_coords(8,3,box) = cdown(box,2);
elseif cup(box,1) < cdown(box,1)
pellet_coords(1,2,box) = cup(box,1)+corr_value; pellet_coords(1,3,box) = cup(box,2);
pellet_coords(8,2,box) = cdown(box,1)-corr_value; pellet_coords(8,3,box) = cdown(box,2);
end
end %end box

cdown_t = [repmat(cdown_t(1),8,1) repmat(cdown_t(2),8,1) repmat(cdown_t(3),8,1) repmat(cdown_t(4),8,1)]; %reshapes cdown_t into 8x2 matrix (for plotting)
pellet_coords(pellet_coords == 0) = NaN;
pellet_coords = fillmissing(pellet_coords, 'linear');

%run video frame-by-frame
for dlc_frame = csv_file.frames(1):csv_file.frames(end) %180:200
disp(dlc_frame)

frame = dlc_frame + 1; %real frame and DLC frame have different indices
figure('visible', 'off') %so individual pictures do not show up and lag
imshow(video(:,:,:,frame)) %'show' the current frame so you can plot on it
hold on %prepare for plotting

for box = 1:4

%plot trajectory
plot(gca, csv_file.x(csv_file.frames==frame & strcmp(csv_file.bodyparts,'Hand') & csv_file.box == box & csv_file.likelihood > 0.999),...
csv_file.y(csv_file.frames==frame & strcmp(csv_file.bodyparts,'Hand') & csv_file.box == box & csv_file.likelihood > 0.999),'.r','MarkerSize',20);

plot(gca, csv_file.x(csv_file.frames > max(frame-20, min(csv_file.frames)) & csv_file.frames < min(frame+20, max(csv_file.frames))...
 & csv_file.box == box & csv_file.likelihood > 0.999 & strcmp(csv_file.bodyparts,'Hand')),...
csv_file.y(csv_file.frames > max(frame-20, min(csv_file.frames)) & csv_file.frames < min(frame+20, max(csv_file.frames))...
 & csv_file.box == box & csv_file.likelihood > 0.999 & strcmp(csv_file.bodyparts,'Hand')),'-r','LineWidth',1);

%plot pellet status
for pellet = 1:8
pellet_name = strcat('Pellet',string(pellet));
pellet_index = find(strcmp(csv_file.bodyparts,pellet_name) & csv_file.frames == frame & csv_file.box == box & csv_file.likelihood > 0.999);

if ~isempty(pellet_index)
pellet_coords(pellet,2,box) = csv_file.x(pellet_index); pellet_coords(pellet,3,box) = csv_file.y(pellet_index);
pellet_coords(pellet,4,box) = 1; %set 4th column value to 1 = green light
else, pellet_coords(pellet,4,box) = 0; %red light
end
end

[grpell_idx,~] = find(pellet_coords(:,4,box) == 1); [redpell_idx,~] = find(pellet_coords(:,4,box) ~= 1);

plot(gca,pellet_coords(grpell_idx,2,box),cdown_t(grpell_idx,box),'ks','MarkerSize',10,'MarkerFaceColor','green');
plot(gca,pellet_coords(redpell_idx,2,box),cdown_t(redpell_idx,box),'ks','MarkerSize',10,'MarkerFaceColor','red');

%store the frame
F(frame) = getframe(gcf);
drawnow %update the gcf (necessary?)

end %end box

close gcf
end %end frames

%https://de.mathworks.com/matlabcentral/answers/84951-make-movie-without-displaying-figures-using-videowriter

% create the video writer with 1 fps
writerObj = VideoWriter('/home/nikolaus/Desktop/Matlab_Scripts/Plots/myVideo.avi');
writerObj.FrameRate = 25; %set the seconds per image %10

% open the video writer
open(writerObj);

% write the frames to the video
for i=1:length(F)

current_frame = F(i); %convert the image to a frame  

writeVideo(writerObj, current_frame);

end

% close the writer object
close(writerObj);