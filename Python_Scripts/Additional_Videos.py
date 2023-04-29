#add additional videos to the network to be re-trained
#change importing in FrameSplitter before using the script to Split these particular videos only

import os
import deeplabcut

#to go into FrameSplitter
projectLocation = '/home/user/DLC_Projects/my_project' #change this

#list all videos prior to addition of new videos
projectFolder = projectLocation + '/labeled-data/'
videoFiles_old = os.listdir(projectFolder);

#add new videos
additional_videos = ['/user/additional_videos/video1.avi', '/user/additional_videos/video2.avi']

config_path = projectLocation + '/config.yaml'
deeplabcut.add_new_videos(config_path, additional_videos, copy_videos=True)

#update list with new videos
videoFiles_new = os.listdir(projectFolder);

#create a new list with only new videos
videoFiles = []
for video_folder in videoFiles_new:
    if video_folder not in videoFiles_old:
        videoFiles.append(video_folder)


#add rescuedimagesFolder path for FrameSplitter
rescuedimagesFolder = projectLocation + '/rescued-images-patch/'

#extract new frames
deeplabcut.extract_frames(config_path, 'automatic','kmeans', crop=False, userfeedback=True); #userfeedback=True ! to select new videos

#now only new videos should be edited by the FrameSplitter
