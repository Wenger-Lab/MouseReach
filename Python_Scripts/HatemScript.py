import os
import deeplabcut
import tensorflow as tf
#from AnalyzeTrain import projectLocation
from Preload_script_analyzevideos import NEW_VID_DIR, my_new_files, csv_paths
projectLocation = '/home/nikolaus/DLC_Projects/Matej-Versuche-ab2019-10-17/DLC_Tests/Matej_November21_Triple_Tracking_1'
###################### PART 4: Hatem's script: Analysis of new videos ############################

#change directories
config_template = projectLocation + '/config.yaml';


#NEW_VID_DIR='/home/nikolaus/DLC_Projects/Matej-Versuche-ab2019-10-17/New_Videos/' 

x_combos = [(0,299),(340,639)]
y_combos = [(0,239),(240,479)]

#----------------------------------------
#check if combos match the combos from FrameSplitter 
# The x, y coordinates of the areas to be cropped. (x1, y1, x2, y2), produce 4 pictures
#crop_areas = [(0, 0, 299, 239), (340, 0, 639, 239), (0, 240, 299, 479), (340, 240, 639, 479)];

# xs coordinates, ys coordinates of the Combos (xs, ys) list
#NIKO: Combos are: [((0, 300), (0, 200)), ((0, 300), (280, 479)), ((340, 639), (0, 200)), ((340, 639), (280, 479))]
#list(enumerate(all_combos) = [(0, ((0, 299), (0, 239))),
#                             (1, ((0, 299), (240, 479))),
#                             (2, ((340, 639), (0, 239))),
#                             (3, ((340, 639), (240, 479)))]
#                                   x1    x2    y1    y2
#
#After all_combos[1], all_combos[2] = all_combos[2], all_combos[1] 
#                                [((0, 299), (0, 239)),
#                                 ((340, 639), (0, 239)),
#                                 ((0, 299), (240, 479)),
#                                 ((340, 639), (240, 479))]
#----------------------------------------

from itertools import product
all_combos = list(product(x_combos,y_combos))
#all_combos[1], all_combos[2] = all_combos[2], all_combos[1] #change box order (previously 3,2, now 2,3)
print("Combos are:", all_combos)
#printed all coordinate combinations

#######
#print("Vid dir content:", list(os.walk(NEW_VID_DIR)))
#root, dir, files = list(os.walk(NEW_VID_DIR))[0]
#my_new_files = list(map(lambda fp: root + fp, files))
#
#print("my vid files:", my_new_files) 
##now we have a list of video files
#####

#imported Preload_script_analyzevideos instead of introducing videos


template = open(config_template,'r').read()


#identity x (idx), xs coordinates, ys coordinates of the Combos (xs, ys) list
config_files = []
for idx, (xs, ys) in enumerate(all_combos):
  text = template
  
  #specify the position of x1, x2, y1, y2 with custom coordinates in the text
  n1 = text.find('x1:') #find the position of x1 in text
  linex1 = text[n1:].rsplit('\nx2', 1) #isolate the line to replace into x1[0], x1[1] is the rest of text
  n2 = text.find('x2:')
  linex2 = text[n2:].rsplit('\ny1', 1)
  n3 = text.find('y1:')
  liney1 = text[n3:].rsplit('\ny2', 1)
  n4 = text.find('y2:') #has to be specific enough not to be mistaken with a date or smth else
  liney2 = text[n4:].rsplit('\n\n', 1)
  ncrop = text.find('cropping: ') #make sure cropping is true
  linecrop = text[ncrop:].rsplit('\n#')

  text = text.replace(linex1[0],'x1: ' + str(xs[0]))
  text = text.replace(linex2[0],'x2: ' + str(xs[1]))
  text = text.replace(liney1[0],'y1: ' + str(ys[0]))
  text = text.replace(liney2[0],'y2: ' + str(ys[1]))
  text = text.replace(linecrop[0],'cropping: true')
  config_fp = projectLocation + '/config_' + str(idx) + '.yaml' #change directory (Hatem wrote)
  output_file = open(config_fp, 'w')
  output_file.write(text)
  output_file.close()
  config_files.append(config_fp) #add the new config_n to the list of config files to be used later
 
#--------------------------------------  
#THE POINT of this FOR loop: create 4 config_n.yaml files for the 4 parts of video-to-be-analyzed
#--------------------------------------


#config_files = ['/home/nikolaus/DLC_Projects/Matej-Versuche-ab2019-10-17/DLC_Tests/TestbisHatemScript-Matej-2019-11-19/config_0.yaml',
# '/home/nikolaus/DLC_Projects/Matej-Versuche-ab2019-10-17/DLC_Tests/TestbisHatemScript-Matej-2019-11-19/config_1.yaml',
# '/home/nikolaus/DLC_Projects/Matej-Versuche-ab2019-10-17/DLC_Tests/TestbisHatemScript-Matej-2019-11-19/config_2.yaml',
# '/home/nikolaus/DLC_Projects/Matej-Versuche-ab2019-10-17/DLC_Tests/TestbisHatemScript-Matej-2019-11-19/config_3.yaml']

analyzed_videos = NEW_VID_DIR + 'Tracking_csvs/'  #linked to newroot = root + 'Analyzed_csvs/' in preload
newvideos_list = {}


boxes = 0
for config_file in config_files: 
  #for video file in my_new_files (video list):
  boxes = boxes + 1 
  print("Analyzing videos for combo:", config_file)

  for video in range(0, len(my_new_files)): #separate videos can be analyzed here by reducing the loop and specifying video
      newpath = csv_paths[video].replace(analyzed_videos, analyzed_videos + str(boxes) + '/') + '/' #newline
      
      if not newvideos_list.get(boxes): #collecting all paths where .csv files are found and removing duplicates
         newvideos_list[boxes] = [newpath]
      elif not newpath in newvideos_list[boxes]: #if newpath does not already exist in the dict
         newvideos_list[boxes].append(newpath)
      
      if not os.path.exists(newpath):
          os.makedirs(newpath)
      deeplabcut.analyze_videos(config_file,[my_new_files[video]], save_as_csv=True, destfolder = newpath) 
      #deeplabcut.analyze_videos(config_path,[`/fullpath/project/videos/'], videotype='.mp4', save_as_csv=True)
      
      
#--------------------
#go through all videos and all boxes in those videos (config_n files)
#create 4 folders for 4 config files: box1/folder1, box2/folder2
#--------------------
  
  

#THE POINT of the script:
  #create a list of videos
  #create a list of combos
  #go through combos to create 4 config_n files
  #make a list out of 4 config_n files
  #go through each config_n file and use it as a template for the analysis of a new video box
  #the template tells the network that cropping is True and that it should focus on certain coordinates
  

  
  
  