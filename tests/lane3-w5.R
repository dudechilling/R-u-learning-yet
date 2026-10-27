# W5 A3: installed-package real 46-method compatibility and numerical oracle suite.
# All data and expected values are independently constructed; no course material.
# No question text is executed, no network and no access to ambient user data.
library(rulearn)
stopifnot(as.character(utils::packageVersion("rulearn"))=="0.4.2.9001")
ids<-c(
 "import_csv","inspect_columns","filter_rows","group_means",
 "missing_values","mean_median","sample_sd","five_number",
 "percentile_cutoff","relative_frequency","categorical_mode","z_score",
 "histogram","bar_chart","boxplot","grouped_boxplot",
 "scatterplot","zero_correlation","normal_shaded_area",
 "line_chart","moving_average","autocorrelation","stationarity",
 "event_probability","conditional_probability","probability_union",
 "binomial_exact","binomial_at_least","normal_left_tail","normal_right_tail",
 "normal_percentile","discrete_expectation","sample_random",
 "sampling_distribution","standard_error","mean_confidence_interval",
 "one_sample_t","two_sample_t","paired_t","correlation_test",
 "spearman_correlation","linear_regression","predict_regression",
 "interpolation","categorical_independence","proportion_interval")
stopifnot(length(ids)==46L,!anyDuplicated(ids))
contract<-getFromNamespace(".ru_allowed_arguments","rulearn")
pick<-getFromNamespace(".ru_pick","rulearn")
stopifnot(all(vapply(ids,function(id)length(contract(id))>0L,logical(1L))))
# Exact installed dispatcher accepts each ID without heuristic substitution.
for(id in ids) {
  item<-suppressMessages(capture.output(z<-pick(id)))
  stopifnot(identical(z$id[[1L]],id))
}
raw<-data.frame(v=c(2,4,6,8,10),other=c(1,2,5,6,9),
                cat=c("A","B","A","B","A"),stringsAsFactors=FALSE)
categorical<-data.frame(cat=c("A","B","B","A","B"),
                         w=c(2,3,1,4,2),stringsAsFactors=FALSE)
grouped<-data.frame(v=c(2,3,4,7,9,11),
                    g=rep(c("north","south"),each=3),stringsAsFactors=FALSE)
paired<-data.frame(before=c(2,3,5,6,8),after=c(3,5,6,8,11))
relationship<-data.frame(x=c(1,2,3,4,5,6),
                         y=c(2,4,4,8,9,10))
curve<-data.frame(x=-3:3,y=(-3:3)^2)
events<-data.frame(A=c("yes","no","yes","no","yes","yes"),
                   B=c("east","east","west","west","east","west"),
                   stringsAsFactors=FALSE)
counted<-data.frame(A=c("yes","no","yes","no"),
                    B=c("east","east","west","west"),
                    w=c(12,14,15,18),stringsAsFactors=FALSE)
trend<-data.frame(t=seq_len(12L),v=c(5,7,4,8,6,9,7,11,9,13,11,15))
discrete<-data.frame(outcome=c(1,2,5),probability=c(.2,.3,.5))
stationary_example<-data.frame(t=seq_len(12L),
                               v=c(2,3,1,4,3,2,3,1,4,2,3,1))
tmp_csv<-file.path(tempdir(),"ru-w5-a3-synthetic.csv")
utils::write.csv(raw,tmp_csv,row.names=FALSE)
stopifnot(file.exists(tmp_csv))
o<-function(x,y,tol=1e-10) isTRUE(all.equal(unname(x),unname(y),tolerance=tol,check.attributes=FALSE))
# Explicit assertion to avoid relying on implementation's own checks.
check<-function(ok,detail="oracle disagreement")if(!isTRUE(ok))stop(detail,call.=FALSE)
# Validation uses the actual ru_apply call with deliberate named inputs only.
cases<-list()
put<-function(id,pos,neg,oracle,roles,model,assumptions,qualification="LIMITED",
             caveat="Inputs and modeling assumptions require user verification.") {
  stopifnot(id%in%ids,is.null(cases[[id]]),is.list(pos),is.list(neg),
            is.function(oracle),is.character(roles),length(roles)==1L,
            is.character(model),length(model)==1L)
  check(all(names(pos)%in%contract(id)),"positive argument outside method contract")
  check(all(names(neg)%in%c("problem",contract(id))),"negative argument outside method contract")
  cases[[id]] <<- list(pos=pos,negative=neg,oracle=oracle,
    required_roles=roles,model=model,assumptions=assumptions,
    qualification=qualification,caveat=caveat)
}
# No installed package internals are used as mathematical oracles.
# For graphical outputs, compare actual data/tables or base graphics primitives.

# Data import/inspection and univariate summaries: explicit data/column roles.
put("import_csv",list(file=tmp_csv),list(file=file.path(tempdir(),"nonexistent.csv")),
 function(z)check(is.data.frame(z)&&o(z$v,raw$v)&&identical(names(z),names(raw))),
 "file: existing CSV path (character scalar)","Tabular import; explicit user-selected local source.",
 "CSV contents and column types require independent provenance review.","LIMITED",
 "Only an explicitly named local CSV is read; a caller must inspect data semantics.")
put("inspect_columns",list(data=raw),list(),
 function(z)check(is.data.frame(z)&&nrow(z)==ncol(raw)),
 "data: data.frame","Observed variable types, counts and missingness.",
 "Variable classification is observational, not a statistical test.","QUALIFIED","Metadata only.")
put("filter_rows",list(data=raw,x="v",threshold=6,operator=">="),
 list(data=raw,x="v",threshold=6,operator="between"),
 function(z)check(identical(z,raw[which(raw$v>=6),,drop=FALSE])),
 "data: data.frame; x: numeric column name; threshold: scalar; operator: comparison",
 "Deterministic row filter on measured/recorded values.",
 "NA comparisons cannot be interpreted as TRUE; retain original table separately.","LIMITED",
 "Unknown comparison rows are removed; explicit filtering is the intended operation.")
