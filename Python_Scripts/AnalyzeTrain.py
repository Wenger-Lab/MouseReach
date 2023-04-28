import os
import deeplabcut
import tensorflow as tf
#from FrameSplitter import projectLocation, config_path

config_path = '/home/nikolaus/DLC_Projects/Matej-Versuche-ab2019-10-17/DLC_Tests/Matej_November21_Triple_Tracking_1/config.yaml'
projectLocation = '/home/nikolaus/DLC_Projects/Matej-Versuche-ab2019-10-17/DLC_Tests/Matej_November21_Triple_Tracking_1'
##################### PART 3: Labeling, Training and Analyzing ##########################

#change Hands, Legs in config_file to paw
input('When ready press to label frames. ')
deeplabcut.label_frames(config_path);
input('\nWhen ready press enter to create training dataset. ')
deeplabcut.create_training_dataset(config_path, num_shuffles=1);
input('\nWhen ready press enter to train the network. ')
deeplabcut.train_network(config_path, maxiters=700000);
#deeplabcut.train_network(config_path,shuffle=1,trainingsetindex=0,gputouse=None,max_snapshots_to_keep=5,autotune=False,displayiters=100,saveiters=15000, maxiters=30000)

