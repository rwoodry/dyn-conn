setwd("C:/Users/UCI - Robert Woodry/Desktop/Unix-Desktop/DynConnTest")

files <- list.files()[grepl("sub076", list.files())]
sch <- read.csv("Schaefer2018_100Parcels_17Networks_order_FSLMNI152_2mm.Centroid_RAS.csv")
splitnames <- strsplit(as.character(sch$ROI.Name), "_")

regionize <- function(locations, hemi = FALSE){
  regions <- c()
  for (i in 1:length(splitnames)){
    if (hemi){
      regions <- c(regions, paste0(splitnames[[i]][2], "_", splitnames[[i]][3]))
    } else {
      regions <- c(regions, splitnames[[i]][3])
    }
   
    
  }
  return(regions)
}

sch <- sch %>% mutate(region = regionize(ROI.Name))
sch$region <- as.factor(sch$region)

sch <- sch %>% mutate(region_hemi = regionize(ROI.Name, hemi=TRUE))
sch$region_hemi <- as.factor(sch$region_hemi)

splitbyregion <- split(sch, sch$region)
splitbyregionhemi <- split(sch, sch$region_hemi)

subregions <- c(27:28, 37:49)

for (i in 1:length(files)){
  data <- read.csv(files[i])
  new_data <- c()
  for (j in 1:length(subregions)){
    # indextoavg <- splitbyregion[[j]]['ROI.Label']
    # indextoavg <- as.numeric(indextoavg[[1]])
    indextoavg <- subregions[j]
    datasubset <- data[indextoavg, ]
    datasubsavg <- colMeans(datasubset, na.rm = TRUE)
    new_data <- rbind(new_data, datasubsavg)
  }
  write.csv(new_data, paste0("15roi_", files[i]), row.names = FALSE)
  
}