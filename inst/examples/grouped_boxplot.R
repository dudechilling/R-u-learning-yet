# How do I compare the distribution of measurements across groups?
# Independent illustrative data.
site <- rep(c("coast","inland"),each=6)
temp_c <- c(12,13,12,15,14,13,18,19,20,21,18,22)
print(table(site))
boxplot(temp_c ~ site,col=c("#CEE2F0","#EAC99E"),
        main="Temperatures by setting",ylab="Temperature (C)",xlab="Setting")
legend("topright",legend=c("Coast","Inland"),
       fill=c("#CEE2F0","#EAC99E"),bty="n")
