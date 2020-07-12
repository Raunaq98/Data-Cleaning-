directory<- getwd()
library(dplyr)
library(tidyr)

features<- read.table(paste0(directory,"/data/features.txt"),as.is = TRUE, header = FALSE, col.names = c("n","feature"))
activities<- read.table(paste0(directory,"/data/activity_labels.txt"),as.is = TRUE, header = FALSE, col.names = c("code","activity"))

training_x <- read.table(paste0(directory,"/data/train/X_train.txt"),as.is = TRUE,header=FALSE, col.names =features$feature )
training_y <- read.table(paste0(directory,"/data/train/y_train.txt"),as.is = TRUE,header=FALSE, col.names = "code")
training_subjects <- read.table(paste0(directory,"/data/train/subject_train.txt"),as.is = TRUE,header=FALSE, col.names = "subject")

testing_x <- read.table(paste0(directory,"/data/test/X_test.txt"),as.is = TRUE,header=FALSE, col.names =features$feature )
testing_y <- read.table(paste0(directory,"/data/test/y_test.txt"),as.is = TRUE,header=FALSE, col.names = "code")
testing_subjects <- read.table(paste0(directory,"/data/test/subject_test.txt"),as.is = TRUE,header=FALSE, col.names = "subject")



# merging all data to create one data set

X <- rbind(training_x,testing_x)
Y <- rbind(training_y,testing_y)
subjects<- rbind(training_subjects,testing_subjects)
data<- cbind(subjects,Y,X)

# extracting data pertaining to only mean and standard deviation

tidy<- select(data,subject,code,contains("mean"), contains("std"))

# adding descriptive names to activities

tidy$code <- activities[tidy$code,2]

# adding descriptive names to labels
# use rsub() to replace strings in the columns

names(tidy)[2] <- "activity"
names(tidy) <-gsub("Acc","Accelerometer",names(tidy))
names(tidy) <-gsub("Gyro","Gyroscope",names(tidy))
names(tidy) <-gsub("BodyBody","Body",names(tidy))
names(tidy) <-gsub("Mag","Magnitude",names(tidy))
names(tidy) <-gsub("^t","Time",names(tidy))
names(tidy) <-gsub("^f","Frequency",names(tidy))
names(tidy) <-gsub("tBody","TimeBody",names(tidy))
names(tidy) <-gsub("angle","Angle",names(tidy))
names(tidy) <-gsub("gravity","Gravity",names(tidy))
names(tidy) <-gsub("-mean()","Mean",names(tidy),ignore.case = TRUE)
names(tidy) <-gsub("-std()","STD",names(tidy),ignore.case = TRUE)
names(tidy) <-gsub("-freq()","Frequency",names(tidy),ignore.case = TRUE)

# independent tidy data with mean of each variable for each activity and each subject

final_data<- tidy %>% group_by(subject,activity) %>%
  summarise_all(funs(mean))

#write this final data into the directory

write.table(final_data, "final.txt", row.name = FALSE)