put("group_means",list(data=grouped,x="v",group="g"),
 list(data=grouped,x="v"),
 function(z){check(nrow(z)==2L&&o(z$mean,c(3,9))&&o(z$n,c(3,3)))},
 "data: data.frame; x: numeric column; group: categorical column",
 "Observed group-specific arithmetic means, not a between-groups test.",
 "Missing group measurements are excluded and logged; group differences do not establish causes.","LIMITED",
 "Automatic complete-group-case exclusion requires deliberate caller review.")
put("missing_values",list(data=data.frame(v=c(2,NA_real_,Inf,4)),x="v"),
 list(data=raw,x="cat"),
 function(z)check(o(z[c("total","missing","available","mean_available")],
                      c(total=4,missing=2,available=2,mean_available=3))),
 "data: data.frame; x: numeric column",
 "Descriptive completeness inventory of finite/nonfinite measurements.",
 "No imputation or MCAR/MAR/MNAR mechanism is inferred.","QUALIFIED",
 "The available-only mean is explicitly labeled.")
put("mean_median",list(data=raw,x="v"),list(data=raw,x="cat"),
 function(z)check(o(z[c("n","mean","median")],c(n=5,mean=6,median=6))),
 "data: data.frame; x: finite numeric column",
 "Descriptive sample arithmetic mean and sample median.",
 "Not an estimator of a population without sampling-design assumptions.","LIMITED",
 "Nonfinite values are excluded after a message without separate consent.")
put("sample_sd",list(data=raw,x="v"),list(data=raw,x="cat"),
 function(z)check(o(z[c("n","sample_variance","sample_sd","range")],
                      c(n=5,sample_variance=10,sample_sd=sqrt(10),range=8))),
 "data: data.frame; x: finite numeric column (n>=2)",
 "Sample variance with denominator n-1 and sample standard deviation.",
 "Sample variance is not a population-variance calculation.","LIMITED",
 "Nonfinite observations are omitted; denominator n-1.")
put("five_number",list(data=raw,x="v"),list(data=raw,x="cat"),
 function(z)check(o(z$quantile,stats::quantile(raw$v,c(0,.25,.5,.75,1))) &&
                       o(z$fivenum,stats::fivenum(raw$v))&&o(z$IQR,4)),
 "data: data.frame; x: finite numeric column",
 "Observed quartiles, Tukey hinges and interquartile range.",
 "Tukey hinges and quantile type-7 quartiles are not necessarily identical.","LIMITED",
 "Nonfinite observations are excluded and output mixes two distinct quantile conventions.")
put("percentile_cutoff",list(data=raw,x="v",prob=.75),
 list(data=raw,x="v",prob=1.1),
 function(z)check(o(as.numeric(z),stats::quantile(raw$v,.75))),
 "data: data.frame; x: numeric column; prob: scalar in [0,1]",
 "Empirical sample quantile (base R type-7 default).",
 "Percentiles describe observed values and are not population confidence limits.","LIMITED",
 "Finite-only quantile with automatic exclusion of missing values.")
put("relative_frequency",list(data=categorical,x="cat",weight="w"),
 list(data=categorical,x="cat",weight=c(1,-1,2,3,4)),
 function(z)check(is.data.frame(z)&&identical(z$category,c("A","B"))&&
                   o(z$n,c(6,6))&&o(z$proportion,c(.5,.5))&&
                   o(z$percent,c(50,50))),
 "data: data.frame; x: categorical column; weight: optional count column",
 "Observed frequency counts and relative frequencies.",
 "Weights are integer replication counts; probabilities are descriptive, not a sampling model.","LIMITED",
 "Missing categories are removed by table() without a dedicated consent argument.")
put("categorical_mode",list(data=categorical,x="cat",weight="w"),
 list(data=categorical,x="cat",weight=c(1,2,3,-1,2)),
 function(z)check(identical(z,c("A","B"))),
 "data: data.frame; x: categorical column; weight: optional frequency counts",
 "All tied observed modes of weighted categorical counts.",
 "Tied modes are not resolved by arbitrary first-match selection.","LIMITED",
 "Missing categories in unweighted counts are omitted.")
put("z_score",list(data=raw,x="v",threshold=8),
 list(data=data.frame(v=rep(4,5)),x="v",threshold=4),
 function(z)check(o(z,(8-mean(raw$v))/stats::sd(raw$v))),
 "data: data.frame; x: numeric column; threshold: optional numeric scalar",
 "Descriptive standardization relative to observed sample mean and sample SD.",
 "A sample z-score does not imply a standard normal distribution.","LIMITED",
 "Nonfinite values omitted; sample SD convention.")

# Graph methods return verifiable computed data when show_plot=FALSE.
put("histogram",list(data=raw,x="v",show_plot=FALSE),
 list(data=raw,x="cat",show_plot=FALSE),
 function(z){base<-graphics::hist(raw$v,plot=FALSE);
   check(inherits(z,"histogram")&&o(z$counts,base$counts)&&o(z$breaks,base$breaks))},
 "data: data.frame; x: numeric column; show_plot: logical FALSE for headless",
 "Frequency histogram of observed numeric measurements.",
 "Bin width/boundaries change shape; not a probability density unless normalized.","LIMITED",
 "Nonfinite values excluded with message; bin choice requires contextual judgment.")
put("bar_chart",list(data=categorical,x="cat",weight="w",show_plot=FALSE),
 list(data=categorical,x="cat",weight=rep(-1,5),show_plot=FALSE),
 function(z)check(o(unname(z),c(6,6))&&identical(names(z),c("A","B"))),
 "data: data.frame; x: categorical column; weight: optional integer counts; show_plot: logical",
 "Observed discrete category frequencies.",
 "Chart displays count data and does not establish probability mechanism.","LIMITED",
 "Missing categories omitted; consent/unknown-category treatment not explicit.")
put("boxplot",list(data=raw,x="v",show_plot=FALSE),
 list(data=raw,x="cat",show_plot=FALSE),
 function(z){base<-grDevices::boxplot.stats(raw$v);
   check(is.list(z)&&o(z$stats,base$stats)&&o(z$n,base$n)&&o(z$out,base$out))},
 "data: data.frame; x: numeric column; show_plot: logical",
 "Tukey box-and-whisker summary and flagged outliers.",
 "Flagged outliers are not necessarily measurement errors.","LIMITED",
 "Nonfinite measurements excluded with report.")
