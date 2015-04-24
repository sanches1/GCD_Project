#This R script does the following:
#Merges the training and the test sets to create one data set.
#Extracts only the measurements on the mean and standard deviation for each measurement. 
#Uses descriptive activity names to name the activities in the data set
#Appropriately labels the data set with descriptive variable names. 
#From the data set in step 4, creates a second, independent tidy data set with the average of each variable
#for each activity and each subject.

#setwd("~/R/Getting and Cleaning Data")
library(data.table)
library(dplyr)
#Here are the data for the project: 
#fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#download.file(fileUrl,destfile="./dataset.zip")
# 'train/X_train.txt': Training set.
# 'train/y_train.txt': Training labels.
# 'test/X_test.txt': Test set.
# 'test/y_test.txt': Test labels.

#1. Merges the training and the test sets to create one data set.
trainData<-read.table("dataset/UCI HAR Dataset/train/x_train.txt")
trainLabels<-read.table("dataset/UCI HAR Dataset/train/y_train.txt")
trainSubj<-read.table("dataset/UCI HAR Dataset/train/subject_train.txt")
train<-cbind(trainSubj, trainLabels, trainData)

testData<-read.table("dataset/UCI HAR Dataset/test/x_test.txt")
testLabels<-read.table("dataset/UCI HAR Dataset/test/y_test.txt")
testSubj<-read.table("dataset/UCI HAR Dataset/test/subject_test.txt")
test<-cbind(testSubj, testLabels, testData)

mergedData<-rbind(train, test)

#4. Appropriately labels the data set with descriptive variable names. 
#We read in features to get the given column names. "-" will be replaced by ".". "()" and digits will be removed.
labels<-scan("dataset/UCI HAR Dataset/features.txt", what="character")
labels2<-gsub("-",".", labels)
labels3<-gsub("\\(\\)","",labels2)
labels4<-grep("[[:alpha:]]", labels3,value=TRUE)
labels5<-as.vector(cbind(c("Subject","Activity",labels4)))
names(mergedData)<-labels5

#2. Extracts only measurements on the mean and standard deviation for each measurement. 
meanstd<-mergedData[,grep("\\.mean\\.|\\.std\\.|mean$|std$|Subject|Activity",colnames(mergedData))]

#3. Uses descriptive activity names to name the activities in the data set
activities<-scan("dataset/UCI HAR Dataset/activity_labels.txt", what="character")
activities1<-grep("[[:alpha:]]", activities,value=TRUE)
actframe=as.data.frame(cbind(c(1:6),activities1))
names(actframe)<-c("Activity","ActivityName")
tidyData<-merge(actframe,meanstd,by="Activity")

#5. Creates a second, independent tidy data set with the average of each 
#   variable for each activity and each subject.
grouped<-group_by(tidyData, Activity, ActivityName, Subject)
tidyDataMeans<-summarise_each(grouped, funs(mean))

#output tidy dataset
write.table(tidyDataMeans, file="tidyDataMeans.txt", row.name=FALSE)

