library(rulearn)
# Independently worded, synthetic, held-out transfer assertions.
questions <- c(
  "A fair three-sided die and a fair five-sided die: make the PMF of their sum."="discrete_pmf",
  "With two independent fair dice, find the mass distribution of their sum."="discrete_pmf",
  "What is the probability mass function of a fair dice sum?"="discrete_pmf",
  "For discrete x and p, build a cumulative distribution table."="discrete_cdf",
  "For a discrete random variable, how do I calculate F(x)?"="discrete_cdf",
  "Using a PMF, find the chance greater than 2.5."="discrete_cdf",
  "Given a Poisson arrival rate, compute exactly 5 visitors."="poisson_exact",
  "What does dpois compute for exactly two counts?"="poisson_exact",
  "For Poisson arrivals, find the probability no more than three."="poisson_cdf",
  "Evaluate ppois for up to six arrivals in a Poisson model."="poisson_cdf",
  "A Poisson process counts alerts. What is P(X>9)?"="poisson_upper_tail",
  "In a Poisson model, find at least five events."="poisson_upper_tail",
  "Is dpois equivalent to dbinom?"="NO_MATCH",
  "Is binomial ppois a valid R function combination?"="NO_MATCH",
  # P1-B added an actual interval method, superseding the P1-A no-match.
  "How do I compute punif for an interval?"="uniform_interval",
  "How to install a shower faucet?"="NO_MATCH")
for (question in names(questions)) {
  hits <- suppressMessages(ru_find(question, n=3L))
  observed <- if(nrow(hits)) hits$id[[1L]] else "NO_MATCH"
  if(!identical(observed,unname(questions[[question]])))
    stop(sprintf("P1-A transfer: %s: %s instead of %s",question,observed,questions[[question]]))
}
# Independent numerical oracles and boundary cases.
stopifnot(all.equal(stats::dpois(3,2.5), exp(-2.5)*2.5^3/factorial(3), tolerance=1e-12)==TRUE)
stopifnot(all.equal(stats::ppois(4,7),sum(stats::dpois(0:4,7)),tolerance=1e-12)==TRUE)
stopifnot(all.equal(stats::ppois(4,7,lower.tail=FALSE),sum(stats::dpois(5:80,7)),tolerance=1e-12)==TRUE)
stopifnot(all.equal(stats::ppois(3,7,lower.tail=FALSE)-stats::ppois(4,7,lower.tail=FALSE),stats::dpois(4,7),tolerance=1e-12)==TRUE)
stopifnot(identical(stats::dpois(0,0),1),identical(stats::ppois(0,0),1),identical(stats::ppois(-1,0,lower.tail=FALSE),1))
a<-1:4;b<-1:5;outcomes<-as.vector(outer(a,b,"+"))
m<-prop.table(table(outcomes));stopifnot(length(outcomes)==20L,abs(sum(m)-1)<1e-12,as.numeric(m[["5"]])==0.2)
x<-c(0.5,1.5,3);p<-c(0.2,0.5,0.3);F<-cumsum(p)
stopifnot(all(diff(F)>=0),tail(F,1)==1,abs(sum(p[x<=1.8])-0.7)<1e-12,abs(sum(p[x>1.8])-0.3)<1e-12)
cat("P1-A held-out 16/16 and numerical boundary checks PASS\n")