put("grouped_boxplot",list(data=grouped,x="v",group="g",show_plot=FALSE),
 list(data=grouped,x="v",group=rep("north",nrow(grouped)),show_plot=FALSE),
 function(z)check(o(as.numeric(z),c(3,9))&&
                   identical(names(z),c("north","south"))),
 "data: data.frame; x: numeric column; group: categorical column; show_plot: logical",
 "Group-level medians; plots only on explicit display.",
 "Headless output contains medians, not full per-group boxplot statistics.","LIMITED",
 "Automatic complete-group-case exclusion; headless output lacks hinges/outlier table.")
put("scatterplot",list(data=relationship,x="x",y="y",show_plot=FALSE),
 list(data=relationship,x="x",y=c(1,2),show_plot=FALSE),
 function(z){x<-relationship$x;y<-relationship$y;
   slope<-sum((x-mean(x))*(y-mean(y)))/sum((x-mean(x))^2);
   check(inherits(z,"lm")&&o(unname(stats::coef(z)),c(mean(y)-slope*mean(x),slope)))},
 "data: data.frame; x and y: aligned numeric columns; show_plot: logical",
 "Paired observations and an illustrative ordinary least-squares fit.",
 "Fitted line alone does not establish linearity, independence, or causation.","LIMITED",
 "Pairs omitted if nonfinite; fitted line needs residual diagnostics.")
put("zero_correlation",list(data=curve,x="x",y="y",show_plot=FALSE),
 list(data=data.frame(x=1:7,y=rep(2,7)),x="x",y="y",show_plot=FALSE),
 function(z)check(is.numeric(z)&&length(z)==1L&&abs(z)<1e-14),
 "data: data.frame; x and y: paired numeric columns",
 "Pearson correlation near zero despite strong quadratic association.",
 "Zero linear correlation does not establish independence.","LIMITED",
 "Pairwise omissions possible; nonlinear dependence is only illustrated.")
put("normal_shaded_area",list(mu=5,sigma=2,threshold=6,assume_normal=TRUE,
                               show_plot=FALSE),
 list(mu=5,sigma=2,threshold=6,assume_normal=FALSE,show_plot=FALSE),
 function(z)check(o(z,stats::pnorm(6,5,2))),
 "mu, sigma>0, threshold: finite numeric scalars; assume_normal=TRUE; show_plot=FALSE",
 "Normal-model left-tail cumulative probability.",
 "Model assumption explicitly declared, not verified from observations.","LIMITED",
 "No empirical normality or stationarity is established.")
# Quantitative time/geography: timestamps must be ordered, unique and regular
# for lags/ACF. A stationarity output is explicitly a diagnostic, not proof.
put("line_chart",list(data=trend,x="v",time="t",show_plot=FALSE),
 list(data=data.frame(v=1:4,t=letters[1:4]),x="v",time="t",show_plot=FALSE),
 function(z)check(is.data.frame(z)&&identical(z$time,trend$t)&&o(z$value,trend$v)),
 "data: data.frame; x: numeric series; time: numeric/Date/POSIXct timestamps",
 "Observed values on a specified time axis.",
 "Time order and gaps are analytically consequential.","LIMITED",
 "Missing timestamps or values removed; source sampling irregularities may remain.")
put("moving_average",list(data=trend,x="v",time="t",window=3L,show_plot=FALSE),
 list(data=trend[-4,,drop=FALSE],x="v",time="t",window=3L,show_plot=FALSE),
 function(z)check(is.data.frame(z)&&o(z$raw,trend$v)&&
                   o(z$smoothed,as.numeric(stats::filter(trend$v,rep(1/3,3),sides=2)))),
 "data: data.frame; x: numeric series; time: regularly spaced timestamps; window: integer >=2",
 "Centered finite moving average by equally spaced observation count.",
 "Not a trend estimator on irregular intervals; endpoint NA values are expected.","LIMITED",
 "Automatic incomplete-row omission may create irregular intervals and is guarded.")
put("autocorrelation",list(data=trend,x="v",time="t",show_plot=FALSE),
 list(data=trend[-4,,drop=FALSE],x="v",time="t",show_plot=FALSE),
 function(z){base<-stats::acf(trend$v,plot=FALSE);
   check(inherits(z,"acf")&&o(as.numeric(z$acf),as.numeric(base$acf)))},
 "data: data.frame; x: finite numeric series; time: regularly spaced timestamps",
 "Empirical sample ACF by equally spaced observation lag.",
 "Autocorrelation is not evidence of stationarity, causality or sampling independence.","LIMITED",
 "Requires equally spaced observations, not proof of weak stationarity.")
put("stationarity",list(data=stationary_example,x="v",time="t",show_plot=FALSE),
 list(data=data.frame(v=1:6,t=1:6),x="v",time="t",show_plot=FALSE),
 function(z){v<-stationary_example$v;check(is.data.frame(z)&&
   o(z$mean,c(mean(v[1:6]),mean(v[7:12])))&&
   o(z$sample_sd,c(stats::sd(v[1:6]),stats::sd(v[7:12]))))},
 "data: data.frame; x: numeric series; time: numeric/Date/POSIXct timestamps",
 "Early-versus-late descriptive means and sample deviations.",
 "Similar halves cannot establish a stationary stochastic process.","LIMITED",
 "Exploratory stability comparison only, not a stationarity test.")

# Probability and sampling: report model conditions, not empirical proof.
put("event_probability",list(data=events,x="A",event="yes"),
 list(data=events,x="A",event=c("yes","no")),
 function(z)check(o(z[c("events","trials","proportion")],
                     c(events=4,trials=6,proportion=4/6))),
 "data: data.frame; x: event-indicator column; event: one nonmissing category",
 "Empirical relative frequency of an explicitly defined event.",
 "Observed frequency is not an independently calibrated future probability.","LIMITED",
 "Missing event rows are dropped after a message.")
