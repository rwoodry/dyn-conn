if (!require(signal)) install.packages('signal')
if (!require(imputeTS)) install.packages('imputeTS')


library(signal)     # For the butter filter
library(imputeTS)   # For the na_interpolation function

avg_filter_3d <- function(subjectid, parcels, scans = c("Ex", "Ex2"), mtn_threshold = 0.5){
  for (c in 1:length(scans)){

    parcelnum <- parcels
    parcellabel <- paste0(parcels, "parcels")
    print(parcellabel)

    # Check to see if average ROI has already been calculated for this iteration. If it has, skip to next iteration
    check_name <- sprintf("/mnt/chrastil/data2/users/liz/DynConn/avgfiltered/%s_%s_%s_avg_filtered.csv", subjectid, scans[c], parcellabel)
    if (file.exists(check_name)){
      print(scans[c])
      next
    }

    working_dir <- sprintf("/mnt/chrastil/data2/users/liz/DynConn/%s_maskdump", subjectid)
    setwd(working_dir)
    print(working_dir)
    # Read in confounds file
    conf <- read.table(sprintf("/mnt/chrastil/data2/users/liz/MLINDIV2/fmriPrepProcessed/fmriprep/%s/func/%s_task-bold%s_run-1_desc-confounds_regressors.tsv", 
				subjectid, subjectid, scans[c]), sep = "\t", header = TRUE)
    print(sprintf("/mnt/chrastil/data2/users/liz/MLINDIV2/fmriPrepProcessed/fmriprep/%s/func/%s_task-bold%s_run-1_desc-confounds_regressors.tsv", 
				subjectid, subjectid, scans[c]))
    
    # Set Motion threshold in mm
    
    # Grab framewise displacement vector from confounds
    fd <- as.numeric(as.character(conf$framewise_displacement))
    print(sum(fd > mtn_threshold, na.rm = TRUE))
    
    # Get list of ROI files and create an empty roi_avgs vector
    print(sprintf("%s_%s_ROI", scans[c], parcels))
    roi_filenames <- list.files()[grepl(sprintf("%s_%s_ROI", scans[c], parcellabel), list.files())]
    print(roi_filenames)
    roi_avgs <- c()
    
    
    # Create butters bandpass filter for filtering motion-corrected ROI betas
    bf <- butter(4, c(0.009, 0.08), type = "pass")
    
    # Create a motion vector of indices where Framewise Displacement exceeds motion threshold
    fd_corr_index <- c()
    for (k in 1:length(fd)){
      if (fd[k] > mtn_threshold & !is.na(fd[k])){
        
        imi <- k - 3
        imx <- k + 3
        
        if (imi < 1){ imi <- 1}
        if (imx > length(fd)){ imx <- length(fd)}
        
        fd_corr_index <- c(fd_corr_index, imi:imx)
        
      }
      
    }
    fd_corr_index <- unique(fd_corr_index)

    write.table(fd_corr_index, sprintf("%s_%s_%s_fd_corr_index.txt", subjectid, scans[c], parcellabel))
    print("FD corr index created...")
    
    
    # For each roi file 1 : nregions
    for (i in 1:length(roi_filenames)){

      roi <- read.table(roi_filenames[i])

      
      # For each voxel in ROI
      for (j in 1:nrow(roi)){
        
        # Censor the betas at indices prescribed by fd_corr_index
        roi[j, 4:ncol(roi)][fd_corr_index] <- NA
        
        # Interpolate the censored betas
        roi[j, 4:ncol(roi)] <- na_interpolation(as.numeric(roi[j, 4:ncol(roi)]))
        
        # Filter over motion-corrected ROI betas w/ butter
        timesteps <- roi[j, 4:ncol(roi)]
        roi[j, 4:ncol(roi)] <- filter(bf, timesteps)
            
      }
      
      # Average all the voxels within ROI
      roi_avg <- colMeans(roi)
      
      roi_avgs <- rbind(roi_avgs, roi_avg)
      print(paste(roi_filenames[i], "completed. # of timesteps censored: ", length(fd_corr_index)))
      
    }
    roi_num <- c(1:parcelnum)
    roi_avgs <- cbind(roi_num, roi_avgs)
    
    rownames(roi_avgs) <- c(1:parcelnum)
    colnames(roi_avgs) <- c("roi", "x", "y", "z", c(1:(ncol(roi) - 3)))
    
    roi_avgs <- as.data.frame(roi_avgs)
    
    write.csv(roi_avgs, sprintf("/mnt/chrastil/data2/users/liz/DynConn/avgfiltered/%s_%s_%s_avg_filtered.csv", subjectid, scans[c], parcellabel))
    print(sprintf("/mnt/chrastil/data2/users/liz/DynConn/avgfiltered/%s_%s_%s_avg_filtered.csv", subjectid, scans[c], parcellabel))
  }
  
}

args <- commandArgs()

subjectids <- args[6:length(args)]


for (s in 1:length(subjectids)){
  avg_filter_3d(subjectids[s], parcels = 100)
  avg_filter_3d(subjectids[s], parcels = 21)
}
