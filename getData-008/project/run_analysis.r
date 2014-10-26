library(data.table)
library(reshape2)
#getting subject data for training and test

subjectTestDt<-fread("UCI HAR Dataset/test/subject_test.txt")
subjectTrainDt<-fread("UCI HAR Dataset/train/subject_train.txt")

#getting activity names/labels data

activityNumTrainDt<-fread("UCI HAR Dataset/train/y_train.txt")
activityNumTestDt<-fread("UCI HAR Dataset/test/y_test.txt")

#getting data set for training and testing

testSetDt<-data.table(fread("UCI HAR Dataset/test/X_test.txt"))
trainSetDt<-data.table(fread("UCI HAR Dataset/train/X_train.txt"))

#binding test and train data for subject,activitynums and data sets

subjectDt<-rbind(subjectTestDt,subjectTrainDt)
setnames(subjectDt,"V1","subject")

activityNumDt<-rbind(activityNumTrainDt,activityNumTestDt)
setnames(subjectDt,"V1","activityNum")

dataSetDt<-rbind(testSetDt,trainSetDt)

finalDt<-cbind(cbind(subjectDt,activityNumDt),dataSetDt)
#set key is used to make sure that the table is sorted with key combination.
setkey(finalDt,subject,activityNum)

#getFeautures list

featuresDt<-data.table(fread("UCI HAR Dataset/features.txt"))
setnames(featuresDt,c("featureIndex","featureName"))

#filter out features with string mean or std in its featureName
featuresDt<-featuresDt[grepl("mean|std",featureName)]

#appending V to the featureIndex, so that they can be mapped with our finalDt column names
featuresDt$featureCode<-featureDt[,paste0("V",featureIndex)]

#filter finalDt, with only mean and std data with there subject and activity which are keys of the finalDt table

finalDt<-finalDt[,c(keys(finalDt),featuresDt$featureCode),with=FALSE]

#read activityData

activityDt<-data.table(fread("UCI HAR Dataset/activity_labels.txt"))
setnames(activityDt,c("V1","V2"),c("activityNum","activityName"))

#merge activityDt with finalDt by activityNum

finalDt<-merge(finalDt,activityDt,by="activityNum",all.x = TRUE)
setkey(finalDt,subject,activityNum,activityName)

#create a tiddier data using melt

finalDt<-melt(finalDt,key(finalDt),variable.name = "featureCode")

#creating a filter function to pull out data based on regex
filterFeature<-function(regex){
    return(grepl(regex,finalDt$featureName))
}

#to map the data with 2 types we would create a 2*1 matrix which would be logical matrix and map it with the matrix data which we get after 
#   filtering out types

    #calculate featType which means which type(time or frequency) the action belongs 
    # actions which start with t is time and which starts with f is frequency
    n<-2
    y<-matrix(seq(1, n), nrow=n)
    x<-matrix(c(filterFeature("^t"), filterFeature("^f")), ncol=nrow(y))
    finalDt$featType <- factor(x %*% y, labels=c("Time", "Freq"))
    
    #calculate featInstrument which means which instrument(accelerometer or gyroscope) the action belongs 
    # actions which contains "Acc" or "Gyro"
    x<-matrix(c(filterFeature("Acc"), filterFeature("Gyro")), ncol=nrow(y))
    finalDt$featInstrument <- factor(x %*% y, labels=c("Accelerometer", "Gyroscope"))

    #calculate featAcceleration which means which type of acceleration
    # actions which contains "BodyAcc" or "GravityAcc"
    x<-matrix(c(filterFeature("BodyAcc"), filterFeature("GravityAcc")), ncol=nrow(y))
    finalDt$featAcceleration <- factor(x %*% y, labels=c(NA, "Body", "Gravity"))

    #calculate featOperation which means the type of operation which is mean or std
    x <- matrix(c(filterFeature("mean()"), filterFeature("std()")), ncol=nrow(y))
    finalDt$featOperation <- factor(x %*% y, labels=c("Mean", "SD"))


#to map the data with 3 types we would create a 3*1 matrix which would be logical matrix and map it with the matrix data which we get after 
#   filtering out types
    
    #calculating featAxis, filtering out all the actions which contains X, Y or Z in it
    n <- 3
    y <- matrix(seq(1, n), nrow=n)
    x <- matrix(c(filterFeature("-X"), filterFeature("-Y"), filterFeature("-Z")), ncol=nrow(y))
    finalDt$featAxis <- factor(x %*% y, labels=c(NA, "X", "Y", "Z"))

#filtering out jerk and magnitude
    finalDt$featJerk <- factor(filterFeature("Jerk"), labels=c(NA, "Jerk"))
    finalDt$featMagnitude <- factor(filterFeature("Mag"), labels=c(NA, "Magnitude"))

#creating final tidy set

setkey(finalDt, subject, activityName, featType, featAcceleration, featInstrument, featJerk, featMagnitude, featOperation, featAxis)
tidyDt <- finalDt[, list(count = .N, average = mean(value)), by=key(finalDt)]

write.table(tidyDt,"tidyDataOutput.txt")


