# How do I make a bar chart with readable category labels and counts?
# Independent illustrative data.
responses <- c("bus","bike","bus","walk","walk","bus","bike")
counts <- table(responses)
at <- barplot(counts,col=c("#CDE1EF","#EAC99E","#B7D7C5"),
              border="#244967",ylab="Responses",
              main="Travel choices",ylim=c(0,max(counts)+2))
text(at,counts,labels=counts,pos=3)
