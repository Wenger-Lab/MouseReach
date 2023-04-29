import os
import pandas as pd
import scipy.io as sio
from HatemScript import newvideos_list, all_combos, boxes


##### REDECORATOR: split table into parts, stack those parts on top of each other!

#1. take 3 values (x,y,lh) from each bodypart and concatenate with coordinates
#2. xylh become column names, bodypart name is inserted in the first column
#3. splits are merged (concat)

def redecorator(my_csv, box):
    
    df = pd.read_csv(my_csv) 
    df.columns = df.iloc[0] 
    df = df.drop(df.index[0])

    split = {}
    parts_amount = len(df.columns)-1 #minus coords column
    
    for part in range(1, parts_amount, 3):
        split[part] = pd.concat([df.iloc[:, part:(part+3)], df.iloc[:, 0]], axis=1)
        
        split[part].columns = split[part].iloc[0]
        split[part] = split[part].drop(split[part].index[0])
        split[part].insert(0, 'bodyparts', df.columns[part])
        
    
    newdf = pd.concat(split, join_axes=[split[1].columns]) 
    newdf.insert(0, 'box', box+1)
    newdf.rename(columns={'coords':'frames'}, inplace=True)
    
    global my_csv_path
    redecorator_path = my_csv.replace('Tracking_csvs/' , 'Tracking_csvs/redecorator/') #stays the same in all scripts
    if not os.path.exists(os.path.dirname(redecorator_path)):
        os.makedirs(os.path.dirname(redecorator_path))    
    my_csv_path = os.path.splitext(redecorator_path)[0] + '_EDIT_' + str(box+1) + os.path.splitext(redecorator_path)[1]
    newdf.to_csv(my_csv_path, index = False)
    print(my_csv + ' redecorated!')
    return my_csv_path

######## MERGER: merge all boxes i.e. all .csv parts of one video into one .csv file
    
#1. loops through video files in all_csv_paths that has the path of all redecorated .csvs
#2. for each specific video, loops through all 4 files for each box, adds them to dictionary and ultimately merges
#3. the coordinates are corrected
#4. the merged video is saved in merged_videos folder under a new name (original video name)

def merger(all_csv_paths, loclist_length):
    

    for location in range(0, loclist_length): #i marks the currently selected video file
        file_placeholder = {}
        file_length = len(os.listdir(os.path.dirname(all_csv_paths[1, location, 0])))
        for x in range(0, file_length):
            for box in range(0, boxes):
                file_placeholder[box+1] = pd.read_csv(all_csv_paths[box+1, location, x])
                if box == 0:
                    file_placeholder[box+1]['x'] += all_combos[box][0][0]
                    file_placeholder[box+1]['y'] += all_combos[box][1][0]
                elif box == 1:
                    file_placeholder[box+1]['x'] += all_combos[box][0][0]
                    file_placeholder[box+1]['y'] += all_combos[box][1][0]
                elif box == 2:
                    file_placeholder[box+1]['x'] += all_combos[box][0][0]
                    file_placeholder[box+1]['y'] += all_combos[box][1][0]
                elif box == 3:
                    file_placeholder[box+1]['x'] += all_combos[box][0][0]
                    file_placeholder[box+1]['y'] += all_combos[box][1][0]
    
         
            new_csv_i = pd.concat(file_placeholder, join_axes=[file_placeholder[1].columns])
            name_index = all_csv_paths[1, location, x].find('DLC')
            new_csv_name = all_csv_paths[1, location, x][:name_index]
            merged_videos_path = new_csv_name.replace('redecorator/1/', 'merger/')
            if not os.path.exists(os.path.dirname(merged_videos_path)):
                os.makedirs(os.path.dirname(merged_videos_path)) 
            new_csv_path = merged_videos_path + '.csv'
            #new_mat_path = merged_videos_path + os.path.basename(new_csv_name) + '.mat'
            print('Merging .csv files for video ' + os.path.basename(new_csv_name))
            new_csv_i.to_csv(new_csv_path, index = False)
            #sio.savemat(new_mat_path, new_csv_i)
                
        
#MAIN

#boxes_number = list(dict.values(newvideos_list)) #how many boxes/splits were created (1,2,3,4)
loclist_length = len(newvideos_list[1])
csv_content = {} 

#LOOP through all the boxes and .csv files and segregate them in a dictionary to access later
for box in range(0, boxes): #go through 1,2,3,4 boxes
    for location in range(0, loclist_length):
        dir_list = os.listdir(newvideos_list[box+1][location])
        for file in dir_list: #go through all files for that n-th box
            if file.endswith('.csv'): #select only .csv files
                if not csv_content.get((box+1, location)):
                    csv_content[box+1, location] = [newvideos_list[box+1][location] + file]
                else:
                    csv_content[box+1, location].append(newvideos_list[box+1][location] + file)



all_csv_paths = {}   
for box in range(0, boxes):
    for location in range(0, loclist_length):
        file_length = len(csv_content[box+1, location])
        for x in range(0, file_length):
            print('Editing box ' + str(box+1) + ': ' + csv_content.get((box+1,location))[x])
            my_csv = csv_content.get((box+1,location))[x]
            redecorator(my_csv, box)
            all_csv_paths[box+1, location, x] = my_csv_path #dict of all new edited .csv files

merger(all_csv_paths, loclist_length)



###example
# =============================================================================
##get a dataset without Hand.1, Hand.2 with column names of bodyparts
#df = pd.read_csv(my_csv) 
#
##changes column names from DeepCut_ to bodyparts
#df.columns = df.iloc[0] 
#df = df.drop(df.index[0])
#    
# #select parts of dataframe to be split and stacked
# part1 = pd.concat([df.iloc[:, 1:4], df.iloc[:, 0]], axis=1)
# part2 = pd.concat([df.iloc[:, 4:7], df.iloc[:, 0]], axis=1)
# part3 = pd.concat([df.iloc[:, 7:10], df.iloc[:, 0]], axis=1)
# 
# #edit each dataframe split to the desired look
# part1.columns = part1.iloc[0]
# part1 = part1.drop(part1.index[0])
# part1.insert(0, 'bodyparts', df.columns[1]) #name comes from every 3d column name (Hand, Tongue, Pellet..)
# part2.columns = part2.iloc[0]
# part2 = part2.drop(part2.index[0])
# part2.insert(0, 'bodyparts', df.columns[4])
# part3.columns = part3.iloc[0]
# part3 = part3.drop(part3.index[0])
# part3.insert(0, 'bodyparts', df.columns[7])
# 
# newdf = pd.concat([part1, part2, part3], join_axes=[part1.columns]) #concatenate parts with column names from part1
# =============================================================================
#######



#data-before
#  Bodypart       Paw      Paw      Tongue   Tongue
#                 x1        y1        x1       y1
#                 x2        y2        x2       y2


#data-after
#Bodypart    Value(x)   Value(y)
# Paw          x1         y1
# Paw          x2         y2
# Tongue       x1         y1
# Tongue       x2         y2

