library("ggplot2")
if(is.null("NEI")||(class(NEI)!='data.frame'&&length(colnames(NEI))!=6&&length(rownames(NEI))!=64697651)){
  NEI<-readRDS("summarySCC_PM25.rds") 
}
if(is.null("SCC")||(class(SCC)!='data.frame'&&length(colnames(SCC))!=15&&length(rownames(SCC))!=11717)){
  SCC <- readRDS("Source_Classification_Code.rds")
}
tidyData<-NEI[NEI$fips=="24510",]
tidyData<-merge(tidyData,SCC,by="SCC")
# tidyData<-merge(x=tidyData,y=SCC,by="SCC")
png("plot3.png", width = 800, height = 800)
print(qplot(year,Emissions,data = tidyData,color=Data.Category,facets=.~Data.Category))
dev.off()