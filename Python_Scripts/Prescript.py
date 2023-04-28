
#Pre-script (list the videos)
#in Prescript edit VID_DIR, WORK_DIR, in Preload_script edit NEW_VID_DIR

#VID_DIR is the input video directory folder (REDUNDANT, outcommented)
#WORK_DIR is the output directory of the new DEEPLABCUT project

import os
import time
time.sleep(2)
import deeplabcut
time.sleep(2)
import tensorflow as tf
time.sleep(2) #interface blocks if there is no short break



###import files that you want to train the network on

#VID_DIR = '/home/nikolaus/DLC_Projects/Matej-Versuche-ab2019-10-17/Data_Video_Staircase_grp1/';
WORK_DIR = '/home/nikolaus/DLC_Projects/Matej-Versuche-ab2019-10-17/DLC_Tests/';

#my_files = ['/home/nikolaus/DLC_Projects/Matej-Versuche-ab2019-10-17/Multiple_Trajectory_Analysis/A_00055.mov', #without pellets
#            '/home/nikolaus/DLC_Projects/Matej-Versuche-ab2019-10-17/Multiple_Trajectory_Analysis/B_00064.mov',
#            '/media/nikolaus/66E0A3E3E0A3B827/Matej_Metamizol/d4/20191024_2019-8_G1_d4/M1-4/A_00001.avi', #with pellets
#            '/media/nikolaus/66E0A3E3E0A3B827/Matej_Metamizol/d4/20191024_2019-8_G1_d4/M1-4/B_00001.avi']

my_files = ['/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d4/20191024_2019-8_G1_d4/M9-10/B_00096.avi', #new in 2021 November for new parameter
            '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d4/20191025_2019-8_G2_d4/M1-4/B_00164.avi',
            '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d4/20191025_2019-8_G2_d4/M1-4/B_00165.avi',
            '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191112_2019-8_G2_d14/M1,3,4/A_00019.avi',
            '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191112_2019-8_G2_d14/M1,3,4/B_00012.avi',
            '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191112_2019-8_G2_d14/M5-8/A_00100.avi',
            '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191112_2019-8_G2_d14/M5-8/B_00100.avi',
            '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191111_2019-8_G1_d14/M5-7/B_00103.avi',
            '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191111_2019-8_G1_d14/M5-7/B_00084.avi',
            '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191111_2019-8_G1_d14/M5-7/B_00082.avi',
            '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d7/20191104_2019-8_G1_d7/M9-10/B_00751.avi',
            '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d7/20191105_2019-8_G2_d7/M1,3,4/B_00032.avi',
            '/mnt/66E0A3E3E0A3B827/Videos_without_pellets/A_00057.mov',
            '/mnt/66E0A3E3E0A3B827/Videos_without_pellets/A_00061.mov',
            '/mnt/66E0A3E3E0A3B827/Videos_without_pellets/A_00062.mov',
            '/mnt/66E0A3E3E0A3B827/Videos_without_pellets/A_00064.mov',
            '/mnt/66E0A3E3E0A3B827/Videos_without_pellets/B_00062.mov',
            '/mnt/66E0A3E3E0A3B827/Videos_without_pellets/B_00064.mov',
            '/mnt/66E0A3E3E0A3B827/Videos_without_pellets/B_00065.mov',
            '/mnt/66E0A3E3E0A3B827/Videos_without_pellets/B_00066.mov',
            '/home/nikolaus/DLC_Projects/Matej-Versuche-ab2019-10-17/Multiple_Trajectory_Analysis/A_00055.mov',
            '/media/nikolaus/66E0A3E3E0A3B827/Matej_Metamizol/d4/20191024_2019-8_G1_d4/M1-4/A_00001.avi',
            '/media/nikolaus/66E0A3E3E0A3B827/Matej_Metamizol/d4/20191024_2019-8_G1_d4/M1-4/B_00001.avi']

#my_files = ['/home/nikolaus/DLC_Projects/Matej-Versuche-ab2019-10-17/Data_Video_Staircase_grp1/mice 1-5/17-08/Pilot2-Malika-17-08-G1/avi/A/A_00002.avi']



#################### PART 1: Introduction (enter DLC, create new project, extract frames) ####################


projectName = input('Please enter project name: ');
projectExperimenter = input('Please input the experimenter name: ');
config_path = deeplabcut.create_new_project(projectName, projectExperimenter, my_files, working_directory=WORK_DIR, copy_videos=True);


deeplabcut.extract_frames(config_path, 'automatic','kmeans', crop=False, userfeedback=False);
input('\nWhen ready press enter to split your frames with FrameSplitter. ')



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


#Questions: How to integrate #deeplabcut.add_new_videos(config_file,my_files,copy_videos=True/False) into this?