put("conditional_probability",list(data=events,x="A",y="B",event="yes",given="east"),
 list(data=events,x="A",y="B",event="yes"),
 function(z)check(o(z[c("both","given","probability")],
                     c(both=2,given=3,probability=2/3))),
 "data: data.frame; x/y: paired categorical columns; event/given: exact levels",
 "Observed conditional proportion P(A|B).",
 "Rows omitted when either event definition is missing; denominators must be positive.","LIMITED",
 "Pairwise exclusion and representativeness remain user concerns.")
put("probability_union",list(data=events,x="A",y="B",event="yes",given="east"),
 list(data=events,x="A",y="B",event="yes"),
 function(z)check(o(z[c("A","B","both","either")],
                     c(A=4/6,B=3/6,both=2/6,either=5/6))),
 "data: data.frame; x/y paired event columns; event/given levels",
 "Observed P(A union B) = P(A)+P(B)-P(A intersection B).",
 "Events must be defined over the same aligned observational units.","LIMITED",
 "Pairwise complete-case rows define effective denominator.")
put("binomial_exact",list(n=10,k=3,prob=.25),
 list(n=10,k=11,prob=.25),
 function(z)check(o(z,choose(10,3)*.25^3*.75^7)),
 "n: positive integer trials; k: integer 0..n; prob: [0,1]",
 "Exactly k successes under independent identical Bernoulli trials.",
 "Fixed success rate, independent trials and identical p are assumptions.","LIMITED",
 "Cannot verify independence or common probability from parameters.")
put("binomial_at_least",list(n=10,k=3,prob=.25),
 list(n=10,k=2.5,prob=.25),
 function(z)check(o(z,sum(choose(10,3:10)*.25^(3:10)*.75^(10-(3:10))))),
 "n: positive integer trials; k: integer threshold 0..n; prob: [0,1]",
 "P(X>=k) for Binomial(n,p), inclusive of k.",
 "Not a Poisson waiting-time or count-process approximation.","LIMITED",
 "Independence and fixed p are declared model assumptions.")
put("normal_left_tail",list(mu=4,sigma=2,threshold=5,assume_normal=TRUE),
 list(mu=4,sigma=2,threshold=5,assume_normal=FALSE),
 function(z)check(o(z,stats::pnorm(.5))),
 "mu: finite mean; sigma: positive SD; threshold: finite; assume_normal=TRUE",
 "Normal theoretical cumulative probability P(X<=threshold).",
 "Normality is stipulated, not inferred from data.","LIMITED",
 "The specified model must be justified independently.")
put("normal_right_tail",list(mu=4,sigma=2,threshold=5,assume_normal=TRUE),
 list(mu=4,sigma=0,threshold=5,assume_normal=TRUE),
 function(z)check(o(z,1-stats::pnorm(.5))),
 "mu: finite mean; sigma: positive SD; threshold: finite; assume_normal=TRUE",
 "Continuous normal survival P(X>threshold).",
 "Continuous point mass is zero and tail direction is explicit.","LIMITED",
 "Model parameters cannot establish observed distribution shape.")
put("normal_percentile",list(mu=4,sigma=2,prob=.9,assume_normal=TRUE),
 list(mu=4,sigma=2,prob=1,assume_normal=TRUE),
 function(z)check(o(z,4+2*stats::qnorm(.9))),
 "mu: finite mean; sigma: positive SD; prob: exclusive (0,1); assume_normal=TRUE",
 "Population model quantile at an explicitly supplied probability.",
 "The quantile is theoretical, not an empirical sample percentile.","LIMITED",
 "Normal model suitability remains untested.")
put("discrete_expectation",list(data=discrete,x="outcome",y="probability"),
 list(data=data.frame(outcome=c(1,2),probability=c(.3,.3)),
      x="outcome",y="probability"),
 function(z){v<-discrete$outcome;p<-discrete$probability;
   m<-sum(v*p);check(o(z,c(expected=m,variance=sum(p*(v-m)^2))))},
 "data: data.frame; x: numeric outcomes; y: finite probabilities summing to 1",
 "Discrete expectation and population distribution variance.",
 "This is not sample variance; probabilities must be exhaustive.","QUALIFIED",
 "Probabilities explicitly validated for finiteness, normalization, nonnegativity.")
put("sample_random",list(data=raw,n=3L,seed=43L),
 list(data=raw,n=8L,seed=43L),
 function(z){expected<-local({set.seed(43L);raw[sample.int(nrow(raw),3L),,drop=FALSE]});
   check(identical(z,expected))},
 "data: data.frame population frame; n: integer 1..rows; seed: nonnegative integer",
 "Reproducible simple random sample without replacement of provided rows.",
 "Randomizing observed rows cannot repair sampling-frame bias.","LIMITED",
 "Population representativeness and sampled-row identifiers require user review.")
put("sampling_distribution",list(data=raw,x="v",n=3L,seed=17L,
                                  reps=50L,show_plot=FALSE),
 list(data=raw,x="v",n=3L,seed=17L,reps=10L,show_plot=FALSE),
 function(z){expected<-local({set.seed(17L);
   replicate(50L,mean(sample(raw$v,3L,replace=TRUE)))});
   check(is.numeric(z)&&length(z)==50L&&o(z,expected))},
 "data: data.frame; x: numeric column; n>=2; reps 50..20000; seed",
 "Bootstrap empirical resampling distribution of sample means.",
 "Dependence and nonrepresentativeness are inherited from original sample.","LIMITED",
 "Bootstrap is a resampling diagnostic, not a proof of sampling validity.")

# Inference: requirements for independence/normality are explicit assumptions.
put("standard_error",list(data=raw,x="v"),
 list(data=data.frame(v=c(1,2)),x="v"),
 function(z)check(o(z[c("n","sample_sd","estimated_se")],
                     c(n=5,sample_sd=stats::sd(raw$v),
                       estimated_se=stats::sd(raw$v)/sqrt(5)))),
 "data: data.frame; x: numeric sample column with n>=3",
 "Estimated sample-mean standard error using sample SD/sqrt(n).",
 "Sampling design and independence remain unverified.","LIMITED",
 "Temporal dependence can invalidate the naive standard error.")
