library("ggplot2")
if(is.null("NEI")||(class(NEI)!='data.frame'&&length(colnames(NEI))!=6&&length(rownames(NEI))!=64697651)){
  NEI<-readRDS("summarySCC_PM25.rds") 
}
if(is.null("SCC")||(class(SCC)!='data.frame'&&length(colnames(SCC))!=15&&length(rownames(SCC))!=11717)){
  SCC <- readRDS("Source_Classification_Code.rds")
}
tidyData<-NEI[NEI$fips=="24510",]
# tidyData<-merge(x=tidyData,y=SCC,by="SCC")
png("plot2.png", width = 480, height = 480)
print(qplot(year,Emissions,data = tidyData))
dev.off()