library(signal)     # For the butter filter
library(imputeTS)   # For the na_interpolation function

avg_filter_3d <- function(subjectid, scans = c("Ex", "Ex2")){
  for (c in 1:length(scans)){
    working_dir <- sprintf("C:/Users/UCI - Robert Woodry/Desktop/Unix-Desktop/%s_maskdump/", subjectid)
    setwd(working_dir)
    print(working_dir)
    
    # Read in confounds file
    conf <- read.table(sprintf("sub-%s_task-bold%s_run-1_desc-confounds_regressors.tsv", subjectid, scans[c]), sep = "\t", header = TRUE)
    
    # Set Motion threshold in mm
    mtn_threshold <- 0.5
    
    # Grab framewise displacement vector from confounds
    fd <- as.numeric(as.character(conf$framewise_displacement))
    print(sum(fd > 0.5, na.rm = TRUE))
    
    # Get list of ROI files and create an empty roi_avgs vector
    roi_filenames <- list.files()[grepl(sprintf("%s_100parcels_ROI", scans[c]), list.files())]
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

    write.table(fd_corr_index, sprintf("%s_%s_fd_corr_index.txt", subjectid, scans[c]))
    
    
    # For each roi file 1 : nregions
    for (i in 1:length(roi_filenames)){
      
      roi <- read.table(roi_filenames[i])
      print(roi_filenames[i])
      
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
    roi_num <- c(1:100)
    roi_avgs <- cbind(roi_num, roi_avgs)
    
    rownames(roi_avgs) <- c(1:100)
    colnames(roi_avgs) <- c("roi", "x", "y", "z", c(1:(ncol(roi) - 3)))
    
    roi_avgs <- as.data.frame(roi_avgs)
    
    write.csv(roi_avgs, sprintf("%s_%s_100_avg_filtered.csv", subjectid, scans[c]))
  }
  
}

# subjectids <- c("sub033", "sub061", "sub022")
# for (s in 1:length(subjectids)){
#   avg_filter_3d(subjectids[s])
# }