put("mean_confidence_interval",list(data=raw,x="v",confidence=.95),
 list(data=raw,x="v"),
 function(z){base<-stats::t.test(raw$v,conf.level=.95);
   check(inherits(z,"htest")&&o(z$conf.int,base$conf.int)&&o(z$estimate,base$estimate))},
 "data: data.frame; x: sample numeric column; confidence: (0,1)",
 "One-sample Student t interval for mean with unknown population sigma.",
 "Coverage relies on sampling and distributional conditions.","LIMITED",
 "Small sample means require independent design assessment.")
put("one_sample_t",list(data=raw,x="v",reference=5,confidence=.95,
                         alternative="greater"),
 list(data=raw,x="v",reference=5,confidence=.95,alternative="sideways"),
 function(z){base<-stats::t.test(raw$v,mu=5,conf.level=.95,alternative="greater");
   check(inherits(z,"htest")&&o(z$p.value,base$p.value)&&
         o(z$statistic,base$statistic)&&o(z$estimate,base$estimate))},
 "data: data.frame; x: numeric sample; reference: null mean; confidence; alternative",
 "One-sample t-test for explicitly named null mean.",
 "Sampling, shape and independence are unverified.","LIMITED",
 "No automatic population inference without design review.")
put("two_sample_t",list(data=grouped,x="v",group="g",
                          independent=TRUE,confidence=.95,alternative="two.sided"),
 list(data=grouped,x="v",group="g",independent=FALSE,confidence=.95),
 function(z){base<-stats::t.test(grouped$v~grouped$g,conf.level=.95);
   check(inherits(z,"htest")&&o(z$statistic,base$statistic)&&
         o(z$p.value,base$p.value)&&o(z$estimate,base$estimate))},
 "data: data.frame; x: numeric response; group: exactly two levels; independent=TRUE; confidence",
 "Welch two-independent-group t-test, unequal variances by default.",
 "Group assignment, representativeness and independence not observed.","LIMITED",
 "Two-group design is assumed, not verified.")
put("paired_t",list(data=paired,x="before",y="after",
                      paired=TRUE,confidence=.95,alternative="two.sided"),
 list(data=paired,x="before",y="after",paired=FALSE,confidence=.95),
 function(z){base<-stats::t.test(paired$after,paired$before,
                                 paired=TRUE,conf.level=.95);
   check(inherits(z,"htest")&&o(z$statistic,base$statistic)&&
         o(z$p.value,base$p.value)&&o(z$estimate,base$estimate))},
 "data: data.frame; x/y: row-aligned before/after; paired=TRUE; confidence",
 "Matched-pair t-test of y minus x differences.",
 "Row identity must truly link the same subject.","LIMITED",
 "Caller must validate pair correspondence; no ID join is performed.")
put("correlation_test",list(data=relationship,x="x",y="y",
                            confidence=.95,alternative="two.sided"),
 list(data=relationship,x="x",y="y"),
 function(z){base<-stats::cor.test(relationship$x,relationship$y,
                                  method="pearson",conf.level=.95);
   check(inherits(z,"htest")&&o(z$estimate,base$estimate)&&
         o(z$p.value,base$p.value)&&o(z$conf.int,base$conf.int))},
 "data: data.frame; x/y paired numeric columns; confidence (0,1); alternative",
 "Pearson linear association and sampling-model t inference.",
 "Linearity, paired independence and approximate normality not established.","LIMITED",
 "Association is not causation; nonlinear patterns may have r near zero.")

put("spearman_correlation",list(data=relationship,x="x",y="y",
                                alternative="two.sided"),
 list(data=data.frame(x=rep(2,5),y=1:5),x="x",y="y"),
 function(z){base<-suppressWarnings(stats::cor.test(
   relationship$x,relationship$y,method="spearman",exact=FALSE));
   check(inherits(z,"htest")&&o(z$estimate,base$estimate)&&
         o(z$p.value,base$p.value))},
 "data: data.frame; x/y paired numeric or ordinal columns; alternative",
 "Spearman rank association with asymptotic inference.",
 "Ties, monotonicity, pairing and dependence matter.","LIMITED",
 "Asymptotic p-value; correlation is not a causal coefficient.")
put("linear_regression",list(data=relationship,x="x",y="y",show_plot=FALSE),
 list(data=data.frame(x=c(1,1,1,2,2,2),y=1:6),
      x="x",y="y",show_plot=FALSE),
 function(z){x<-relationship$x;y<-relationship$y;
   slope<-sum((x-mean(x))*(y-mean(y)))/sum((x-mean(x))^2);
   exp<-c(mean(y)-slope*mean(x),slope);
   check(inherits(z,"lm")&&o(as.numeric(stats::coef(z)),exp)&&
         o(as.numeric(stats::fitted(z)),exp[1]+exp[2]*x))},
 "data: data.frame; x/y aligned numeric columns; show_plot=FALSE",
 "Simple ordinary least-squares fit with intercept and slope.",
 "Residual independence/linearity and causal identification not established.","LIMITED",
 "Fitted association alone is not causal.")
put("predict_regression",list(data=relationship,x="x",y="y",
                              new_x=3.5,confidence=.95),
 list(data=relationship,x="x",y="y",new_x=7,
      confidence=.95,allow_extrapolate=FALSE),
 function(z){base<-stats::predict(stats::lm(y~x,data=relationship),
   newdata=data.frame(x=3.5),interval="prediction",level=.95);
   check(is.matrix(z)&&identical(dim(z),c(1L,3L))&&o(z,base))},
 "data: data.frame; x/y numeric pairs; new_x: finite inside x-range; confidence (0,1)",
 "Individual outcome prediction interval from simple OLS model.",
 "Interval is conditional on fitted residual assumptions; extrapolation guarded.","LIMITED",
 "Not a causal forecast, and interval can be invalid under misspecification.")
