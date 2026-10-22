# P2-A1 held-out transfer: independently written synthetic questions.
# Five fields freeze question, expected ID, source, failure consequence and risk.
library(rulearn)
cases <- read.table(text="
id|question|expected|basis|risk
A01|Does the CLT turn each raw observation normal as soon as n reaches thirty?|central_limit_theorem|PSU central limit theorem concerns means|HIGH
A02|Why do sample averages from iid measurements approach a normal shape?|central_limit_theorem|PSU CLT normal limit for means|HIGH
A03|For n=4 from a normal parent population what does the central limit theorem imply for the average?|central_limit_theorem|Exact normal means for normal parents|HIGH
A04|Why might sample means from skewed populations converge toward a Gaussian law?|central_limit_theorem|CLT asymptotic normality|HIGH
A05|How does the SD of individual observations differ from standard error of a sample mean?|standard_error|Individual SD versus sampling SE|HIGH
A06|What does standard error measure for an estimated average?|standard_error|SE is variability of statistic|HIGH
A07|Describe the sampling distribution formed by drawing fresh samples repeatedly.|sampling_distribution|Sampling statistic distribution without normality cue|HIGH
A08|For unknown population standard deviation which 90% confidence interval estimates one average?|mean_confidence_interval|R t.test and qt estimated SD|CRITICAL
A09|Only sample s is available: construct a 99% CI for the mean of one numeric population.|mean_confidence_interval|R t.test estimated sigma|CRITICAL
A10|Population sigma is not known; which 95% confidence interval estimates mu?|mean_confidence_interval|Unknown sigma requires t reference|CRITICAL
A11|With estimated SD in one quantitative sample find the two-sided t confidence interval for its mean.|mean_confidence_interval|One sample t CI|CRITICAL
A12|The known population SD was certified before sampling. Find a 90% mean confidence interval.|mean_ci_z|Independent known sigma and normal critical|CRITICAL
A13|Given known population variance 6.25 calculate a 95% confidence interval for average thickness.|mean_ci_z|sigma equals square root known variance|CRITICAL
A14|Population standard deviation is provided as 2.3. Find a 99% confidence interval for the mean.|mean_ci_z|Known population sigma R qnorm|CRITICAL
A15|Population sigma is known as 1.4. Which z confidence interval estimates the average?|mean_ci_z|Population known sigma z method|CRITICAL
A16|If population variance is known which confidence interval estimates a single population mean?|mean_ci_z|Known variance gives known sigma|CRITICAL
A17|Should an analyst choose z or t for a confidence interval?|ci_method_selection|Design and sigma status needed|HIGH
A18|Which CI method is chosen for estimating a numeric mean?|ci_method_selection|Method selection no invented computation|HIGH
A19|How should I choose the proper confidence interval procedure?|ci_method_selection|Selection before numerical result|HIGH
A20|For a sample mean CI z versus t?|ci_method_selection|Known versus estimated SD not n|HIGH
A21|What does coverage mean for a 99% confidence interval?|confidence_intervals|Frequentist coverage concept|HIGH
A22|Can individual spread be confused with coverage of a confidence interval?|confidence_intervals|CI does not give observed value range|HIGH
A23|For a binary proportion what confidence interval estimates its population frequency?|proportion_interval|Existing AUTHORED proportion interval|HIGH
A24|I recorded yes/no responses and want a 90% confidence interval for the population proportion.|proportion_interval|Proportion not numeric mean|HIGH
A25|One population mean CI is requested but population sigma status is not stated.|NO_MATCH|Known versus estimated sigma unresolved|CRITICAL
A26|Find confidence limits from twenty observations without identifying any parameter.|NO_MATCH|Missing parameter|CRITICAL
A27|Both known and unknown population sigma are asserted; find a mean CI.|NO_MATCH|Contradictory SD facts|CRITICAL
A28|Use a one-sample mean confidence interval on matched pre and post readings.|NO_MATCH|Paired design requires separate method|CRITICAL
A29|Calculate a mean confidence interval comparing two independent cohorts.|NO_MATCH|Two groups not one population|CRITICAL
A30|Make a mean CI using clustered pupils without describing the sampling dependence.|NO_MATCH|Cluster dependence not iid SE|CRITICAL
A31|Test whether a null population proportion equals 0.37 instead of estimating it.|NO_MATCH|Proportion test pending P2-A2|CRITICAL
A32|Test population variance equal to 25 using a chi-square hypothesis.|NO_MATCH|One-population variance test pending|CRITICAL
A33|For a suspected increase is an alternative one-tailed or two-tailed?|NO_MATCH|Hypothesis sidedness method pending|CRITICAL
A34|Calculate a p value for a hypothesis test of population mean with known sigma.|NO_MATCH|Mean hypothesis test not z CI|CRITICAL
A35|Sample size 30 but population SD unreported: construct a mean confidence interval.|NO_MATCH|n cannot decide sigma status|CRITICAL
A36|Sample s is available for a one-observation mean confidence interval.|mean_confidence_interval|t guide must warn n needs at least two|HIGH
A37|Population sigma is known but only one normal observation: mean confidence interval?|mean_ci_z|Known sigma normal mean supports n=1|HIGH
A38|Estimate a mean given known population variance without specifying interval or test.|NO_MATCH|Missing task kind cannot assume CI|HIGH
A39|Population variance is known yet population sigma is unknown: give a mean CI.|NO_MATCH|Known variance versus unknown sigma contradiction|CRITICAL
A40|For a binomial count of 12 independent trials evaluate P(X>6).|binomial_more_than|P1-B strictly above endpoint|HIGH
A41|For a continuous uniform model over [0,15] evaluate P(3<X<7).|uniform_interval|P1-B two bound probability|HIGH
A42|In a normal model what fraction falls between 16 and 25?|normal_between|P1-B normal two bound probability|HIGH
A43|For Poisson arrivals what chance is at most two?|poisson_cdf|P1-A inclusive lower tail|HIGH
A44|How can I stop mould on the basement window?|NO_MATCH|Out of statistical domain|HIGH
",sep="|",header=TRUE,stringsAsFactors=FALSE,comment.char="",
quote="",check.names=FALSE)
stopifnot(nrow(cases)==44L,!anyDuplicated(cases$id),
          all(nzchar(cases$basis)),all(cases$risk %in% c("HIGH","CRITICAL")))
got <- lapply(seq_len(nrow(cases)), function(i) {
 hits <- NULL
 printed <- capture.output(hits <- ru_find(cases$question[i],n=3L))
 first <- if(nrow(hits))hits$id[1L] else "NO_MATCH"
 data.frame(id=cases$id[i],observed=first,
            top3=paste(hits$id,collapse=";"),
            ok=identical(first,cases$expected[i]) && !length(printed) &&
               (cases$expected[i]!="NO_MATCH" || !nrow(hits)))
})
observed <- do.call(rbind,got)
report <- cbind(cases,observed[,c("observed","top3","ok")])
qa <- Sys.getenv("RULEARN_QA_DIR",unset="")
if(nzchar(qa)) {
 dir.create(qa,recursive=TRUE,showWarnings=FALSE)
 write.csv(report,file.path(qa,"p2a1-heldout-routes.csv"),row.names=FALSE)
}
bad <- report[!report$ok,,drop=FALSE]
if(nrow(bad))stop(paste(capture.output(print(bad[,c("id","question","expected","observed","top3")],
                            row.names=FALSE,right=FALSE)),collapse="\n"),call.=FALSE)
cat("P2-A1 independently worded transfer:",nrow(report),"/",nrow(report),
    "safe first-ranked routes and silent output PASS\n")