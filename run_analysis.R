if(!require(reshape2)){
  install.packages("reshape2")
  library(reshape2)
}

#Requirement #1 - Merges the training and the test sets to create one data set
test_x <- read.table("test/X_test.txt", sep="", strip.white = TRUE, colClasses = "numeric")
train_x <- read.table("train/X_train.txt", sep ="", strip.white = TRUE, colClasses = "numeric")

combined_x <- rbind(test_x, train_x)

variable_names <- read.table("features.txt")
names(combined_x) <- variable_names$V2

subject_test <- read.table("test/subject_test.txt", colClasses = "numeric")
subject_train <- read.table("train/subject_train.txt", colClasses = "numeric")

combined_subject <- rbind(subject_test, subject_train)
names(combined_subject) <- c("Subject_ID")

combined_test_train <- cbind(combined_x, combined_subject)

#Requirement #2 - Extracts only the measurements on the mean and standard deviation for each measurement
filtered_test_train <- combined_test_train[,grep("-mean|-std|Subject_ID", colnames(combined_test_train))]

#Requirement #3 - Uses descriptive activity names to name the activities in the data set
test_activity_id <- read.table("test/Y_test.txt")
train_activity_id <- read.table("train/Y_train.txt")
combined_activity_id <- rbind(test_activity_id, train_activity_id)
names(combined_activity_id)[1] <- "Activity_ID"

combined_filtered_test_train <- cbind(filtered_test_train, combined_activity_id)

activity_labels <- read.table("activity_labels.txt", sep ="", strip.white = TRUE)
names(activity_labels) <- c("Activity_ID", "Activity_Name")

merged_test_train <- merge(combined_filtered_test_train, activity_labels, by="Activity_ID") #NOTE: This re-orders the data

#Requirement #4 - Appropriately labels the data set with descriptive variable names
descriptive_variable_names <- character(0)

for (i in 1:ncol(filtered_test_train)) {
  
  name <- names(filtered_test_train)[i]
  
  if(name == "Subject_ID")
    next
  
  signal_type <- substr(name,1,1)
  is_body <- grepl("Body", name)
  is_gravity <- grepl("Gravity", name)
  is_acceleration <- grepl("Acc", name)
  is_jerk <- grepl("Jerk", name)
  is_gyroscope <- grepl("Gyro", name)
  is_magnitude <- grepl("Mag", name)
  is_mean <- grepl("-mean()", name, fixed = TRUE)
  is_mean_frequency <- grepl("-meanFreq()", name, fixed = TRUE)
  is_std_dev <- grepl("-std()", name, fixed = TRUE)
  is_x_axis <- grepl("-X", name)
  is_y_axis <- grepl("-Y", name)
  is_z_axis <- grepl("-Z", name)
  
  label <- ifelse(is_body, "Body_", "")
  label <- paste(label, ifelse(is_gravity, "Gravity_", ""), sep = "")
  label <- paste(label, ifelse(is_acceleration, "Acceleration_", ""), sep = "")
  label <- paste(label, ifelse(is_gyroscope, "Gyroscope_", ""), sep = "")
  label <- paste(label, ifelse(is_jerk, "Jerk_", ""), sep = "")
  label <- paste(label, ifelse(is_magnitude, "Magnitude_", ""), sep = "")
  label <- paste(label, ifelse(is_mean, "Mean_", ""), sep = "")
  label <- paste(label, ifelse(is_mean_frequency, "Mean_Frequency_", ""), sep = "")
  label <- paste(label, ifelse(is_std_dev, "Standard_Deviation_", ""), sep = "")
  label <- paste(label, ifelse(is_x_axis, "X-Axis_", ""), sep = "")
  label <- paste(label, ifelse(is_y_axis, "Y-Axis_", ""), sep = "")
  label <- paste(label, ifelse(is_z_axis, "Z-Axis_", ""), sep = "") 
  
  label <- paste(label, ifelse(signal_type == "f", "Frequency_Signal", ""), sep = "")
  label <- paste(label, ifelse(signal_type == "t", "Time_Signal", ""), sep = "")
  
  has_trailing_underscore <- substr(label,length(label) - 1, length(label)) == "_"
  
  label <- ifelse(has_trailing_underscore, substr(label, 1, length(label - 1)), label)
  
  #Set to blank for labels without a signal type (i.e. not a valid feature, for our purposes)
  label <- ifelse(signal_type == "t" | signal_type == "f", label, "")
  
  if(label == "") stop("Invalid Label Found")
    
  descriptive_variable_names <- c(descriptive_variable_names, label)
}

names(merged_test_train) <- c("Activity_ID", descriptive_variable_names, "Subject_ID", "Activity_Name")

#Requirement #5 - Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

melt_test_train <- melt(merged_test_train[,2:ncol(merged_test_train)],id=c("Activity_Name","Subject_ID")) #eliminating the Activity_Id from merged_test_train with the subset

final_test_train <- dcast(melt_test_train, Activity_Name + Subject_ID ~ variable, fun.aggregate = mean)

write.table(final_test_train, file="getdata-course-project-tidy-data.txt", sep = "\t", row.name=FALSE)
