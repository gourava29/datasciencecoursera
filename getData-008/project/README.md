Documentation for run_analysis.R
=================================

-------------------------------------------------------------------------------------------

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected. 

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

 	You should create one R script called run_analysis.R that does the following. 

    Merges the training and the test sets to create one data set.
    Extracts only the measurements on the mean and standard deviation for each measurement. 
    Uses descriptive activity names to name the activities in the data set
    Appropriately labels the data set with descriptive variable names. 

    From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Good luck!

-------------------------------------------------------------------------------------------

Step1 : As mentioned in the above assignment, we need to merge the training and test sets to create one data set and then extract only the mean and standard deviation for each measurement.

	1) To do this we first, merged the the training set(train_x.txt) and test set(test_x.txt) using rbind

		dataSetDt<-rbind(trainSetDt,testSetDt)

	2) Merged the subject data for train and test

		subjectDt<-rbind(testSubjectDt,trainSubjectDt)

	and then named subjectDt column with the variable name "subject", so as to identify the what that column represent in the finalDt.

	We then acquired the y_train.txt and y_test in activityDt and renamed the column in 
	activityDt "V1" to "activityNum"
		activityNumTrainDt<-fread("UCI HAR Dataset/train/y_train.txt")
		activityNumTestDt<-fread("UCI HAR Dataset/test/y_test.txt")
		activityDt<-rbind(activityNumTrainDt,activityNumTestDt)
		setnames(activityDt,"V1","activityNum")

	3)finalDt was acquired, by column bind subjectDt,activityDt and dataSetDt.

		finalDt<-cbind(cbind(subjectDt,activityDt),dataSetDt)

	4) Get feature list and rename the column name with featureNum and featureName respectively

		featureDt<-data.table(fread("features.txt"))
		setnames(featureDt,c("featureNum","featureName"))

	5) Filtering out only the mean and sd from the whole list of features and getting there corresponding featureNum

		featureDt<-featureDt[grepl("mean|sd"),featureName]

	6) Prepending "V" to featureNum so that they can be mapped with our finalDt column names(measurements).

		featureDt$featureCode<-featureDt[,paste0("V",featureNum)]

	7)Now filtering out mean and sd features from our finalDt

		finalDt<finalDt(,c(Keys(finalDt),featureDt$featureCode),with=FALSE)

	8)get Activity data from activity_labels.txt and rename the columns "V1","V2" with
	"activityNum","activityName" respectively

		activityDt<-data.table(fread("UCI HAR Dataset/activity_labels.txt"))
		setnames(activityDt,c("V1","V2"),c("activityNum","activityName"))

	9)merge with finalDt

		finalDt<-merge(finalDt,activityDt,by="activityNum",all.x = TRUE)
		setkey(finalDt,subject,activityNum,activityName)

	10)Finally melt the data and get the required variables in the dataSet

		finalDt<-melt(finalDt,keys(finalDt),variable.name="featureCode")

		the above statement will get all the measurement variable i.e. featureCode from the column of the finalDt, and move it to a single column named featureCode

	11) Finally merge the featureDt with finalDt to get the featureName

		finalDt<-merge(finalDt,featureDt,by="featureCode")

	Successfully merged training and test data set filtering out mean and sd from it

Step2:  From the finalDt acquired, create a second, independent tidy data set with the average of each variable for each activity and each subject.

	To do this, we must first filter out each activity and each subject then perform mean on the combination and store it in a new variable which would represent the activity or subject

	1)create a function filterFeature which would take a regex expression as input and returns logical vector of that regex from featureName

		filterFeature<-function(regex){
			return(grepl(regex,featureName))
		}

	2)Calculating the featType which would average of all the operations which were calculated either in time or freq as units.

	    n<-2
	    y<-matrix(seq(1, n), nrow=n)
	    x<-matrix(c(filterFeature("^t"), filterFeature("^f")), ncol=nrow(y))
	    dt$featType <- factor(x %*% y, labels=c("Time", "Freq"))

	3)Repeating the step 2 we would calculate featInstrument( contains "Acc|Gyro" ),featAcceleration( contains "BodyAcc|GravityAcc" ),featVariable( contains "mean|std" )

	4)Now we'll calculate featAxis, in which each axis represent the which angle it was performed, hence merging the data based on axis("X","Y","Z")

		To do this we'll create a 3x1 logical vector

		n<-3
	    y<-matrix(seq(1, n), nrow=n)
	    x<-matrix(c(filterFeature("-X"), filterFeature("-Y"), filterFeature("-Z")), ncol=nrow(y))
	    dt$featAxis <- factor(x %*% y, labels=c("Time", "Freq"))

	5)Calulating featJerk and featMagintude
		
		dt$featJerk <- factor(filterFeature("Jerk"), labels=c(NA, "Jerk"))
		dt$featMagnitude <- factor(filterFeature("Mag"), labels=c(NA, "Magnitude"))

	6)Creating a final tidyDt, by calculating mean of all possible keys combination.

		setkey(dt, subject, activityName, featType, featAcceleration, featInstrument, featJerk, featMagnitude, featVariable, featAxis)
		tidyDt <- dt[, list(count = .N, average = mean(value)), by=key(dt)]










