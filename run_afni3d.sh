#!/bin/bash
#$ -S /bin/bash -V
#$ -j y
#$ -l arch=linux-x64
#$ -cwd
#$ -q shared.q
#$ -pe openmp 4

# The above are parameters for the grid. Replace stark.q with whatever it is for your lab. 

umask 0

s_outdir=/mnt/chrastil/lab/users/rob/DynConn
subjectnum="sub-$1"


echo Starting fmriprep on $HOSTNAME with $NSLOTS cores at `date`
echo Subject: $1
echo Extra: $2 #If you have any additional parameters.
echo PATH is $PATH
# unset PYTHONPATH


# For any mask that you use in the 3dMaskDump:
#	1) 3dresample -master sub033_Ex2_errts+tlrc.BRIK -prefix HO_resample -input HarvardOxford-sub-maxprob-thr25-2mm.nii.gz
#	2) 3dAFNItoNIFTI -prefix HO_resample HO_resampl+tlrc.BRIK
# To find all subdirectories that don't contain subdirectories with name: 'func': use:
#		find -maxdepth 1 -type d \! -exec test -d '{}/func' \; -print

#In subject num sub-directory, find all explore ("Ex") session preprocessed bold files, store them in "scans" array
indir=/mnt/chrastil/lab/data/MLINDIV/preprocessed/derivatives/fmriprep/${subjectnum}/func
mapfile -d $'\0' scans < <(find $indir -maxdepth 1 -name "*Ex*preproc_bold*.nii.gz*" -print0)




##
## AFNI FOR LOOP STARTS HERE
# Need to figure out how to loop through all subjects here (for i in range of subject_list, do: Ex and Ex2)


for scan_ii in "${scans[@]}"
do

	subjid=$subjectnum 
	input=${scan_ii}
	mask=${scan_ii:77: -19}brain_mask.nii.gz
	scan=${scan_ii:86: -51}
	outdir=$s_outdir
	
	echo $subjid
	echo $input

	echo "DEBUG END"


	indir=/mnt/chrastil/lab/data/MLINDIV/preprocessed/derivatives/fmriprep/${subjid}/func

	#
	# Format Confounds: Not sure how to call this, but this will format confounds.tsv for following script
	#
	Rscript /mnt/chrastil/lab/users/rob/scripts/MyScripts/format_confs.R $indir $outdir 

	#
	# 3dDeconvolve the current subject task
	#

	3dDeconvolve                                                                                               \
	-input $input                     		\
	-mask  $indir/$mask                			\
	-polort 4                                                                                                  \
	-jobs 4                                                                                                    \
	-local_times                                                                                               \
	-allzero_OK                                                                                                \
	-num_stimts 14                                                                                             \
	-stim_file      1  $outdir/${subjid}_${scan}_conformatted.tsv'[0]'  -stim_base 1    -stim_label 1  'WhiteMatter'   	   \
	-stim_file      2  $outdir/${subjid}_${scan}_conformatted.tsv'[1]'  -stim_base 2    -stim_label 2  'Global'   	   \
	-stim_file      3  $outdir/${subjid}_${scan}_conformatted.tsv'[2]'  -stim_base 3    -stim_label 3  'nStd_dvars'   	   \
	-stim_file      4  $outdir/${subjid}_${scan}_conformatted.tsv'[3]'  -stim_base 4    -stim_label 4  'FD'   	   \
	-stim_file      5  $outdir/${subjid}_${scan}_conformatted.tsv'[4]'  -stim_base 5    -stim_label 5  'aCC0'   	   \
	-stim_file      6  $outdir/${subjid}_${scan}_conformatted.tsv'[5]'  -stim_base 6    -stim_label 6  'aCC1'   	   \
	-stim_file      7  $outdir/${subjid}_${scan}_conformatted.tsv'[6]'  -stim_base 7    -stim_label 7  'aCC2'   	   \
	-stim_file      8  $outdir/${subjid}_${scan}_conformatted.tsv'[7]'  -stim_base 8    -stim_label 8  'aCC3'   	   \
	-stim_file      9  $outdir/${subjid}_${scan}_conformatted.tsv'[8]'  -stim_base 9    -stim_label 9  'dx'   	   \
	-stim_file      10  $outdir/${subjid}_${scan}_conformatted.tsv'[9]'  -stim_base 10    -stim_label 10  'dy'   	   \
	-stim_file      11  $outdir/${subjid}_${scan}_conformatted.tsv'[10]'  -stim_base 11    -stim_label 11  'dz'   	   \
	-stim_file      12  $outdir/${subjid}_${scan}_conformatted.tsv'[11]'  -stim_base 12    -stim_label 12  'rotx'   	   \
	-stim_file      13  $outdir/${subjid}_${scan}_conformatted.tsv'[12]'  -stim_base 13    -stim_label 13  'roty'   	   \
	-stim_file      14  $outdir/${subjid}_${scan}_conformatted.tsv'[13]'  -stim_base 14    -stim_label 14  'rotz'   	   \
	-errts  $outdir/${subjid}_${scan}_errts                                            						   		\
	-bucket $outdir/${subjid}_${scan}                                                						   		  	\
	-fout

	##
	## Afni Mask Dump (Voxelwise beta weight value to text files)
	##

	mask=/home/rwoodry/DataProcessing/Schaefer2018_resample.nii
	mask2=/home/rwoodry/DataProcessing/HO_resample.nii
	subjdir=$s_outdir
	outdir=/mnt/chrastil/lab/users/rob/DynConn/${subjid}_maskdump
	
	if [ ! -d "$outdir" ]
	then 
		mkdir -p $outdir
	fi 

	for ii in {0..400}
	do

	    3dmaskdump                                                                  \
	    -mask $mask                                                                 \
	    -xyz                                                                        \
	    -noijk                                                                      \
	    -mrange $ii $ii                                                             \
	    -o $outdir/${subjid}_${scan}_400parcels_ROI-$(printf %03d $ii).txt 						\
	       $subjdir/${subjid}_${scan}_errts+tlrc.BRIK

	done

	for jj in {0..21}
	do

	    3dmaskdump                                                                  \
	    -mask $mask2                                                                 \
	    -xyz                                                                        \
	    -noijk                                                                      \
	    -mrange $jj $jj                                                             \
	    -o $outdir/${subjid}_${scan}_21parcels_ROI-$(printf %03d $jj).txt 						\
	       $subjdir/${subjid}_${scan}_errts+tlrc.BRIK

	done
	
	Rscript /home/rwoodry/MyScripts/average_ROI.R /mnt/chrastil/lab/users/rob/DynConn/${subjid}_maskdump $scan

done

##
## AFNI FOR LOOP ENDS HERE
##

##
## ROI Averaging: Censor, Interpolate, Filter, Average, Export
##



##
## Create 3d Correlation Matrix
## Need to edit below script for pipeline integration

# R /MyScripts/corr_3d.R 

## And done up until MATLAB scripts
## TODO Clean up scripts some more and work with Hamsi to get it executable: TEEST FOR LOOP WITH JUST 2 or 3 SUBJECTS!!!!!!!!!!!!!!




echo Finished at `date`
