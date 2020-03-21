#!/bin/bash

# For any mask that you use in the 3dMaskDump:
#	1) 3dresample -master sub033_Ex2_errts+tlrc.BRIK -prefix HO_resample -input HarvardOxford-sub-maxprob-thr25-2mm.nii.gz
#	2) 3dAFNItoNIFTI -prefix HO_resample HO_resampl+tlrc.BRIK



declare -a ScansArray=("Ex" "Ex2")
declare -a SubjectArray=("sub-sub029" "sub-sub020" "sub-sub052") 
#"sub-sub014" "sub-sub024" "sub-sub054" "sub-sub034" "sub-sub017" "sub-sub059" "sub-sub074" "sub-sub023" "sub-sub039" "sub-sub033" "sub-sub055" "sub-sub076" "sub-sub069" "sub-sub070" "sub-sub078" "sub-sub032" "sub-sub056" "sub-sub025" "sub-sub022" "sub-sub019" "sub-sub049" "sub-sub053" "sub-sub068" "sub-sub043" "sub-sub048" "sub-sub058" "sub-sub018" "sub-sub038" "sub-sub030" "sub-sub057" "sub-sub060" "sub-sub041" "sub-sub061" "sub-sub044" "sub-sub046" "sub-sub072" "sub-sub066" "sub-sub045" "sub-sub050" "sub-sub015" "sub-sub073" "sub-sub062" "sub-sub026" "sub-sub047" "sub-sub027" "sub-sub028" "sub-sub031" "sub-sub071" "sub-sub065")

##
## AFNI FOR LOOP STARTS HERE
# Need to figure out how to loop through all subjects here (for i in range of subject_list, do: Ex and Ex2)

for sub_ii in "${SubjectArray[@]}"
do
	for scan_ii in "${ScansArray[@]}"
	do

		subjid=$sub_ii
		scan=$scan_ii
		outdir=/mnt/chrastil/data2/users/liz/DynConn


		indir=/mnt/chrastil/data2/users/liz/MLINDIV2/fmriPrepProcessed/fmriprep/${subjid}/func

		#
		# Format Confounds: Not sure how to call this, but this will format confounds.tsv for following script
		#
		Rscript /home/rwoodry/MyScripts/format_confs.R $indir $outdir 

		#
		# 3dDeconvolve the current subject task
		#

		3dDeconvolve                                                                                               \
		-input $indir/${subjid}_task-bold${scan}_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz                      		\
		-mask  $indir/${subjid}_task-bold${scan}_run-1_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz                  			\
		-polort 4                                                                                                  \
		-jobs 4                                                                                                    \
		-local_times                                                                                               \
		-allzero_OK                                                                                                \
		-num_stimts 14                                                                                             \
		-stim_file      1  $outdir/${subjid}_bold${scan}_run_conformatted.tsv'[0]'  -stim_base 1    -stim_label 1  'WhiteMatter'   	   \
		-stim_file      2  $outdir/${subjid}_bold${scan}_run_conformatted.tsv'[1]'  -stim_base 2    -stim_label 2  'Global'   	   \
		-stim_file      3  $outdir/${subjid}_bold${scan}_run_conformatted.tsv'[2]'  -stim_base 3    -stim_label 3  'nStd_dvars'   	   \
		-stim_file      4  $outdir/${subjid}_bold${scan}_run_conformatted.tsv'[3]'  -stim_base 4    -stim_label 4  'FD'   	   \
		-stim_file      5  $outdir/${subjid}_bold${scan}_run_conformatted.tsv'[4]'  -stim_base 5    -stim_label 5  'aCC0'   	   \
		-stim_file      6  $outdir/${subjid}_bold${scan}_run_conformatted.tsv'[5]'  -stim_base 6    -stim_label 6  'aCC1'   	   \
		-stim_file      7  $outdir/${subjid}_bold${scan}_run_conformatted.tsv'[6]'  -stim_base 7    -stim_label 7  'aCC2'   	   \
		-stim_file      8  $outdir/${subjid}_bold${scan}_run_conformatted.tsv'[7]'  -stim_base 8    -stim_label 8  'aCC3'   	   \
		-stim_file      9  $outdir/${subjid}_bold${scan}_run_conformatted.tsv'[8]'  -stim_base 9    -stim_label 9  'dx'   	   \
		-stim_file      10  $outdir/${subjid}_bold${scan}_run_conformatted.tsv'[9]'  -stim_base 10    -stim_label 10  'dy'   	   \
		-stim_file      11  $outdir/${subjid}_bold${scan}_run_conformatted.tsv'[10]'  -stim_base 11    -stim_label 11  'dz'   	   \
		-stim_file      12  $outdir/${subjid}_bold${scan}_run_conformatted.tsv'[11]'  -stim_base 12    -stim_label 12  'rotx'   	   \
		-stim_file      13  $outdir/${subjid}_bold${scan}_run_conformatted.tsv'[12]'  -stim_base 13    -stim_label 13  'roty'   	   \
		-stim_file      14  $outdir/${subjid}_bold${scan}_run_conformatted.tsv'[13]'  -stim_base 14    -stim_label 14  'rotz'   	   \
		-errts  $outdir/${subjid}_${scan}_errts                                            						   		\
		-bucket $outdir/${subjid}_${scan}                                                						   		  	\
		-fout

		##
		## Afni Mask Dump (Voxelwise beta weight value to text files)
		##

		mask=/home/rwoodry/DataProcessing/Schaefer2018_resample_100parcels.nii
		mask2=/home/rwoodry/DataProcessing/HO_resample.nii
		subjdir=/mnt/chrastil/data2/users/liz/DynConn
		outdir=/mnt/chrastil/data2/users/liz/DynConn/${subjid}_maskdump
		
		if [ ! -d "$outdir" ]
		then 
			mkdir -p $outdir
		fi 

		for ii in {0..100}
		do

		    3dmaskdump                                                                  \
		    -mask $mask                                                                 \
		    -xyz                                                                        \
		    -noijk                                                                      \
		    -mrange $ii $ii                                                             \
		    -o $outdir/${subjid}_${scan}_100parcels_ROI-$(printf %03d $ii).txt 						\
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
	done
done

##
## AFNI FOR LOOP ENDS HERE
##

##
## ROI Averaging: Censor, Interpolate, Filter, Average, Export
##

# R /MyScripts/average_ROI.R

##
## Create 3d Correlation Matrix
## Need to edit below script for pipeline integration

# R /MyScripts/corr_3d.R

## And done up until MATLAB scripts
## TODO Clean up scripts some more and work with Hamsi to get it executable: TEEST FOR LOOP WITH JUST 2 or 3 SUBJECTS!!!!!!!!!!!!!!





