Hello and welcome to MouseReach!

MouseReach is a toolkit designed to explore the hand-object interaction in animals recovering from stroke.

Our software is composed out of 3 different main parts:

1) Python scripts: DeepLabCut implementation, image segmentation and tabular data transformation<br>
1.1 Here, we use DeepLabCut (Mathis et al, 2018) to extract images from recorded videos of the Staircase test.<br>
1.2 Extracted images are further split into 4 parts, filtered and used to train a residual neural network.<br> 
1.3 This network is then used to analyze additional videos in a selective box-wise manner.<br>
1.4 Lastly, resultant CSV files are transformed to contain information on all 4 boxes per one file (and video).<br>
These scripts have been designed to form one continuous pipeline from start to finish.

2) MATLAB scripts: rule-based signal processing, computation of kinematics, data visualization<br>
1.1 Data from CSV files is transformed to form two different types of signals.<br>
1.2 Hand movement signal is generated from vertical and horizontal positional displacement.<br>
1.3 Pellet binary signal is generated from pellet likelihood values for all 8 pellets.<br>
1.4 Peaks and troughs are found and carefully matched to detect sought signal patterns.<br>
1.5 Discovered patterns are thoroughly filtered via several categorical thresholds.<br>
1.6 Detailed timepoints within patterns are determined and related kinematic parameters are computed.<br>
Most functions have been built to revolve around the main script 'main.m' accompanied by optional analysis scripts.<br>
The 'Visualization' folder contains scripts that we have used to gather additional information on computed parameters:
Line and box plots on kinematics with statistics, volume correlation plots, PCA, LDA, ICA, heatmaps, validation, etc.

3) MATLAB App: a graphical user interface for post-processing of results obtained from automated analysis<br>
1.1 Inputs 'big_merge_matrix.xlsx' computed via above scripts and a table with information on the experiment.<br>
1.2 Enables the user to screen through the results and jump between chosen events such as pellet removal or slips.<br>
1.3 For every event, a corresponding video, related events and pellet status are loaded.<br>
1.4 The video can be scrolled through frame-by-frame and specific events can be added, modified and deleted.<br>
MouseReach GUI can be used to validate acquired results and ascertain the rate of successfully eaten pellets.

If you would like to use MouseReach for your experiments, feel free to contact us @ Translational Neuromodulation Group.

Thank you for your interest and good luck with your research!
