library("data.table")
library("plyr")
houseHoldData<-data.table(fread('household_power_consumption.txt'))
houseHoldData<-subset(houseHoldData,Date=='1/2/2007'|Date=='2/2/2007')
houseHoldData$Global_active_power<-as.numeric(houseHoldData$Global_active_power)
datetime<-paste(houseHoldData$Date,houseHoldData$Time)
datetime<-strptime(datetime,format="%d/%m/%Y %H:%M:%S")
datetime<-as.POSIXct(datetime)
houseHoldData$Datetime<-datetime
remove(datetime)
png("plot2.png", width = 480, height = 480)
plot(houseHoldData$Global_active_power~houseHoldData$Datetime, type="l",
     ylab="Global Active Power (kilowatts)", xlab="")
dev.off()