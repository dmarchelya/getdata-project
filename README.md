# Getting and Cleaning Data Course Project
## `run_analysis.R` Explained

### Requirement #1 - Merges the training and the test sets to create one data set

1. Reads the test and train data sets each into their own data frame using `read.table`.
2. Combines the test and train data sets into one data frame using `rbind` to append the rows from each data frame together.
3. Reads the variable names in from `features.txt` and sets the names of the variables in the combined data frame.
4. Reads the subject IDs for the test and train data sets into separate variables from their respective txt files.
5. Combines the test and train subject ID data frame rows together by using `rbind` to append the rows from each data frame.
6. Applies the label "Subject_ID" to the IDs column
7. Combines the combined variable data frame to the subject ID's data frame by using `cbind`.

### Requirement #2 - Extracts only the measurements on the mean and standard deviation for each measurement

1. Extracts the mean, standard deviation (and Subject ID) columns from the combined data frame using subsetting and `grep`

### Requirement #3 - Uses descriptive activity names to name the activities in the data set

1. Reads in the test and train activity IDs from their respective txt files as independent data frames
2. Combines the test and train activity IDs using `rbind` to combine their rows vertically, and names the column for those IDs as "Activity_ID".
3. Combines those test and train activity IDs to the filtered variable data frame containing the mean and standard deviation measurements
4. Reads in the activity labels from the txt file, and sets the column names for that data frame.
5. Merges the activity labels to the test and train variable data frame.  Note that this reorders data.

### Requirement #4 - Appropriately labels the data set with descriptive variable names

1. For each of the column that is a measurement / variable for the test and train data.
2. Parse the name of the column using `grepl` to determine if it meets certain criteria, and assign each criteria match to a varible.
3. For each criteria match, use a series of paste operation to build up a more descriptive string to describe that variable.
4. Append the label for each column to a character vector of descriptive variable names.
5. Apply the character vector of descriptive variable names to the data frame, along with the labels for the other columns.

### Requirement #5 - Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

1. `Melt` the working data frame with the merged test and train data by Activity Name and Subject ID, and purposely eliminating the Activity_Id with a subset
2. Apply a `dcast` on the melted data frame by Activity Name and Subject ID, aggregating using the mean operation.
3. Write the final data set to a file named `getdata-course-project-tidy-data.txt` in the working directory.
