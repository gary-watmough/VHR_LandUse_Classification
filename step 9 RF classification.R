## Step 9 Random froest classification of VHR data
## Written by Gary R Watmough 2016
## applies the samples generated in step 8 to the objects exported from Phase 2 of the framework. 
## use the training dataframe created in the step 6 sample splitting script. 

##first train the model on training data
##second apply the model to all of the objects exported from ecognition developer 9.2

rm(list=ls())

##open training data
train<-read.csv("D:\\IIASA\\Uganda\\Uganda Image processing\\Uganda2015\\Phase2\\RandomForest\\Training_samples.csv")

##subset the data to remove the FID_1 columns, this will make the code shorter
## for the random forest models
Train<-subset(train, select=-c(X.1, FID_1, Class_Num, X, Y))
names(Train)

## run random forest 
library(randomForest)
## we specify ntree which is the number of trees that should be calcuated. 
RF.1<-randomForest(Class_Name~. , data=Train, ntree=1000)
##examine the confidence table (error table)
##if some classes have large misclassification errors return to step 7 and check if the samples are 
##ok. inparticular check on classes that appear to have large overlap in the confidence table. 
RF.1$conf
##if necessary change the samples. 

## If changes made repeat the RF model again when the conf table is adeuqate run more indepth 
##analysis 

## look at the confusion matrix from the random forest model - out-of-bag error is the error of the overall model. 
## so we average the OOB error across all 1000 trees 
mean.OOB.err<-apply(RF.1$err.rate, 2, mean)
mean.OOB.err
##print the mean OOB - this the error of the model. 

######################### predict the land covers in the other objects ##############################
##once happy with the model stats from training can apply the model to all of the objects across the
## study site. 
## load the database that contains all of the objects in
Allobjects<-read.csv("FILENAME")
##check that the names in the ALLobjects DF are the same as those in the Train DF above. 
names(Allobjects)
## drop Gary_ID variable from the Uganda_All dataframe to make sure that the RF.1 and 
## Allobjects dataframes have the same parameter names 
All_obs<-subset(Uganda_All, select=-c(Gary_ID))

## use the predict function to apply the random forest model from above to the rest of the data
preds<-predict(RF.1, Allobjects)
## join the classification with All samples again for validation in ArcMap/R 
RF.classified<-cbind(Allobjects, preds)

## subset the dataframe to the GARY_ID and Preds variable for joining in ArcMap
Finalpred<-subset(RF.classified, select=c(Gary_ID, preds))
head(Finalpred)
## export the RF classification 
write.csv(Finalpred, "FILENAME")

