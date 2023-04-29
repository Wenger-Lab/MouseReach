import os
import deeplabcut
import tensorflow as tf
from FrameSplitter import projectLocation, config_path

##################### PART 3: Labeling, Training and Analysis ##########################

#change Hands, Legs in config_file to paw
input('When ready press to label frames. ')
deeplabcut.label_frames(config_path);
input('\nWhen ready press enter to create training dataset. ')
deeplabcut.create_training_dataset(config_path, num_shuffles=1);
input('\nWhen ready press enter to train the network. ')
deeplabcut.train_network(config_path, maxiters=700000);
#deeplabcut.train_network(config_path,shuffle=1,trainingsetindex=0,gputouse=None,max_snapshots_to_keep=5,autotune=False,displayiters=100,saveiters=15000, maxiters=30000)

