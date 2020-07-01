args <- commandArgs()
print(args)
indir <- args[6]
outdir <- args[7]

setwd(indir)

files <- list.files()[grepl("confounds_regressors.tsv", list.files())]
print(files)

for (i in 1:length(files)){
  conf <- read.table(files[i], sep = "\t", header=TRUE)
  sbjid <- strsplit(files[i], "_")[[1]][1]
  scan <- strsplit(files[i], "_")[[1]][2]
  scan <- paste0(scan, "_", strsplit(files[i], "_")[[1]][3])

  new_conf <- conf[, which(colnames(conf) %in% c("white_matter", "global_signal", "std_dvars", "framewise_displacement", 
                                                 "a_comp_cor_00", "a_comp_cor_01", "a_comp_cor_02", "a_comp_cor_03",
                                                 "trans_x", "trans_y", "trans_z", "rot_x", "rot_y", "rot_z"))]
  new_conf$std_dvars <- as.numeric(as.character(new_conf$std_dvars))
  new_conf$framewise_displacement <- as.numeric(as.character(new_conf$framewise_displacement))
  
  write.table(new_conf, sprintf("%s/%s_%s_conformatted.tsv", outdir, sbjid, scan), row.names=FALSE, sep="\t", quote = FALSE, na = "n/a")
  print(sprintf("%s/%s_%s_conformatted.tsv", outdir, sbjid, scan))
}