put("interpolation",list(data=relationship,x="x",y="y",
                          threshold=3.5,show_plot=FALSE),
 list(data=relationship,x="x",y="y",threshold=7,show_plot=FALSE),
 function(z)check(is.list(z)&&o(z$x,3.5)&&o(z$y,6)),
 "data: data.frame; x/y paired coordinates and values; threshold in observed range",
 "One-dimensional linear interpolation between adjacent observations.",
 "Not full 2D GIS surface, kriging or nearest-neighbor analysis.","LIMITED",
 "Interpolation uncertainty and spatial dependence not modeled.")
put("categorical_independence",list(data=counted,x="A",y="B",weight="w"),
 list(data=data.frame(A=c("a","a","a"),B=c("x","y","x")),x="A",y="B"),
 function(z){tab<-stats::xtabs(w~A+B,data=counted);
   base<-suppressWarnings(stats::chisq.test(tab,correct=FALSE));
   check(inherits(z,"htest")&&o(z$statistic,base$statistic)&&
         o(z$p.value,base$p.value))},
 "data: data.frame; x/y categorical columns; weight: integer counts optional",
 "Pearson chi-square test of categorical independence when expected cells adequate.",
 "Observations must be independent; sparse categories need exact/simulation methods.","LIMITED",
 "Sparse non-2x2 expected cells return a no-test diagnostic rather than p-value.")
put("proportion_interval",list(successes=30,n=50,confidence=.95),
 list(successes=60,n=50,confidence=.95),
 function(z){base<-stats::prop.test(30,50,conf.level=.95,correct=FALSE);
   check(inherits(z,"htest")&&o(z$estimate,base$estimate)&&
         o(z$conf.int,base$conf.int))},
 "successes: integer 0..n; n: positive integer; confidence (0,1)",
 "Single-proportion score-type approximation confidence interval.",
 "Independent Bernoulli sampling is assumed, not proven.","LIMITED",
 "Small n/extreme rates weaken approximation.")

# Run real installed calls (not mock dispatch). Record every failure and oracle
# separately before the final all-method assertion, allowing blocked evidence.
stopifnot(length(cases)==46L,setequal(names(cases),ids))
with_base_seed<-function(seed,expr){
  existed<-exists(".Random.seed",envir=.GlobalEnv,inherits=FALSE)
  if(existed)prior<-get(".Random.seed",envir=.GlobalEnv,inherits=FALSE)
  on.exit(if(existed)assign(".Random.seed",prior,envir=.GlobalEnv) else
    if(exists(".Random.seed",envir=.GlobalEnv,inherits=FALSE))
      rm(list=".Random.seed",envir=.GlobalEnv))
  set.seed(seed)
  force(expr)
}
# Each negative may have a different model/data/required-input challenge.
invoke<-function(id,args) {
  value<-NULL
  warnings<-character();messages<-character()
  result<-tryCatch(withCallingHandlers(
    capture.output(value<-do.call(ru_apply,c(list(problem=id),args)),
                   type="output"),
    warning=function(w){warnings<<-c(warnings,conditionMessage(w));
                        invokeRestart("muffleWarning")},
    message=function(m){messages<<-c(messages,conditionMessage(m));
                        invokeRestart("muffleMessage")}),
    error=function(e)e)
  if(inherits(result,"error"))
    return(list(ok=FALSE,error=conditionMessage(result),value=NULL,
                messages=messages,warnings=warnings))
  list(ok=TRUE,error="",value=value,messages=messages,warnings=warnings)
}
safe_oracle<-function(fun,z){
  out<-tryCatch({fun(z);TRUE},error=function(e)conditionMessage(e))
  if(identical(out,TRUE))list(pass=TRUE,error="") else
    list(pass=FALSE,error=as.character(out))
}
shape<-function(z) paste(class(z),collapse="/")
quantity<-function(z){
  if(is.numeric(z)&&length(z)<=12L)
    return(paste(signif(as.numeric(z),8),collapse=";"))
  if(is.data.frame(z))return(paste0("rows=",nrow(z),"; cols=",ncol(z)))
  if(is.matrix(z))return(paste(signif(as.numeric(z),8),collapse=";"))
  if(inherits(z,"htest"))return(paste0("p=",signif(z$p.value,8)))
  if(inherits(z,"lm"))return(paste(signif(stats::coef(z),8),collapse=";"))
  if(inherits(z,"acf"))return(paste0("acf1=",signif(as.numeric(z$acf)[2],8)))
  if(inherits(z,"histogram"))return(paste0("count=",sum(z$counts)))
  if(is.list(z))return(paste(names(z),collapse=";"))
  paste(utils::head(as.character(z),5L),collapse=";")
}
short_input<-function(v){
  if(is.data.frame(v))return(paste0("data.frame[",nrow(v),"x",ncol(v),
                                    ";",paste(names(v),collapse="/"),
                                    "; missing=",sum(is.na(v)),"]"))
  if(is.atomic(v)&&length(v)<=6L)
    return(paste0(class(v)[1L],"(",paste(as.character(v),collapse="/"),")"))
  paste0(class(v)[1L],"[",length(v),";",
         paste(utils::head(as.character(v),3L),collapse="/"),"/...]")
}
described_args<-function(args){
  if(!length(args))return("<none>")
  paste(vapply(names(args),function(nm)
    paste0(nm,"=",short_input(args[[nm]])),character(1L)),collapse="; ")
}
source_path<-function(id){
  if(id%in%ids[1:12])return("R/apply-basic.R")
  if(id%in%ids[13:19])return("R/apply-graphs.R")
  if(id%in%ids[20:23])return("R/apply-time.R")
  if(id%in%ids[24:34])return("R/apply-probability.R")
  "R/apply-inference.R"
}
rows<-vector("list",length(ids))
set.seed(20261027)
for(i in seq_along(ids)){
  id<-ids[[i]]
  cse<-cases[[id]]
  previous<-get(".Random.seed",envir=.GlobalEnv,inherits=FALSE)
  old_graphics<-grDevices::dev.cur()
  before<-serialize(cse$pos,NULL)
  pos<-invoke(id,cse$pos)
  unmodified<-identical(serialize(cse$pos,NULL),before)
  no_side_effect<-identical(get(".Random.seed",envir=.GlobalEnv,
                                inherits=FALSE),previous) &&
                  identical(grDevices::dev.cur(),old_graphics)
  independent<-if(pos$ok)safe_oracle(cse$oracle,pos$value) else
    list(pass=FALSE,error=pos$error)
  neg<-invoke(id,cse$negative)
  pass<-pos$ok&&independent$pass&&!neg$ok&&
        nchar(neg$error)>0L&&unmodified&&no_side_effect
  qual<-if(!pass)"BLOCKED" else cse$qualification
  rows[[i]]<-data.frame(method_id=id,source_path=source_path(id),
    allowed_arguments=paste(contract(id),collapse=","),
    required_inputs=cse$required_roles,model=cse$model,
    assumptions=cse$assumptions,positive_input=described_args(cse$pos),
    negative_input=described_args(cse$negative),
    actual_return_class=if(pos$ok)shape(pos$value) else "",
    actual_quantities=if(pos$ok)quantity(pos$value) else "",
    positive=if(pos$ok)"PASS" else "FAIL",
    oracle=if(independent$pass)"PASS" else "FAIL",
    negative=if(!neg$ok)"PASS" else "FAIL",
    no_side_effect=if(no_side_effect&&unmodified)"PASS" else "FAIL",
    verdict=if(pass)"PASS" else "FAIL",qualification=qual,
    caveat=cse$caveat,
    error=if(pass)"" else paste(pos$error,independent$error,
                               if(neg$ok)"NEGATIVE ACCEPTED" else "",
                               if(!no_side_effect)"SIDE_EFFECT" else "",
                               if(!unmodified)"INPUT_MUTATED" else "",
                               sep=" | "),
    negative_reason=if(!neg$ok)neg$error else "NEGATIVE INCORRECTLY ACCEPTED",
    stringsAsFactors=FALSE)
  cat(sprintf("A3 W5 %02d/46 %-27s %s (%s)\n",i,id,
              rows[[i]]$verdict,qual))
}
matrix<-do.call(rbind,rows)
out_dir<-Sys.getenv("RU_A3_W5_EVIDENCE_DIR",unset="")
if(nzchar(out_dir)){
  dir.create(out_dir,recursive=TRUE,showWarnings=FALSE)
  utils::write.csv(matrix,file.path(out_dir,"46-method-qualification-matrix.csv"),
                   row.names=FALSE,na="")
}
cat("W5 A3 46-method oracle matrix:\n")
print(table(matrix$verdict,matrix$qualification))
if(any(matrix$verdict!="PASS")){
  print(matrix[matrix$verdict!="PASS",
               c("method_id","positive","oracle","negative",
                 "no_side_effect","error")],row.names=FALSE)
  stop("A3 W5 method contract qualification FAIL",call.=FALSE)
}
cat("A3 W5 46/46 exact installed positives, 46/46 negatives, 46/46 independent oracles, 46/46 no mutation/plot/RNG side effects PASS\n")

