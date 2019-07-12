rm(list=ls())

install.packages("dplyr")
library("dplyr")

## Download dataset
setwd("C:/Karen/R/Course 3/Project")
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("./project.zip")){
    download.file(fileUrl, destfile = "./project.zip")
}

# Unzipping the data
unzip("./project.zip")

# Reading the data
features<-read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activities<-read.table("UCI HAR Dataset/activity_labels.txt", col.names=c("code","activity"))
sub_test<-read.table("UCI HAR Dataset/test/subject_test.txt", col.names="subject")
x_test<-read.table("UCI HAR Dataset/test/X_test.txt", col.names=features$functions)
y_test<-read.table("UCI HAR Dataset/test/y_test.txt", col.names="code")
sub_train<-read.table("UCI HAR Dataset/train/subject_train.txt", col.names="subject")
x_train<-read.table("UCI HAR Dataset/train/x_train.txt", col.names = features$functions)
y_train<-read.table("UCI HAR Dataset/train/y_train.txt", col.names="code")


###################################################################
## 1. Merge training and test sets
###################################################################
x<-rbind(x_train, x_test)
y<-rbind(y_train, y_test)
subjects<-rbind(sub_train, sub_test)
merged_dt<-cbind(subjects, y, x)
head(merged_dt)

###################################################################
## 2 Extract only the measurements on the mean and standard deviation for each measurement
###################################################################

tidy_dt <- merged_dt %>% select(subject, code, contains("mean"), contains("std"))
head(tidy_dt)

######################################################################
## 3.Uses descriptive activity names to name the activities in the data set
######################################################################

tidy_dt$code<-activities[tidy_dt$code,2]
head(tidy_dt)
#################################################################################
## 4. Uses descriptive activity names to name the activities in the data set
#################################################################################
names(tidy_dt)[2]="activity"
names(tidy_dt)<-gsub("Acc","Accelerometer",names(tidy_dt))
names(tidy_dt)<-gsub("Gyro","Gyrometer",names(tidy_dt))
names(tidy_dt)<-gsub("BodyBody","bodyr",names(tidy_dt))
names(tidy_dt)<-gsub("Mag", "Magnitude", names(tidy_dt))
names(tidy_dt)<-gsub("^t", "Time", names(tidy_dt))
names(tidy_dt)<-gsub("^f", "Frequency", names(tidy_dt))
names(tidy_dt)<-gsub("tBody", "TimeBody", names(tidy_dt))
names(tidy_dt)<-gsub("-mean()", "Mean", names(tidy_dt), ignore.case = TRUE)
names(tidy_dt)<-gsub("-std()", "STD", names(tidy_dt), ignore.case = TRUE)
names(tidy_dt)<-gsub("-freq()", "Frequency", names(tidy_dt), ignore.case = TRUE)
names(tidy_dt)<-gsub("angle", "Angle", names(tidy_dt))
names(tidy_dt)<-gsub("gravity", "Gravity", names(tidy_dt))

#########################################################################################
## 5. From the data set in step 4, creates a second, independent tidy data set with the average 
## of each variable for each activity and each subject.
#########################################################################################
final_dt <- tidy_dt %>%
    group_by(subject, activity) %>%
    summarise_all(funs(mean))
write.table(final_dt, "final_dt.txt", row.name=FALSE)
