# dyn-conn
Dynamic Connectivity pipeline scripts. So far reads in specific fMRI data by subject (exploration phase bold data), and runs it through a pipeline to spit out a binary thresholded node-node adjacency matrix for use in the Dynamic Connectivity Matlab toolbox. [IN THE WORKS]

This is for use in the Spatial Neuroscience Lab at UC Irvine, for the Maze Learning Individual Differences Task (MLINDIV).

Everything works at the individual scale for testing the code. Scripts are still in the process of being streamlined, compiled, and commented. See below for script/pipeline details.

# format_confs.R
This script takes in the functional task scan's confounds.tsv file (after fMRIprep) and spits out a more structured confounds table for use in the 3dtest.sh script. 

# 3dtest.sh
This script runs AFNI's 3d deconvolve function on fmri Bold task data, regressing out a number of regressors passed in as arguments to the function. The output is then fed into the next script, 3ddump.sh

# 3ddump.sh
This script takes the 3d deconvolved data and dumps out funcitonal beta weights by Regions of Interest which are defined by an MNI space atlas passed as an argument to the function. This results in a number of text files equal to the number of ROIs defined by the atlas. These text files contain the beta weights of each voxel within that ROI across all of the time steps for that functional run.

# regionize.R
This script is optional, and is used after 3ddump.sh in order to average the ROIs by a broader definition of networks defined by the Schaeffer MNI atlas.

# average_ROI.R
This script goes through the resulting ROI text files and for each beta weight voxel time-series: 
1) Censors beta weights where framewise displacement from confounds exceeds preset motion threshold
2) Interpolates linearly the censored values
3) Applies a butters bandpass filter over the new voxel betas
4) Averages all voxels for each time step within that ROI
5) Spits out a csv where each row is an ROI and each column is a time step, containing the averaged beta weight for that time step

# corr_3d.R
This script contains three functions that takes the averaged ROI csv file and spits out an adjacency matrix defined by parameters passed into the functions. 

The function nodenodetime splits the averaged ROI into time windows of equal width and time steps, then within each of those new time windows, constructs a 3d array where each entry is a pearson correlation value between each node I (ROI I) and node J (ROI J) at time window K.

The function nnt_threshold takes the new 3d node x node x time window array and calculates a Fischer Z-score to each value. It also optionally thresholds the array to retain only the top nth percentile of correlation values within each time window, as well as optionally binarizes the array (0 for those that do not pass the threshold, 1 for those that do).

The function dump_3darray takes the resulting adjacency matrix and spits out a 2d matrix text file for each time window. The size of these matrices are equal to the number of node node pairs that have been correlated. These text files are then read into Matlab in the next script.

# make3darray.m
This matlab script reads in the 2d array text files and concatenates them back into one 3d array. It then rearranges them so the time windows are in the correct order. Following that, it then creates a contact sequence for use with functions in the Dynamic Connectivity toolbox (https://github.com/asizemore/Dynamic-Graph-Metrics) and visualizes the resulting dynamic network. These visualizations can be seen in the two .pngs uploaded in this repository. The two visualizations correspond to two different subjects and 15 Specific Regions of interest as defined by the Schaeffer atlas.
