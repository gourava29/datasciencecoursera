
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
png("plot3.png", width = 480, height = 480)
plot(houseHoldData$Sub_metering_1~houseHoldData$Datetime, type="l",
     ylab="Energy sub metering", xlab="")
lines(houseHoldData$Sub_metering_2~houseHoldData$Datetime,col='Red')
lines(houseHoldData$Sub_metering_3~houseHoldData$Datetime,col='Blue')
legend("topright", col=c("black", "red", "blue"), lty=1, lwd=2, 
       legend=c("Sub_metering 1", "Sub_metering 2", "Sub_metering 3"))
dev.off()