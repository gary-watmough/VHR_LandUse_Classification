### Pre-processing VHR resolution satellite data 
### code written by Gary R Watmough 2016. 
### covers steps 1, 3 and 4 of the methods highlighted in paper. 
## Step 1 DN to radiance conversion and radiance to TOA based on methods in Christopher Smalls Matlab code
## step 3 Pan-sharpening of MS data (In the published paper this was done in ENVI 4.7 but it is included here also)
## pan sharpening here differs to that in ENVI as currently we have not found a way to run Gram Schmidt sharpening in R.
## Step 4 creation of additional features, in the published paper we use NDVI and two textural bands. We include these and
## additional features such as Principal components for ease of use in the future. 

##housekeeping ##clear workspace
rm(list = ls())

##################################################################################################
######################################### Estimate TOA reflectance correction factors ############
## code based on the Matlab code supplied by Christopher Small in 2012. 
## uses the approach by Updike and Comp (2010)
## variables needed:
## Gregorian Date and Time of image acquisition in YYYYMMDDHHMMSS format
## The Solar zenith angle of the image acquisition
##Earth-Sun distance vs julian day dateframe
## create vector of days of year
DOY<-c(1,15, 32, 46, 60, 74, 91, 106, 121, 135, 152, 166, 182, 196, 213, 227, 242, 258, 274, 288, 305, 319, 335, 349, 365)

##create vector of earth sun distances associated with above DOY
Distance<-c(0.9832, 0.9836, 0.9853, 0.9878, 0.9909, 0.9945, 0.9993, 1.0033, 1.0076, 1.0109, 1.0140, 1.0158, 1.0167, 1.0165,
            1.0149, 1.0128, 1.0092, 1.0057, 1.0011, 0.9972, 0.9925, 0.9892, 0.9860, 0.9843, 0.9833)

##join the two vectors together in esd object
esd<-cbind(DOY, Distance)

## create new Julian day function (this does what the Julian Matlab script does)
## please note that it does not account for situations where time information is missing from the input data. 
## this is because all WV2 and QB data available for MVP have date and time information in the filenames. 

Julian.day<-function(Time){
  Time.1<-as.character(Time)
  time.format<-as.POSIXct(Time.1, tz="GMT", format="%Y%m%d %H%M%S")
  JD.Diff<-as.numeric(julian(time.format, origin = as.POSIXct("1968-05-23", tz="GMT")))
  J.Day<-as.double(JD.Diff+2440000)         ##the +2440000 is added because the origin date of 23 May 1968 is Julian day 2440000
  return(as.vector(J.Day))
}

##convert the gregorian date and time of satellite data into julian days using the above Julian.Day function
## see the acquisition time in the IMD file supplied by image vendor. 
Jul.Day<-Julian.day(20070703083053) 

## Solar Zenith Angle is 90 degrees minus the Solar Elevation 
## find solar elevation in Image Metadata. this is the .imd file if using Digital Globe Data
SZA<-90-55.5

## convert to Julian day of the year by:
## Julian Day of acquistion minus Julian day of January 1st of the year of acquisition 
## need to find out the Julian day of Jan first of year in question
##to get Year (Y) extract the first 4 characters from the gregorian date string 

Y<-2007
## create an object that accounts for the rest of the date and time for the start of the year 
## i.e. (Jan 1st Midnight
Rest<-c("0101000000")

## paste the year in question together with the "rest" of the date and time stamp together
Year_Start<-paste(Y,Rest)

jd_Year<-Julian.day(20070703083053)-Julian.day(Year_Start)+1

## we now have the DOY and the solar zenith angle. 
## we need to know the solar emission of the bands for the satellite sensor in question.

## solar emission by QuickBird bands with panchromatic band included
## this can be found in th Metadata file (.imd file)
## NOTE it is different for GeoEye, WorldView-2, Worldview-3 etc. 
esun<-c(1381.79, 1924.59, 1843.08, 1574.77, 1113.71)

## need to calculate the seasonal Earth-Sun astronomical distance (from table)
## this uses a linear interpolation method (approx in R) to interpolate between the DOY esd column 1 and the given easrth-sun distances in esd column 2
## we want to interpolate the distances for the julian day of the year that we calculated above (jd_year)
ad<-approx(esd[,1],esd[,2],xout=jd_Year)

## Radiance->ExoReflectance conversion factor
## vector of 1s the length of esun
ones<-rep(1, length(esun))

## we create a matrix (C) with the number of rows matching the number of images that require conversion factors and the number of columns matching the number of bands 
## in that sensor.  
Corr.Fact<-matrix(NA, nrow=length(jd_Year), ncol=length(esun))

Corr.Fact<-((pi*ones)*ad$y^2)/(esun*cos(SZA*pi/180))

## names will need altering if have more bands. 
names(Corr.Fact) <- c("Pan", "Blue", "Green", "Red", "NIR")

Corr.Fact

##the above created correction factors for each of the bands available in the image,
## apply them to the bands. 

####################################Open Raw Image Files###########################################################
## Open Panchromatic raw file
library(raster)
setwd("FILEPATH")
list.files()
## sometimes have more than one file covering the scene. 
Pan<-raster("FILENAME.TIF")
##################################################### convert to radiance #########################
## two stage approach presented in Krause 2005
## Radiance = DN/a (DN is the Digital Number per band and a is the offset for each band)
## for ease of use we split into two steps. 

##step 1 multiply the DN by the Gain factor found in the Metadata file
Rad.P*0.064476000
##step 2 divide the above by the offset (also found in the metadata file)
Rad2.P<-Rad.P/0.398000000

#################################################### apply TOA conversion to Radiance #############
P.Ref<-Corr.Fact[1]*Rad2.P

