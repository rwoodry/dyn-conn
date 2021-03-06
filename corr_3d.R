# Correlation
#TODO Add Magnitude Squared Coherence option along with  correlation for matrix
#TODO Add False Discovery RAte Thresholding as option along with top n-% threshold option
# Split into n time_windows
library(zoo)
library(DescTools)

nodenodetime <- function(data, window_width = 50, window_by=48){
  rois <- data[, 6:ncol(data)]
  time_steps = ncol(rois)
  
  
  if (time_steps < 674){
    missing <- 674 - time_steps
    last_col <- rois[, ncol(rois)]
    
    rois <- cbind(rois, matrix(rep(last_col, each=missing), ncol=missing, byrow=TRUE))
    
  } else if (time_steps > 674){
    rois <- rois[,1:674]
  }
  
  indices <- as.data.frame(rollapply(1:time_steps, c, width=window_width, by=window_by))
  tw_rois <- list()
  
  for (i in 1:nrow(indices)){
    tw_rois[[i]] <- as.data.frame(rois[, as.numeric(indices[i, ])])
  }
  
  tw_corrs <- array(dim = c(nrow(rois), nrow(rois), length(tw_rois)))
  for (k in 1:length(tw_rois)){

    for (i in 1:nrow(tw_rois[[k]])){

      for(j in 1:nrow(tw_rois[[k]])){
        ni <- as.numeric(tw_rois[[k]][i, ])
        nj <- as.numeric(tw_rois[[k]][j, ])
        tw_corrs[i, j, k] <- cor(ni, nj, method = "pearson")
      
      
      }

    }
    
  }
  return(tw_corrs)

}

nnt_threshold <- function(data, pct_threshold=.20, thresholding=TRUE, binarize=TRUE){
  nntarray <- data

  for (k in 1:dim(nntarray)[3]){
    # Replace diagonals with 0
    diag(nntarray[,,k]) <- 0
    
    # Calculate Fisher Z for each corr value
    nntarray[,,k] <- FisherZ(nntarray[,,k])
    
    # Calculate cutoff z score value for top pct_threshold
    cutoff <- as.numeric(quantile(as.numeric(nntarray[,,k]), 1-pct_threshold))
    print(paste(k, "cutoff value:", cutoff))
    
    # If Binarize, 0 if below cutoff, 1 if above. Otherwise 0 if below cutoff, z score if above
    if (binarize & thresholding){
      nntarray[,,k][nntarray[,,k] < cutoff] <- 0
      nntarray[,,k][nntarray[,,k] >= cutoff] <- 1
      
    } else if (thresholding){
      nntarray[,,k][nntarray[,,k] < cutoff] <- 0
    }
    print(sum(nntarray[,,k]))
  }
  return(nntarray)

}

dump_3darray <- function(data, roi,  session, subjectid){
  
  for(k in 1:dim(data)[3]){
    write.table(data[,,k], sprintf("array3d_%s_sub%s_%s_%03d.txt", parcels, subjectid, session, k), row.names = FALSE, col.names = FALSE)
  }
  
}


setwd("/home/rwoodry/DataProcessing/DynConn/avgfiltered")
files <- list.files()[grepl("avg_filtered", list.files())]

for (i in 1:length(files)){
  data <- read.csv(files[i], header=TRUE)
  
  filename <- strsplit(files[i], "_")
  subject_id <- filename[[1]][1]
  parcels <- filename[[1]][3]
  session <- filename[[1]][2]
  
  print(ncol(data))
  
  data_nnt <- nodenodetime(data)
  data_bin <- nnt_threshold(data_nnt, 0.1, binarize=FALSE)
  dump_3darray(data_bin, parcels, session, subject_id)
  
}
