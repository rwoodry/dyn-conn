##
## Afni Deconvolve/Lin Regression
##
subjid=sub076
scan=Ex2
indir=/mnt/chrastil/data2/users/liz/MLINDIV2/fmriPrepProcessed/fmriprep/sub-${subjid}/func
outdir=/home/rwoodry/DataProcessing/Deconvolved

3dDeconvolve                                                                                               \
-input $indir/sub-${subjid}_task-bold${scan}_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz                      		\
-mask  $indir/sub-${subjid}_task-bold${scan}_run-1_space-MNI152NLin2009cAsym_desc-brain_mask.nii.gz                  			\
-polort 4                                                                                                  \
-jobs 4                                                                                                    \
-local_times                                                                                               \
-allzero_OK                                                                                                \
-num_stimts 14                                                                                             \
-stim_file      1  $outdir/sub-${subjid}_bold${scan}_run_conformatted.tsv'[0]'  -stim_base 1    -stim_label 1  'WhiteMatter'   	   \
-stim_file      2  $outdir/sub-${subjid}_bold${scan}_run_conformatted.tsv'[1]'  -stim_base 2    -stim_label 2  'Global'   	   \
-stim_file      3  $outdir/sub-${subjid}_bold${scan}_run_conformatted.tsv'[2]'  -stim_base 3    -stim_label 3  'nStd_dvars'   	   \
-stim_file      4  $outdir/sub-${subjid}_bold${scan}_run_conformatted.tsv'[3]'  -stim_base 4    -stim_label 4  'FD'   	   \
-stim_file      5  $outdir/sub-${subjid}_bold${scan}_run_conformatted.tsv'[4]'  -stim_base 5    -stim_label 5  'aCC0'   	   \
-stim_file      6  $outdir/sub-${subjid}_bold${scan}_run_conformatted.tsv'[5]'  -stim_base 6    -stim_label 6  'aCC1'   	   \
-stim_file      7  $outdir/sub-${subjid}_bold${scan}_run_conformatted.tsv'[6]'  -stim_base 7    -stim_label 7  'aCC2'   	   \
-stim_file      8  $outdir/sub-${subjid}_bold${scan}_run_conformatted.tsv'[7]'  -stim_base 8    -stim_label 8  'aCC3'   	   \
-stim_file      9  $outdir/sub-${subjid}_bold${scan}_run_conformatted.tsv'[8]'  -stim_base 9    -stim_label 9  'dx'   	   \
-stim_file      10  $outdir/sub-${subjid}_bold${scan}_run_conformatted.tsv'[9]'  -stim_base 10    -stim_label 10  'dy'   	   \
-stim_file      11  $outdir/sub-${subjid}_bold${scan}_run_conformatted.tsv'[10]'  -stim_base 11    -stim_label 11  'dz'   	   \
-stim_file      12  $outdir/sub-${subjid}_bold${scan}_run_conformatted.tsv'[11]'  -stim_base 12    -stim_label 12  'rotx'   	   \
-stim_file      13  $outdir/sub-${subjid}_bold${scan}_run_conformatted.tsv'[12]'  -stim_base 13    -stim_label 13  'roty'   	   \
-stim_file      14  $outdir/sub-${subjid}_bold${scan}_run_conformatted.tsv'[13]'  -stim_base 14    -stim_label 14  'rotz'   	   \
-errts  $outdir/${subjid}_${scan}_errts                                            						   		\
-bucket $outdir/${subjid}_${scan}                                                						   		  	\
-fout


