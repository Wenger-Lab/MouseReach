#add additional videos (TO BE USED ONLY ONCE or delete unused folders in /labeled-data/)
#change importing in FrameSplitter before using the script
import os
import deeplabcut

#to go into FrameSplitter
projectLocation = '/home/nikolaus/DLC_Projects/Matej-Versuche-ab2019-10-17/DLC_Tests/Matej_November21_Triple_Tracking_1' #change this

#list all videos prior to addition of new videos
projectFolder = projectLocation + '/labeled-data/'
videoFiles_old = os.listdir(projectFolder);

#add new videos
# additional_videos = ['/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d4/20191024_2019-8_G1_d4/M9-10/B_00117.avi', #change this
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d4/20191024_2019-8_G1_d4/M9-10/B_00096.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d7/20191105_2019-8_G2_d7/M5-8/B_00034.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d7/20191105_2019-8_G2_d7/M5-8/B_00090.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d21/20191119_2019-8_G2_d21/M1,3,4/A_00001.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d21/20191119_2019-8_G2_d21/M1,3,4/A_00005.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d21/20191119_2019-8_G2_d21/M1,3,4/B_00001.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d21/20191119_2019-8_G2_d21/M1,3,4/A_00031.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d21/20191119_2019-8_G2_d21/M1,3,4/B_00031.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d21/20191119_2019-8_G2_d21/M5-8/A_00080.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d21/20191119_2019-8_G2_d21/M5-8/B_00080.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191119_2019-8_G4_d14/M5-8/A_00162.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191119_2019-8_G4_d14/M5-8/B_00162.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191119_2019-8_G4_d14/M1,2,4/A_00126.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191119_2019-8_G4_d14/M1,2,4/B_00126.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d7/20191111_2019-8_G3_d7/M1-4/A_00039.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d7/20191111_2019-8_G3_d7/M1-4/B_00037.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d7/20191111_2019-8_G3_d7/M9-10/B_00127.avi']




additional_videos = ['/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191119_2019-8_G4_d14/M5-8/B_00162.avi', #grabbing
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191119_2019-8_G4_d14/M5-8/B_00160.avi',
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191119_2019-8_G4_d14/M5-8/B_00141.avi',
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191119_2019-8_G4_d14/M5-8/A_00131.avi',
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191119_2019-8_G4_d14/M5-8/A_00132.avi',
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d4/20191101_2019-8_G4_d4/M1-4/A_00507.avi',
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d7/20191111_2019-8_G3_d7/M9-10/A_00102.avi',
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d7/20191111_2019-8_G3_d7/M9-10/B_00098.avi',
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d7/20191111_2019-8_G3_d7/M9-10/A_00099.avi',
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d21/20191119_2019-8_G2_d21/M5-8/A_00042.avi',
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d21/20191119_2019-8_G2_d21/M5-8/B_00043.avi',
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d21/20191119_2019-8_G2_d21/M5-8/A_00052.avi',
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d21/20191119_2019-8_G2_d21/M5-8/B_00060.avi',
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d21/20191119_2019-8_G2_d21/M5-8/A_00079.avi',
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d21/20191126_2019-8_G4_d21/M4,9-10/A_00232.avi',
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d21/20191126_2019-8_G4_d21/M4,9-10/A_00226.avi',
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d21/20191118_2019-8_G1_d21/M5-7/A_00080.avi',
'/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191111_2019-8_G1_d14/M5-7/A_00072.avi']


# additional_videos = ['/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d4/20191024_2019-8_G1_d4/M9-10/B_00096.avi', #change this variable
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d4/20191025_2019-8_G2_d4/M1-4/B_00164.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d4/20191025_2019-8_G2_d4/M1-4/B_00165.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191112_2019-8_G2_d14/M1,3,4/A_00019.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191112_2019-8_G2_d14/M1,3,4/B_00012.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191112_2019-8_G2_d14/M5-8/A_00100.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191112_2019-8_G2_d14/M5-8/B_00100.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191111_2019-8_G1_d14/M5-7/B_00103.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191111_2019-8_G1_d14/M5-7/B_00084.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d14/20191111_2019-8_G1_d14/M5-7/B_00082.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d7/20191104_2019-8_G1_d7/M9-10/B_00751.avi',
#                      '/mnt/66E0A3E3E0A3B827/Matej_Metamizol/d7/20191105_2019-8_G2_d7/M1,3,4/B_00032.avi',
#                      '/mnt/66E0A3E3E0A3B827/Videos_without_pellets/A_00057.mov',
#                      '/mnt/66E0A3E3E0A3B827/Videos_without_pellets/A_00061.mov',
#                      '/mnt/66E0A3E3E0A3B827/Videos_without_pellets/A_00062.mov',
#                      '/mnt/66E0A3E3E0A3B827/Videos_without_pellets/A_00064.mov',
#                      '/mnt/66E0A3E3E0A3B827/Videos_without_pellets/B_00062.mov',
#                      '/mnt/66E0A3E3E0A3B827/Videos_without_pellets/B_00064.mov',
#                      '/mnt/66E0A3E3E0A3B827/Videos_without_pellets/B_00065.mov',
#                      '/mnt/66E0A3E3E0A3B827/Videos_without_pellets/B_00066.mov']

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
