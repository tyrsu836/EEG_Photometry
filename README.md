# EEG_Photometry
These are some, but not all of the de Lecea lab's scripts for processing EEG/EMG &amp; fiber-photometry data. Please note that there is one step missing where we score the EEG/EMG into sleep states, as it belongs to another lab and is copyrighted. Sorry! To see the output from that step look at the EEG_SCORED.txt file in the example data - you should be able to match up your EEG scoring program output to ours easily enough :)

This folder contains 3 2017a MATLAB scripts that I used to create the scripts, test it on these files before testing it on your own.
In order to work you also need to download @gramm and have the @gramm folder either in the same folder as these 3 scripts or have it in your path
Find @gramm here: https://www.mathworks.com/matlabcentral/fileexchange/54465-gramm-complete-data-visualization-toolbox-ggplot2-r-like
Download example data here to test: https://drive.google.com/open?id=1g8UHtuqwai1jqqOwhzQeSchtxiMXcErM 

Files needed:
	For Pre_Processing:
	'...EEG TEXT.txt' - Data output from the EEG rig
	'...DATA.mat' - Signal data output from the Fiber-Photometry rig
	'...TIME.mat' - Time data output from the Fiber-Photometry rig
	
	For Post_Processing:
	'plot_heatmap.m' - personalized heatmap plotting script
	'@gramm' - folder containing gramm figure plotting scripts
	'...EEG SCORED.txt' - Scored EEG output from the EEG_Processing program
	'...EEGPh.mat' - Our MATLAB output from the 'Pre_Processing' script

Steps involved:

1. Move your '...EEG TEXT.txt' data file and your Fiber photometry files ('...DATA.mat' and '...TIME.mat') into the 'EEG and FPh Processing' Folder.
2. Run Pre_Processing
	Now You will have your '...EEGPh.mat' located in the 'EEG and FPh Processing' Folder.

3. Use the EEGProcessing script to score sleep-wake states (not included in this file - ask Shibin/Jeremy for it)
	This should give you a .txt output that you should call '...EEG SCORED.txt'

4. Make sure your '...EEG SCORED.txt' and '...EEGPh.mat' are in the 'EEG and FPh Processing' Folder.
5. Run Post_Processing
	Now you will have a new .csv file called '...EEG SCORED.csv' which has all of your transition times in it in the 'EEG and FPh Processing' Folder.
	You will also have a new folder with .csv files in it for each transition type which hold Fiber Photometry data for 10 seconds before and after each transition.
	This script also plots several figures for you.


