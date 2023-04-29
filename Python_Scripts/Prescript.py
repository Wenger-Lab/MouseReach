
#Pre-script (list the videos)
#WORK_DIR is the output directory of the new DEEPLABCUT project

import os
import time
#time.sleep(2)
import deeplabcut
#time.sleep(2)
import tensorflow as tf
#time.sleep(2) #in case the interface blocks, make short pauses inbetween

#import files that you want to train the network on
WORK_DIR = '/home/user/DLC_Projects/My_project/';
my_files = ['example/day/group/subgroup/video1.avi', 'example/day/group/subgroup/video2.avi']

#################### PART 1: Introduction (enter DLC, create new project, extract frames) ####################

projectName = input('Please enter project name: ');
projectExperimenter = input('Please input the experimenter name: ');
config_path = deeplabcut.create_new_project(projectName, projectExperimenter, my_files, working_directory=WORK_DIR, copy_videos=True);

deeplabcut.extract_frames(config_path, 'automatic','kmeans', crop=False, userfeedback=False); #use DLC to extract initial frames from videos

#import date for filename
from datetime import date
today = date.today();
# dd-mm-YY
dateFormat = today.strftime("%Y-%m-%d");

projectLocation = WORK_DIR + projectName + '-' + projectExperimenter + '-' + dateFormat;
projectFolder = projectLocation + '/labeled-data/';
videoFiles = os.listdir(projectFolder); #folders of frames, not videos; referring to extracted frames

#rescued original frames
rescuedimagesFolder = projectLocation + '/rescued-images-patch/';
os.mkdir(rescuedimagesFolder);

input('\nWhen ready press enter to split your frames with FrameSplitter. ') #continue to the next script (FrameSplitter)
