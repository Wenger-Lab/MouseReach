import os
import deeplabcut
import tensorflow as tf

#in case this is first run, uncomment 'Prescript', in case you're adding videos, uncomment 'Additional_Videos'
from Prescript import videoFiles, projectFolder, rescuedimagesFolder, projectLocation, config_path
#from Additional_Videos import videoFiles, projectFolder, rescuedimagesFolder, projectLocation, config_path


####################### PART 2: Frame-splitting ###########################


######Image module and cropping function defined outside the FOR loop###### 
from PIL import Image
from skimage.metrics import structural_similarity as ssim 
import numpy

# The x, y coordinates of the areas to be cropped. (x1, y1, x2, y2), produce 4 pictures
#crop_areas = [(0, 0, 299, 239), (340, 0, 639, 239), (0, 240, 299, 479), (340, 240, 639, 479)];
crop_areas = [(0, 0, 299, 239), (0, 240, 299, 479), (340, 0, 639, 239),  (340, 240, 639, 479)];

#measure time (optional)
#import time
#t = time.time()

##########LOOP 1: First FOR loop, go through all x video directories (each contains y frames)
for x in range(0, len(videoFiles)):
    myfolder_temporary = projectFolder + videoFiles[x] #directory where splitted images will be saved
    if not os.path.exists(rescuedimagesFolder + videoFiles[x]):
        os.mkdir(rescuedimagesFolder + videoFiles[x]) #make rescued frames folder for each video file


    #list all of the frames inside the folder of x-th video
    framesList = os.listdir(myfolder_temporary);
    #have the frames been extracted? if not, move on to the next video file
    if framesList == []:
        continue
    
    
    temporary = {} #empty dictionary

    #########LOOP 2: FOR each extracted frame go through the splitting process
    for y in range(0, len(framesList)):
        
        image_name = myfolder_temporary + '/' + framesList[y]; #function needs full directory
        #for testing image_name = '/home/user/directory/image.PNG';
        img = Image.open(image_name);
        

        #######LOOP 3: Loops through the "crop_areas" list and crops the image based on the coordinates in the list
        for i, crop_area in enumerate(crop_areas): #enumerate('strings', starting number) adds a number to each string or character
            filename = os.path.splitext(image_name)[0] #splits image.jpg into image(0) && .png(1)
            ext = os.path.splitext(image_name)[1]
            new_filename = myfolder_temporary + '/' + str(i+1) + '_' + os.path.basename(os.path.normpath(filename)) + ext #make new name
            #crop the original image (img)
            cropped_image = img.crop(crop_area)
            temporary[y,i] = cropped_image #store image to a temporary variable
            #cropped_image.save(temporary[y][i]) 
                        
            #compare images
            if y == 0:
                cropped_image.save(new_filename) #save immediately if it is the very first frame
            else: #if y>0
                for z in range(y-1, 0, -1): #check if previous temporary[y-1][i] is empty
                    if temporary[z,i] == '': #if it is, keep checking backwards until the first frame, which must be full
                        continue        
                    else: #if previous temporary is full, compare it to current temporary
                        #read temp files to compare with ssim
                        tempread1 = numpy.array(temporary[z,i]);
                        tempread2 = numpy.array(temporary[y,i]);
                        if ssim(tempread1[0:300][40:240], tempread2[0:300][40:240], multichannel=True) < 0.90: #if the difference in similarity is significant, save. if not, don't
                            cropped_image.save(new_filename)
                            
                        else:
                            temporary[y,i]==''
                        break
    
        #save image in rescuedimagesFolder, delete image in labeled-data
        #normpath removes '/' at the end of path, just in case, so basename can return image name
        #for testing old_filename = rescuedimagesFolder + os.path.basename(os.path.normpath(image_name));
        old_filename = rescuedimagesFolder + videoFiles[x] + '/' + os.path.basename(os.path.normpath(image_name));
        img.save(old_filename);
        os.remove(image_name);
        

        
#give elapsed time (optional)
#elapsed = time.time()-t;
#elapsedstr = str(elapsed);
#print('')
#print('The three FOR loops needed exactly: ' + elapsedstr + ' seconds.')
    



