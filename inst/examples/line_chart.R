# How do I plot values across dates or ordered time points?
# Independent illustrative data.
days <- as.Date("2026-01-01") + 0:6
temperature_c <- c(2,4,3,6,7,5,4)
plot(days,temperature_c,type="b",pch=19,col="#3F78A8",
     xlab="Date",ylab="Temperature (C)",
     main="Week of measurements")
grid(col="gray85")
