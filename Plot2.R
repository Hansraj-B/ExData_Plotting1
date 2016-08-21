#********************************************************************
#1. Donwload and extract File to local drive
#********************************************************************

#A. Set working ddirectory
setwd("~/Data Scientist/Projects/ExpGraph")
#B. clear memory
rm(list=ls())

#C. create download directory
if (!file.exists("./data")) {
    dir.create("./data")
}

#D. set url and file name
furl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
fname <- file.path("./data" , "exdata_data_household_power_consumption.zip")
fpath <-  file.path("./data" , "household_power_consumption.txt")

#E. downlad the file
if (!file.exists(fname)) {
    download.file(furl, destfile = fname);
}

#F. unzip if not already unzipped
if (!file.exists(fpath))   unzip(fname,exdir='./data')  else {message(paste(fpath, 'already exists'))}



#********************************************************************
#2.Read file into memory
#********************************************************************
#epc <- read.table(fpath, ,header=TRUE,stringsAsFactors=FALSE, sep=";") - this is possible
#using RSQLite based on stackoverflow
library(RSQLite)
# Create/Connect to a database
con <- dbConnect(RSQLite::SQLite(), dbname = "epcDB")

# read file into local database - done just once 
dbWriteTable(con, name="epcTBL", value=fpath, row.names=FALSE, header=TRUE, sep = ";", overwrite=TRUE)

qry <- 'SELECT * FROM epcTBL WHERE Date=\'1/2/2007\' OR Date=\'2/2/2007\''
epc <- dbGetQuery(con, qry)

#disconnect connection
dbDisconnect(con)


#********************************************************************
#3. Update the classes
#********************************************************************
library(lubridate)
epc$Date = dmy(epc$Date)
epc$Time <- ymd_hms(paste(as.character(epc$Date),epc$Time)) #convert to time
epc[3:9] <- lapply(epc[3:9], as.numeric) #conver rest of columns to numeric



#********************************************************************
#4. plot1
#********************************************************************
#open png device
png(file="plot2.png", width=480, height=480)
#Create plot
plot(epc$Time,epc$Global_active_power, type='l', xlab='', ylab='Global Active Power (kilowatts)')
dev.off() ##Close the graphics device

message('Plot generated')

