###################################
## Step 8 smaple editing 
## Written by Gary R Watmough 2016
## use the samples selected in eCognition and edited in ArcMap/Excel in this script
## the script splits the  samples into a training and testing dataframe. 
## the training data consists of samples for each of the land use classes. 
###################################

rm(list=ls())

## open training samples 
Train<-read.csv("FILENAME")
nrows(Train)
##########################################
## we have X samples in the training dataset
## split each class label into training and testing data.
## we will use samples for each class to train the RF model. 
## use a random number generator to subset each class. 
unique(Train$Class_Name)
## create separate dataframe for each class label

Agri<-subset(Train, Class_Name == "Ag")
Bareground<-subset(Train, Class_Name == "BareGround")
BareAgri<-subset(Train, Class_Name == "BareAg")
Shrub<-subset(Train, Class_Name == "Shrub")
Grass<-subset(Train, Class_Name == "Grass")
WetAgri<-subset(Train, Class_Name == "IrrigatedAg")
WetBare<-subset(Train, Class_Name == "IrrigatedBare")
Woody<-subset(Train, Class_Name == "Woody")
Tree<-subset(Train, Class_Name == "Tree")
Shadow<-subset(Train, Class_Name == "Shadow")

Agri.T<-Train[which(Train$Class_Name=="Ag"),]
BareGround.T<-Train[which(Train$Class_Name=="BareGround"),]
BareAgri.T<-Train[which(Train$Class_Name=="BareAg"),]
Shrubland.T<-Train[which(Train$Class_Name=="Shrub"),]
Grass.T<-Train[which(Train$Class_Name=="Grass"),]
WetAgri.T<-Train[which(Train$Class_Name=="IrrigatedAg"),]
WetBare.T<-Train[which(Train$Class_Name=="IrrigatedBare"),]
Woody.T<-Train[which(Train$Class_Name=="Woody"),]
Tree.T<-Train[which(Train$Class_Name=="Tree"),]
Shadow.T<-Train[which(Train$Class_Name=="Shadow"),]

##calculate 70% for each class
Agri.Per<-round(nrow(Agri.T)*0.7)
BareGround.Per<-round(nrow(BareGround.T)*0.7)
BareAgri.Per<-round(nrow(BareAgri.T)*0.7)
Shrubland.Per<-round(nrow(Shrubland.T)*0.7)
Grass.Per<-round(nrow(Grass.T)*0.7)
WetAgri.Per<-round(nrow(WetAgri.T)*0.7)
WetBare.Per<-round(nrow(WetBare.T)*0.7)
Woody.Per<-round(nrow(Woody.T)*0.7)
Tree.Per<-round(nrow(Tree.T)*0.7)
Shadow.Per<-round(nrow(Shadow.T)*0.7)

## sample each class
Agri.row<-sample(1:nrow(Agri.T), Agri.Per)
BareGround.row<-sample(1:nrow(BareGround.T), BareGround.Per)
BareAgri.row<-sample(1:nrow(BareAgri.T), BareAgri.Per )
Shrubland.row<-sample(1:nrow(Shrubland.T), Shrubland.Per)
Grass.row<-sample(1:nrow(Grass.T), Grass.Per)
WetAgri.row<-sample(1:nrow(WetAgri), WetAgri.Per)
WetBare.row<-sample(1:nrow(WetBare.T), WetBare.Per)
Woody.row<-sample(1:nrow(Woody.T), Woody.Per)
Tree.row<-sample(1:nrow(Tree.T), Tree.Per)
Shadow.row<-sample(1:nrow(Shadow.T), Shadow.Per)
## create Train and test datasets: test = Ag_1 minus Ag_1.row and train = Ag_1 == Ag_1.row

#training data
Agri.train<-Agri.T[Agri.row,]
Bare.train<-BareGround.T[BareGround.row,]
BareAgri.train<-BareAgri.T[BareAgri.row,]
Shrub.train<-Shrubland.T[Shrubland.row,]
Grass.train<-Grass.T[Grass.row,]
WetAgri.train<-WetAgri.T[WetAgri.row,]
WetBare.train<-WetBare.T[WetBare.row,]
Woody.train<-Woody.T[Woody.row,]
Tree.train<-Tree.T[Tree.row,]
Shadow.train<-Shadow.T[Shadow.row,]

# test data
Grass.test<-Grass.T[-Grass.row,]
Agri.test<-Agri.T[-Agri.row,]
Bare.test<-BareGround.T[-BareGround.row,]
BareAgri.test<-BareAgri.T[-BareAgri.row,]
Shrub.test<-Shrubland.T[-Shrubland.row,]
WetAgri.test<-WetAgri.T[-WetAgri.row,]
WetBare.test<-WetBare.T[-WetBare.row,]
Woody.test<-Woody.T[-Woody.row,]
Tree.test<-Tree.T[-Tree.row,]
Shadow.test<-Shadow.T[-Shadow.row,]


## bind all the test and training dataframes together into a complete training DF and a 
## complete test dataframe

Training<-rbind(Agri.train, Bare.train, BareAgri.train, Shrub.train, Grass.train, WetBare.train, WetAgri.train, Woody.train, Tree.train, Shadow.train)
Testing<-rbind(Agri.test, Bare.test, BareAgri.test, Grass.test, Shrub.test, WetAgri.test, WetBare.test, Woody.test, Tree.test, Shadow.test)

## write csvs of both testing nd training to use in future. 

write.csv(Training, "FILENAME")
write.csv(Testing, "FILENAME")