# Adversarial cross-method challenges: preserve denominator, pairing, and
# model identity rather than quietly converting one statistical task to another.
guard_error<-function(name,args,fragment){
  r<-invoke(name,args)
  if(r$ok || !grepl(fragment,r$error,fixed=TRUE))
    stop("Required negative guard not met: ",name," :: ",
         r$error,call.=FALSE)
  invisible(TRUE)
}
guard_error("relative_frequency",
            list(data=data.frame(cat=c("A",NA,"B")),x="cat"),
            "Explicitly recode or subset")
guard_error("categorical_mode",
            list(data=data.frame(cat=c("A",NA,"B")),x="cat"),
            "Explicitly recode or subset")
guard_error("bar_chart",list(data=data.frame(cat=c("A",NA,"B")),
                               x="cat",show_plot=FALSE),
            "Explicitly recode or subset")
guard_error("relative_frequency",
            list(data=data.frame(cat=c(1,Inf,2)),x="cat"),
            "missing/nonfinite")
guard_error("filter_rows",list(data=raw,x="v",threshold=NA_real_),
            "nonmissing threshold")
guard_error("filter_rows",
            list(data=data.frame(v=c(1,Inf,3)),x="v",threshold=2),
            "missing/nonfinite")
guard_error("scatterplot",
            list(data=data.frame(x=rep(1,5),y=1:5),
                 x="x",y="y",show_plot=FALSE),
            "requires variation")
guard_error("binomial_exact",list(n=2147483648,k=2,prob=.25),
            "supported R integer range")
guard_error("sample_random",list(data=raw,n=2,seed=2147483648),
            "supported R integer range")
guard_error("sampling_distribution",
            list(data=raw,x="v",n=100001,reps=50,show_plot=FALSE),
            "Bootstrap work cap")
guard_error("sampling_distribution",
            list(data=raw,x="v",n=10000,reps=500,show_plot=FALSE),
            "Bootstrap work cap")
guard_error("interpolation",
            list(data=data.frame(x=c(1,2,2,4),y=c(1,2,3,4)),
                 x="x",y="y",threshold=2,show_plot=FALSE),
            "Repeated x positions")
guard_error("paired_t",list(data=paired,x="before",y="after",
                            paired=FALSE,confidence=.95),
            "paired=TRUE")
guard_error("two_sample_t",list(data=grouped,x="v",group="g",
                                independent=FALSE,confidence=.95),
            "independent=TRUE")
guard_error("autocorrelation",
            list(data=trend[-4,,drop=FALSE],x="v",time="t",
                 show_plot=FALSE),"Regularly spaced")
guard_error("moving_average",
            list(data=trend[-4,,drop=FALSE],x="v",time="t",
                 window=3,show_plot=FALSE),"Regularly spaced")
guard_error("predict_regression",
            list(data=relationship,x="x",y="y",new_x=7,confidence=.95),
            "outside the observed")
guard_error("discrete_expectation",
            list(data=data.frame(x=c(1,2),p=c(.2,.2)),x="x",y="p"),
            "sum to 1")
guard_error("mean_confidence_interval",
            list(data=raw,x="v"),"confidence=")
guard_error("normal_left_tail",
            list(mu=0,sigma=1,threshold=2),"assume_normal=TRUE")
