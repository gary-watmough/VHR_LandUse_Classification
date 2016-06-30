## Post step 10 - creating confusion matrix for publication
## written by Gary r Watmough 2016
## requires some additional editing work to create the error samples which is detailed in a separate readme

######create an error matrix for the phase 1 samples and classification#####

## remove existing data and operations from R memory
rm(list=ls())

## call caret
library(caret)
library(foreign)

## open the classification results
mydata<-read.dbf("FILENAME")
## create the matrix.
## confusionMatrix(data, reference, positive, dnn, prevalence)
## data = predicted land cover from the classification 
## reference = the land cover sample 
## positive = this is not useful for our purposes. 
## dnn = names for the rows and columns, we call it samples, and class to correspond to the 
## classified land cover and the land cover sample
## prevalence - again this is not useful for our data. 
Conf.table<-confusionMatrix(mydata$Pred_num, mydata$Class_Num, positive=NULL, 
                            dnn= c("Class", "Sample"), prevalence=NULL)

## call the table
Conf.table

##  the overall value from confusion matrix provides ooverall accuracy and kappa statistic
Conf.table$overall

## the byClass value gives details of the specificity and senssitvity of each of the classes 
## these will correspond to users and producers accuracies

## definitions are and how they correspond to the conventional RS errors
Conf.table$byClass

## the table value from the confusion matrix gives the class comparisons and allows us to look 
## at the errors of omission and commission. 
Conf.table$table

## save the table as a matrix
full_error<-Conf.table$table

##create a class total and a sample total for each land cover. 

class_total<-rowSums(full_error)
sample_total<-colSums(full_error)

## bind the sums to the error matrix

full_error<-cbind(full_error, class_total)
full_error<-rbind(full_error, sample_total)

full_error

##calculate total number of classes and total number of samples, these should be the same
all_sam<-sum(full_error[11,1:10])
all_clas<-sum(full_error[1:10, 11])

##add this total to the bottom right hand corner of the error table
full_error[11,11]<-c(666)

full_error
#################
## add in the producers, users, omission and commission accuracy/errors. 
#################

## producers accuracy is the # of correctly classified objects or pixels / the total number of samples. 
## in the confusionMatrix function it is called Sensitivity
## users is the #of correctly classified / the total number classified in that class
## this is called Pos.Pred.values in the confusionMatrix output. 
errors<-data.frame(Conf.table$byClass)
producers<-round(errors$Sensitivity, digits=2)
users<-round(errors$Pos.Pred.Value, digits=2)

## omission is 1-user accuracy and indicates the chance of excluding a pixel that should have been included in the class. 
omission<-1-producers

## commission is 1-producers accuracy and indicates the chance of including a pixel in a class when it should have been excluded
commission<-1-users

##################
## join the additional errors to the error table
##################
## start by adding in a new row of NA's to the bottom of full_error
full_error<-rbind(full_error, NA)

## replace the NA's in row 12 column 1:10 with the values of producers accuracy, , these numbers will change depending
## on the number of classes that are classified. 
full_error[12,1:10] <- producers

## repeat for omission errors

full_error<-rbind(full_error, NA)
full_error[13, 1:10]<-omission

## do the same for the columns and users accuracy and commission error

full_error<-cbind(full_error, NA)

## replace the NA's in column 12 row 1:10 with the values of producers accuracy
full_error[1:10,12] <- users

## repeat for comission errors

full_error<-cbind(full_error, NA)
full_error[1:10, 13]<-commission

## create a list of dimnames for the error matrix

row_names<-c("Agriculture", "BareAgri", "BareGround", "Grass", "IrrigatedAgri", "IrrigatedBare", "Shadow", "Shrub", "Tree", "Woody", "Sample Total", "Producers", "Omission")
col_names<-c("Agriculture", "BareAgri", "BareGround", "Grass", "IrrigatedAgri", "IrrigatedBare", "Shadow", "Shrub", "Tree", "Woody", "Class Total", "Producers", "Omission")

## add the names to the full error matric
rownames(full_error)<-row_names
colnames(full_error)<-col_names

full_error

## save

write.csv(full_error, "FILENAME")
