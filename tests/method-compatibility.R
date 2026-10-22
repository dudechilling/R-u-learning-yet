# P0-A: original synthetic question-first method-compatibility tests.
# Missing verified methods must abstain rather than show a wrong calculation.
library(rulearn)
stopifnot(as.character(packageVersion("rulearn"))=="0.4.2.9001")
check_route <- function(label, question, expected) {
  printed <- capture.output(hits <- ru_find(question,n=3L))
  stopifnot(length(printed)==0L, is.data.frame(hits))
  observed <- if(nrow(hits)) hits$id[[1L]] else "NO_MATCH"
  if(!identical(observed,expected))
    stop(label, ": expected ",expected,", obtained ",observed,
         " for ",encodeString(question,quote="\""),call.=FALSE)
  if(expected=="NO_MATCH" && nrow(hits)!=0L)
    stop("An incompatible suggestion escaped: ",label,call.=FALSE)
  invisible(TRUE)
}
# Exact P0 subset of the original synthetic 42-question design corpus.
p0 <- list(
  c("Q01","A fair six-faced die and a fair four-faced die are rolled: how can I make the PMF of their sum?","discrete_pmf"),
  c("Q02","I have a table of x and probabilities. How do I accumulate it into F(x)?","discrete_cdf"),
  c("Q03","For a discrete variable how do I find P(X>3) from its PMF?","discrete_cdf"),
  c("Q04","A discrete probability chart is given. What's the CDF at or below 4?","discrete_cdf"),
  c("Q05","Events happen according to a Poisson model. What is the chance of exactly 4 in one interval?","poisson_exact"),
  c("Q06","The expected arrivals are 6. How do I get P(N<=2) using R?","poisson_cdf"),
  c("Q07","If a Poisson count exceeds 7, how do I compute that probability?","poisson_upper_tail"),
  c("Q08","How can I compute P(2<U<5) for a continuous uniform variable on [0,8]?","uniform_interval"),
  c("Q09","What does punif return for a number on a uniform distribution?","uniform_cdf"),
  c("Q10","I have 12 independent yes/no trials with success probability .3. Probability exactly 4?","binomial_exact"),
  c("Q11","Find probability a normal measurement lies between 2 and 6 given mean 3 and SD 1.5.","normal_between"),
  c("Q12","My task asks P(1 < X < 3) in a normal model. Should I use one tail?","normal_between"),
  c("Q13","How does dpois differ from dbinom?","NO_MATCH"),
  c("Q14","Can I use a binomial distribution for a wait time recorded in minutes?","NO_MATCH"),
  c("Q15","How do I get at least 5 successes with pbinom for 15 independent trials?","binomial_at_least"),
  c("Q16","How do I get more than 5 successes out of 15 trials?","binomial_more_than"),
  c("Q19","If population sigma is known, is z or t used for a mean CI?","mean_ci_z"),
  c("Q20","I need evidence a population proportion is different from .4. Which test?","NO_MATCH"),
  c("Q21","I'm estimating a percentage, not testing it. Which method should I use?","proportion_interval"),
  c("Q22","Are the hypotheses for an increase in mean one- or two-sided?","NO_MATCH"),
  c("Q23","How do I test whether a population variance equals 16?","NO_MATCH"),
  c("Q24","How do I compute descriptive variance of 10 measurements?","variance"),
  c("Q35","How do I form a discrete PMF for an arbitrary categorical score?","NO_MATCH"),
  c("Q36","I need a Poisson or binomial model, not sure which.","NO_MATCH"),
  c("Q37","How can I replace a bicycle tire on the roadside?","NO_MATCH"),
  c("Q38","Give me a wiring diagram for a kitchen outlet.","NO_MATCH"),
  c("Q39","What does punif tell me about a sample's correlation?","NO_MATCH"),
  c("Q40","How can I make a cummulative Poissson probability?","poisson_cdf"),
  c("Q41","Does a 'proprotion test' create a 95% interval or evaluate a null?","NO_MATCH"),
  c("Q42","How do I run chisq.test to check a population variance?","NO_MATCH")
)
for(item in p0) check_route(item[[1L]],item[[2L]],item[[3L]])
# Independently phrased hold-outs: different numbers, symbols and contexts.
holdouts <- list(
  c("H01","Given a Poisson rate of 2.5, find the probability of two observations.","NO_MATCH"),
  c("H02","A Poissson process counts objects per hour; which dpois expression applies?","poisson_exact"),
  c("H03","Use ppois to evaluate a count of no more than six arrivals.","poisson_cdf"),
  c("H04","Compute Poisson counts given an event rate for each minute.","NO_MATCH"),
  c("H05","What is the probability table for the sum of two irregular dice?","NO_MATCH"),
  c("H06","Build a probability mass function for non-binomial outcomes.","NO_MATCH"),
  c("H07","Convert discrete point probabilities into the cumulative CDF.","discrete_cdf"),
  c("H08","Given a PMF, evaluate P(X>=4) without losing the endpoint.","discrete_cdf"),
  c("H09","Can punif compute the area below an observed score?","uniform_cdf"),
  c("H10","What is P(0.4 < U < 0.8) for a uniform distribution?","uniform_interval"),
  c("H11","A normal variate has mean ten; obtain P(8 < X < 12).","normal_between"),
  c("H12","Using pnorm, obtain the probability between minus one and plus one.","normal_between"),
  c("H13","Find the ninetieth percentile of a normal distribution.","normal_percentile"),
  c("H14","Find the chance of a normal outcome above nine.","normal_right_tail"),
  c("H15","For a binomial count what is the chance of more than nine successes?","binomial_more_than"),
  c("H16","A binomial X has a pbinom upper tail P(X>=9); which method applies?","binomial_at_least"),
  c("H17","Compute exactly three binomial successes with dbinom.","binomial_exact"),
  c("H18","Should we choose Poisson or binomial for a set of counts?","NO_MATCH"),
  c("H19","Does a binomial model apply to a waiting time in minutes?","NO_MATCH"),
  c("H20","Should H1 be one-sided for a lower mean hypothesis?","NO_MATCH"),
  c("H21","Which one-tailed or two-tailed alternative should be selected?","NO_MATCH"),
  c("H22","Conduct a hypothesis test of a population proportion of 0.4.","NO_MATCH"),
  c("H23","Run a chi-square hypothesis test for a population variance.","NO_MATCH"),
  c("H24","Why is chisq.test inappropriate for testing population variance?","NO_MATCH"),
  c("H25","Estimate a population proportion using a confidence interval.","proportion_interval"),
  c("H26","How do I compute the descriptive variance in R?","variance"),
  c("H27","What does a p-value represent after we reject H0?","p_value"),
  c("H28","How should I describe a Bernoulli trial?","bernoulli"),
  c("H29","Use a two-sided hypothesis test for a population proportion.","NO_MATCH"),
  c("H30","Which t test is appropriate for paired before-after measurements?","paired_t"),
  c("H31","How do I install a shower faucet?","NO_MATCH"),
  c("H32","Where can I park a bicycle overnight?","NO_MATCH"),
  c("H33","Is pbinom used for binomial P(X<=3)?","NO_MATCH"),
  c("H34","What does dpois do for an observed count?","poisson_exact"),
  c("H35","Which is appropriate for a mean CI: z versus t?","ci_method_selection"),
  c("H36","What about a variance test when the hypothesis is sigma squared equal to 4?","NO_MATCH"),
  c("H37","Does binom.test evaluate a null proportion of 0.7?","NO_MATCH"),
  c("H38","Can I perform an exact binomial hypothesis test?","NO_MATCH"),
  c("H39","How does pchisq apply to a population variance hypothesis test?","NO_MATCH"),
  c("H40","Can prop.test provide a confidence interval for a proportion?","proportion_interval")
)
for(item in holdouts) check_route(item[[1L]],item[[2L]],item[[3L]])
# Previously supported routes must still provide their known first result.
controls <- list(
  c("What is skewness?","skewness"),
  c("How do I make a histogram?","histogram"),
  c("How do I calculate exactly 3 successes in 10 binomial trials?","binomial_exact"),
  c("How do I obtain at least 2 binomial successes?","binomial_at_least"),
  c("What is a Bernoulli trial?","bernoulli"),
  c("How do I run a one sample t test?","one_sample_t"),
  c("How to import a csv file","import_csv"),
  c("How do I calculate standard deviation?","variance_sd"),
  c("What does a p-value mean?","hypothesis_tests_pvalues"),
  c("How to compute population proportion with a confidence interval?","proportion_interval")
)
for(item in controls) check_route("control",item[[1L]],item[[2L]])
# Native R arithmetic anchors the model/operation rejection criteria:
# on integer counts, >k excludes the mass at k; continuous intervals
# require two CDF evaluations, not one tail.
n <- 14L
k <- 5L
prob <- 0.35
at_least <- 1-stats::pbinom(k-1L,size=n,prob=prob)
strictly_more <- 1-stats::pbinom(k,size=n,prob=prob)
stopifnot(at_least > strictly_more,
          isTRUE(all.equal(at_least-strictly_more,
                           stats::dbinom(k,size=n,prob=prob))),
          isTRUE(all.equal(stats::ppois(2L,lambda=3),
                           exp(-3)*(1+3+9/2))),
          isTRUE(all.equal(stats::punif(0.8)-stats::punif(0.3),
                           0.5)),
          (stats::pnorm(2,mean=1,sd=0.5)-
           stats::pnorm(0,mean=1,sd=0.5)) > 0,
          !isTRUE(all.equal(stats::pnorm(2,mean=1,sd=0.5)-
                            stats::pnorm(0,mean=1,sd=0.5),
                            stats::pnorm(2,mean=1,sd=0.5))))
cat("P0-A: ",length(p0)," designed, ",length(holdouts),
    " held-out, ",length(controls)," positive controls PASS\n",sep="")