# Finite-case exclusions are explicitly reported; these methods remain
# LIMITED because ru_apply has no separate explicit exclusion-consent flag.
partial<-data.frame(v=c(2,4,NA_real_,8,Inf))
m<-invoke("mean_median",list(data=partial,x="v"))
stopifnot(m$ok,o(m$value[c("n","mean","median")],
                  c(n=3,mean=14/3,median=4)),
          any(grepl("Excluded 2 non-finite",m$messages,fixed=TRUE)),
          identical(partial$v,c(2,4,NA_real_,8,Inf)))
# The same time series with an omitted interior row is no longer regular.
partial_time<-trend
partial_time$v[[4L]]<-NA_real_
guard_error("autocorrelation",
            list(data=partial_time,x="v",time="t",show_plot=FALSE),
            "Regularly spaced")
# No algorithm proves causation, independent grouping or stationarity.
stopifnot(cases[["stationarity"]]$qualification=="LIMITED",
          cases[["correlation_test"]]$qualification=="LIMITED",
          cases[["linear_regression"]]$qualification=="LIMITED",
          cases[["paired_t"]]$qualification=="LIMITED")
cat("A3 W5 22 additional adversarial method/model/data/cap challenges PASS\n")

# Additional analytical crosschecks deliberately do NOT call the same
# statistical producer for the expected value; use mathematical identities.
value_for<-function(id) {
  z<-invoke(id,cases[[id]]$pos)
  stopifnot(z$ok)
  z$value
}
columns<-value_for("inspect_columns")
stopifnot(identical(columns$column,c("v","other","cat")),
          identical(columns$type,c("numeric","numeric","character")),
          identical(as.integer(columns$missing),c(0L,0L,0L)),
          identical(as.integer(columns$non_missing),c(5L,5L,5L)))
h<-value_for("histogram")
stopifnot(sum(h$counts)==length(raw$v),
          o(sum(h$density*diff(h$breaks)),1))
acf_obj<-value_for("autocorrelation")
tsv<-trend$v
acf1<-sum((tsv[-length(tsv)]-mean(tsv))*
          (tsv[-1L]-mean(tsv)))/sum((tsv-mean(tsv))^2)
stopifnot(o(as.numeric(acf_obj$acf)[[2L]],acf1))
ci<-value_for("mean_confidence_interval")
m<-mean(raw$v);se<-sqrt(sum((raw$v-m)^2)/(length(raw$v)-1))/
  sqrt(length(raw$v))
critical<-stats::qt(.975,df=length(raw$v)-1)
stopifnot(o(ci$conf.int[1:2],c(m-critical*se,m+critical*se)))
t1<-value_for("one_sample_t")
stat<-(m-5)/se
stopifnot(o(unname(t1$statistic),stat),
          o(t1$p.value,stats::pt(stat,df=4,lower.tail=FALSE)))
t2<-value_for("two_sample_t")
u<-grouped$v[grouped$g=="north"];v<-grouped$v[grouped$g=="south"]
su<-stats::var(u)/length(u);sv<-stats::var(v)/length(v)
tw<-(mean(u)-mean(v))/sqrt(su+sv)
dfw<-(su+sv)^2/(su^2/(length(u)-1)+sv^2/(length(v)-1))
stopifnot(o(unname(t2$statistic),tw),
          o(t2$p.value,2*stats::pt(-abs(tw),df=dfw)))
tp<-value_for("paired_t")
diffs<-paired$after-paired$before
tpaired<-mean(diffs)/(sqrt(sum((diffs-mean(diffs))^2)/
                 (length(diffs)-1))/sqrt(length(diffs)))
stopifnot(o(unname(tp$statistic),tpaired),
          o(tp$p.value,2*stats::pt(-abs(tpaired),df=length(diffs)-1)))
pearson<-value_for("correlation_test")
xx<-relationship$x;yy<-relationship$y
rho<-sum((xx-mean(xx))*(yy-mean(yy)))/
  sqrt(sum((xx-mean(xx))^2)*sum((yy-mean(yy))^2))
tc<-rho*sqrt((length(xx)-2)/(1-rho^2))
stopifnot(o(unname(pearson$estimate),rho),
          o(pearson$p.value,2*stats::pt(-abs(tc),df=length(xx)-2)))
spearman<-value_for("spearman_correlation")
rank_rho<-stats::cor(rank(xx),rank(yy))
stopifnot(o(unname(spearman$estimate),rank_rho))
prediction<-value_for("predict_regression")
fit<-stats::lm(y~x,data=relationship)
nx<-3.5
fitval<-as.double(stats::coef(fit)[1L]+stats::coef(fit)[2L]*nx)
mse<-sum(stats::residuals(fit)^2)/(nrow(relationship)-2)
width<-stats::qt(.975,df=nrow(relationship)-2)*
 sqrt(mse*(1+1/nrow(relationship)+
       (nx-mean(xx))^2/sum((xx-mean(xx))^2)))
stopifnot(o(as.double(prediction[1L,]),c(fitval,
                                          fitval-width,fitval+width)))
independent_tab<-stats::xtabs(w~A+B,data=counted)
obs<-unclass(independent_tab)
expected_tab<-outer(rowSums(obs),colSums(obs))/sum(obs)
chi2<-sum((obs-expected_tab)^2/expected_tab)
independent_test<-value_for("categorical_independence")
stopifnot(o(unname(independent_test$statistic),chi2),
          o(independent_test$p.value,
            stats::pchisq(chi2,df=1,lower.tail=FALSE)))
propci<-value_for("proportion_interval")
phat<-30/50;zz<-stats::qnorm(.975);nn<-50
center<-(phat+zz^2/(2*nn))/(1+zz^2/nn)
half<-zz*sqrt(phat*(1-phat)/nn+zz^2/(4*nn^2))/(1+zz^2/nn)
stopifnot(o(propci$conf.int[1:2],c(center-half,center+half)))
cat("A3 W5 12 independent analytical checks (columns, hist density, ACF, t, Welch, paired, correlations, prediction, contingency, Wilson) PASS\n")
