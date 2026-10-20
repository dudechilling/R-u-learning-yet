# How do I check whether a measurement resembles earlier observations?
# Independent illustrative data.
set.seed(25)
x <- as.numeric(arima.sim(model=list(ar=.6),n=100))
plot.ts(x,col="#3F78A8",ylab="Simulated value",
        main="Example with time dependence")
acf(x,main="Autocorrelation by lag",col="#A35E20")
