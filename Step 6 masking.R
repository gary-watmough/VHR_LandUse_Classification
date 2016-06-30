## masking Phase 1 classified objects from the image in preparation for phase 2 classification
## step 6 in the published paper
### code written by Gary R Watmough 2016. 
## takes phase 1 ecognition classification shapefiles, converts them to raster and masks them from the 
## TOA data ready for the second phase of classification. 

## clear memory and open relevant packages
rm(list = ls())
library(rgdal)
library(raster)

##import the shapefiles to be used as masks
Build.shp<-readOGR(dsn="FILEPATH", layer="Building")

## import the satellite image that will be masked and find out the extent, rows and columns
QB<-brick("FILENAME")
extent(QB)
ncol(QB)
nrow(QB)

#####create an empty raster file that will house the buildings when converted from shape####
## set an extent that matches the above satellite data
ext<-extent(c(450175.2, 460176, 9440441, 9450439))
## set a col and row that matches the above satellite data
xy<-c(4167, 4166)
##setup a raster template that has the same environment as the satellite image to be masked
raster.mask<-raster(ext, ncol=xy[1], nrow=xy[2])
summary(raster.mask)

## convert the shapefile to raster using the raster template above.
build.rast<-rasterize(Build.shp, raster.mask)
plot(build.rast)
summary(build.rast)

## reclassify the raster. R sets the noData values from the shapefile as NA and each of the polygons are
## given the FID value from the shapefile metadata
## so we want NA to be coded as 1 and any building/road etc as 0 so they are masked out. 
## the rcl argument in the reclassify function has to be a matrix of 3 columns, from, to, new value. 
build.mask<-reclassify(build.rast, c(NA, NA, 1, 0,483,NA))
plot(build.mask)
build.mask

#####################################################################################################
## Repeat for other classes resulting from phase 1 classification ######################################

Water.shp<-readOGR(dsn="FILEPATH", layer="Water")
Road.shp<-readOGR(dsn="FILEPATH", layer="road")
Cloud.shp<-readOGR(dsn="FILEPATH", layer="cloudandshadow")

## convert shapefiles to raster using the raster template above.
water.rast<-rasterize(Water.shp, raster.mask)
road.rast<-rasterize(Road.shp, raster.mask)
cloud.rast<-rasterize(Cloud.shp, raster.mask)

##reclassify
water.mask<-reclassify(water.rast, c(NA, NA, 1, 0,266,NA))
road.mask<-reclassify(road.rast, c(NA, NA, 1, 0,859,NA))
cloud.mask<-reclassify(cloud.rast, c(NA, NA, 1, 0,874,NA))

#######combine the four masks together using multiply######
phase1.mask<-build.mask*water.mask*road.mask*cloud.mask
summary(phase1.mask)

################################################################################################
####### mask building, road & cloud from the WV3 brick above##########
QB.masked<-QB*phase1.mask
plot(QB.masked)
##replace the NAs with zero for MS data and use this as NoData in eCog, this ensures that the display
##of the image is not stretched too far. 
QB.masked[is.na(QB.masked)]<-0

######### write masked data to raster file for phase 2##################
writeRaster(QB.masked, "FILENAME", format="EHdr")

##################################################################################################
##################################################################################################
####### repeat the masking process for all other data sets used in the classification ##########
## eg EVI, texture, NDVI, PC1. SAVI, VARI. 
## do this in a loop for all but PCA (PCA is a brick not a raster so dealt with separately - see end)
## allow the masking to run with NAs as the masked pixels
##problem is with the masked value, it has to be different in each image and it cannot be NA as 
##ecognition doesnt like it. check the range of values in each using summary and reclassify the no data value 

##replace the NAs in each raster with a NODATA value - this will be the no data value when working in eCog.
setwd("FILEPATH")
list.files(pattern = "*.tif")

PC1<-brick("PC1.tif")
EVI<-raster("EVI.tif")
NIR9con<-raster("glcmConNIR9.tif")
Red11con<-raster("glcmConRed11.tif")
NIR9Dis<-raster("glcmDisNIR9.tif")
NDVI<-raster("NDVI.tif")
SAVI<-raster("SAVI.tif")
VARI<-raster("VARI.tif")

##use summary to find out max value and then use a suitable value to represent no data eg 2 in NDVI
summary(VARI)

name.list<-c("PC1_masked", "EVI_masked", "NIR9Con_masked", "Red11Con_masked", 
             "NIR9Dis_masked", "NDVI_masked", "SAVI_masked", "VARI_masked")
NODATA<-c(40, 2, 11, 8, 4, 2, 2, 2)

setwd("FILEPATH") 
files<-c("PC1.tif", "EVI.tif", "glcmConNIR9.tif", "glcmConRed11.tif", "glcmDisNIR9.tif", "NDVI.tif", 
         "SAVI.tif", "VARI.tif")
for (i in 1:length(files))
{
outname<-paste(name.list[i], "bil", sep=".") 
outputname<-paste("FILEPATH", outname, sep="\\")
rast<-raster(files[i])
rast.masked<-rast*phase1.mask
rast.masked[is.na(rast.masked)]<-NODATA[i]
writeRaster(rast.masked, filename=outputname, format="EHdr", overwrite=TRUE)
}


