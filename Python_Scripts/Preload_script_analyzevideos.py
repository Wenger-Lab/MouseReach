import os

NEW_VID_DIR = '/home/user/DLC_Projects/my_data/New_Videos/' #directory of videos-to-be-analyzed

print("Vid dir content:", list(os.walk(NEW_VID_DIR)))
levels = len(list(os.walk(NEW_VID_DIR)))
my_videos = list(range(0, levels)) #placeholder list
new_name_videos = my_videos[:]

#list all videos in all subdirectories
for level in range(0, levels):
    root, dir, files = list(os.walk(NEW_VID_DIR))[level]
    
    if level != 0: #add / to all paths below top level (to be used in my_videos)
        root = root + '/'

    else: #remember a new path for .csv files in first step
        oldroot = root
        newroot = root + 'Tracking_csvs/' #same name has to remain in all scripts      
    
    
    if files == []:
        my_videos[level] = []
        new_name_videos[level] = []
        continue
    else: 
        my_videos[level] = list(map(lambda fp: root + fp, files)); #applies lambda function to every file in files
        #new_name_videos[level] = list(map(lambda fp: root + root.replace('/','-')[1:] + fp, files));
        #os.rename(my_videos, new_name_videos)
    

my_unedited_files = list(filter(None, my_videos)) #take out all empty strings
#my_new_files = list(filter(None, new_name_videos))

flatten = lambda l: [item for sublist in l for item in sublist] #make a single list (not lists out of lists)
my_new_files1 = flatten(my_unedited_files) #this variable goes into DLC
my_new_files2 = list(filter(lambda x: x.endswith('.avi'), my_new_files1))
my_new_files3 = list(filter(lambda y: 'unopenable' not in y, my_new_files2)) #this variable goes into DLC
my_new_files = list(filter(lambda z: '/._' not in z, my_new_files3))
#my_new_files = list(filter(lambda z: VideoFileClip(z).duration < 1, my_new_files3))
future_directories = my_new_files[:]
csv_paths = list(range(0, len(my_new_files)))

for i in range(0, len(my_new_files)): #introducing list of new roots to make new dirs
    future_directories[i] = future_directories[i].replace(oldroot, newroot)
    new_path = os.path.dirname(os.path.abspath(future_directories[i]))
    csv_paths[i] = new_path
    #if not os.path.exists(new_path): #this was creating redundant folder structure - all we need are paths which will be changed in further scripts
        #os.makedirs(new_path)   

#after this is completed there exists the same structure in which the videos are kept in, but for .csv files
#the videos for DLC are linked in my_files
#next step: produce .csvs and store them in their places accordingly