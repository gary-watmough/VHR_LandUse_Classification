# VHR_LandUse_Classification
Repository for certain steps in the VHR Landuse Classification Framework. 

The files are R scripts for particular steps in the LU classification framework developed by Gary R Watmough, Clare Sullivan and Cheryl A Palm abd published in International Journal of Applied Earth Observation and Geoinformation (DOI: 10.1016/j.jag.2016.09.012).

Pre-processing step 1_3_4 = Conversion of Digital Number imagery to Radiance and TOA Reflectance including calculating TOA correctuion factors (step 1), pan sharpening of the multispectral bands (step 3), creation of additional features for classification including NDVI, VARI, principal components and textural analysis (step4)
Step 6 masking script = masks the objects classified in phase 1 from the image stack in preparation for phase 2 segmentation and classification. 
Step 8 sample splitting script = the sample objects from ecognition are exported as one file. This script splits the samples 70/30 for training and testing of the subsequent random forest model. 
Step 9 RF classification script = Uses the training samples from step 8 and the segmented objects from step 7 (performed in eCognition Developer) to run a random forest classifier. Also includes quick checks of the internal Out-of-bag error so the user can identify if the samples need attention. Once model is ok (we say that a model is OK when all classes error is less than 20% in the OOB) apply the model to all of the objects segmented in step 7. 
Step 10 error estimation script = uses the testing samples created in step 8 and withheld from RF model training to estimate a confusion matrix. Some additional steps are required in a GIS prior to this script being run (see below). the output is a class confusion matrix for the phase 2 classes. Phase 1 could also be added if desired. 

Additional steps in GIS prior to confusion matrix:
Import the classified objects resulting from the step 9 script. Use the testing samples created in step 8 to run a point in polygon analysis. The samples should have a column representing the observed class value, this can be compared to the predicted class value using point in polygon and the step 10 code. 

The framework requires that all objects exported from eCognition in step 7 have either a uniqiue ID created that can be linked to the same ID number in the samples. 