############################################### write TOA panchromatic Tiff files ##################

writeRaster(P.Ref, "FILENAME", format="EHdr")

############################################# repeat for multispectral images ##########################

setwd("FILEPATH")
##list.files(pattern=("TIF$"))
DN.MS<-brick("FILENAME")

##################################################### convert to radiance #########################
#step 1 multiply each band by the gain
Rad.B<-DN.1[[1]]*0.016041200
Rad.G<-DN.1[[2]]*0.014384700
Rad.R<-DN.1[[3]]*0.012673500
Rad.N<-DN.1[[4]]*0.015424000

## step 2 divide by the offset
Rad2.B<-Rad.B/0.06800000
Rad2.G<-Rad.G/0.09900000
Rad2.R<-Rad.R/0.07100000
Rad2.N<-Rad.N/0.11400000

#################################### apply TOA corection factors

B.Ref<-Corr.Fact[2]*Rad2.B
G.Ref<-Corr.Fact[3]*Rad2.G
R.Ref<-Corr.Fact[4]*Rad2.R
N.Ref<-Corr.Fact[5]*Rad2.N

############################ pre-processing step 2: mosaic ###########################################
## some of the files from Digital globe contain more than one image in order to cover the extent of the
## image order. 
## this section can be skipped if only have a single image to work with. 
MS.1<-merge(R1C1Ref, R1C2Ref)
MS.2<-merge(R2C1Ref, R2C2Ref)
MS.mosaic<-merge(MS.1, MS.2)
plot(MS.mosaic)

writeRaster(MS.mosaic, "FILENAME", format="EHdr")

#### repeat for panchromatic band. 
Pan.1<-merge(P.R1C1.Ref, P.R1C2.Ref)
Pan.2<-merge(P.R2C1.Ref, P.R2C2.Ref)
Pan.mosaic<-merge(Pan.1, Pan.2)
plot(Pan.mosaic)
writeRaster(Pan.mosaic, "FILENAME", format="EHdr")

################################## step 2 pan sharpen ###################################
library(RStoolbox)
library(ggplot2)
library(raster)
##read in the TOARef data for Multispectral and panchromatic and P.Ref
MS1<-brick("FILENAME")
P.Ref<-brick("FILENAME")

##step1 creates Pansh of NIR (4), Red (3) and Blue (1) the three bands that we make most use of 
## Brovey sharpening produces very good quality pansharpened images, but can only produce RGB 3 band stack) 
## we can run the pansharpen algorithm twice to get all of the 4 bands done, just need to extract the missing bands
## and stack it with the original three pansharpened bands. 
## 
## WARNING: this seems to cause problems for PC analysis later in the script as the number or rows and cols
## differ slightly in the two Pansharpened bricks. 
## In Sauri we used ENVI pan sharpening and the fram schmidt algorithm. 

##pansh will be NIR, red and blue
Pansh<-panSharpen(MS1, P.Ref, r=4, g=3, b=1, method="brovey")
##check the image
ggRGB(Pansh, stretch="lin") + ggtitle("Pansharpened (Brovey)")
##check the image is a brick still and contains 3 bands
plot(Pansh)
writeRaster(Pansh, "FILENAME", format="EHdr")

##pansh 1 will be Red, green, blue
Pansh.1<-panSharpen(MS1, P.Ref, r=3, g=2, b=1, method="brovey")
writeRaster(Pansh.1, "FILENAME", format="EHdr")

#############################Step 3 create additional features ###############################
## in Sauri paper we ised NDVI and two textural bands. 
## here we include a few more as we originally calculated more than three additional features and then
## visually examined them to decide on which to use in classification steps

############################# NDVI ####################################################
## read in the pansh and pansh.1 data for the next steps
library(raster)
library(RStoolbox)
##open the pansharpened data
## if not pansharpening the data then open the TOA reflectance data
Pansh<-brick("FILENAME")
Pansh.1<-brick("FILENAME")

##NDVI (split into three steps for simplicity)
one<-Pansh[[3]]-Pansh[[2]]
two<-Pansh[[3]]+Pansh[[2]]

NDVI<-one/two
writeRaster(NDVI, "FILENAME", format="EHdr")
############################# VARI ####################################################
## Visible Atmospherically Resistent Index 
VARI.1<-Pansh.1[[2]]-Pansh.1[[3]]
VARI.2<-Pansh.1[[2]]+Pansh.1[[3]]-Pansh.1[[1]]

VARI<-VARI.1/VARI.2

writeRaster(VARI, "FILENAME", format="EHdr")

################################################################################################
############ Principal Components analysis of raster ##########################################
library(raster)
library(RStoolbox)
library(ggplot2)

Pansh<-brick("FILENAME.bil")

##run the PCA on the first Pansh brick (NIR, Red, Blue)
PC<-rasterPCA(Pansh, nComp=2)

## write the first two PC's to raster files
writeRaster(PC$map[[1]], "FILENAME", format="EHdr")
writeRaster(PC$map[[2]], "FILENAME", format="EHdr")

############# GLCM texture analysis ######################

library(glcm)
## calculate texture on red band 
## using shift shift=list(c(0,1), c(1,1), c(1,0), c(1,-1)), returns a all direction raster. 
textures <- glcm(raster(Pansh.1, layer=3), window=c(11,11), 
                 shift=list(c(0,1), c(1,1), c(1,0), c(1,-1)), 
                 statistics=c("variance", "contrast"))
##write the texture bands as individual rasters. 
writeRaster(textures[[1]], "FILENAME", format="EHdr")
writeRaster(textures[[2]], "FILENAME", format="EHdr")

