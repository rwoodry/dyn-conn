##
## Afni Mask Dump (Voxelwise beta weight value to text fileq)
##
subjid=sub076
scan=Ex2
mask=/home/rwoodry/DataProcessing/Schaefer2018_resample_100parcels.nii
subjdir=/home/rwoodry/DataProcessing/Deconvolved
outdir=/home/rwoodry/DataProcessing/Dumped/${subjid}_maskdump

for ii in {0..100}; do

    3dmaskdump                                                                  \
    -mask $mask                                                                 \
    -xyz                                                                        \
    -noijk                                                                      \
    -mrange $ii $ii                                                             \
    -o $outdir/${subjid}_${scan}_100parcels_ROI-$(printf %03d $ii).txt 						\
       $subjdir/${subjid}_${scan}_errts+tlrc.BRIK

done
