# Independent arithmetic/optimization oracles for the ten product workflows.
# Synthetic cases and oracle implementations are original. No network use.
library(rulearn)
read_card <- getFromNamespace(".ru_lesson_read","rulearn")
checks <- 0L
ok <- function(label,condition) {
  if(!isTRUE(condition)) stop("Numerical acceptance failed: ",label,call.=FALSE)
  checks <<- checks+1L
}
near <- function(a,b,tol=1e-8) {
  a <- as.numeric(a); b <- as.numeric(b)
  length(a)==length(b) && all(is.finite(a)) && all(is.finite(b)) &&
    max(abs(a-b)) <= tol*(1+max(abs(b)))
}
run_card <- function(id,overrides=list()) {
  card <- read_card(id)
  stopifnot(!is.null(card),nzchar(card$code))
  env <- new.env(parent=.GlobalEnv)
  expr <- parse(text=card$code)
  invisible(utils::capture.output(for(e in expr) {
    target <- if(is.call(e) && identical(e[[1L]],as.name("<-")) && is.symbol(e[[2L]]))
      as.character(e[[2L]]) else ""
    if(target %in% names(overrides)) assign(target,overrides[[target]],envir=env)
    else eval(e,envir=env)
  }))
  env
}
reject <- function(id,override) {
  result <- tryCatch({run_card(id,override);FALSE},error=function(e) TRUE)
  ok(paste(id,"invalid input",paste(names(override),collapse=",")),result)
}
# Manual t density, integrated independently of pt/qt.
t_density <- function(x,df) exp(lgamma((df+1)/2)-lgamma(df/2)-.5*log(df*pi)-
                                ((df+1)/2)*log1p(x*x/df))
t_tail <- function(t,df) 2*stats::integrate(function(z)t_density(z,df),
                                  abs(t),Inf,rel.tol=1e-10)$value
t_critical <- function(df,confidence=.95) stats::uniroot(function(q)
  .5+stats::integrate(function(z)t_density(z,df),0,q,rel.tol=1e-10)$value-
  (1+confidence)/2,c(0,100),tol=1e-10)$root
sample_var <- function(x) sum((x-sum(x)/length(x))^2)/(length(x)-1)
grDevices::pdf(tempfile(fileext=".pdf"))

one <- run_card("one_sample_t")
x <- one$sample_values; n <- length(x); se <- sqrt(sample_var(x)/n)
t <- (sum(x)/n-one$target)/se
ok("one sample statistic / centered sums",near(one$fit$statistic,t))
ok("one sample p / integrated density",near(one$fit$p.value,t_tail(t,n-1)))
q <- t_critical(n-1)
ok("one sample interval / inverse integrated density",near(one$fit$conf.int,mean(x)+c(-1,1)*q*se))

two <- run_card("two_sample_t")
a <- two$group_a; b <- two$group_b
va <- sample_var(a)/length(a); vb <- sample_var(b)/length(b)
t <- (mean(a)-mean(b))/sqrt(va+vb)
df <- (va+vb)^2/(va^2/(length(a)-1)+vb^2/(length(b)-1))
ok("Welch statistic / separate variance arithmetic",near(two$fit$statistic,t))
ok("Welch degrees of freedom",near(two$fit$parameter,df))
ok("Welch p / independent density integration",near(two$fit$p.value,t_tail(t,df)))
wt <- stats::oneway.test(c(a,b)~factor(c(rep(1,length(a)),rep(2,length(b)))),var.equal=FALSE)
ok("Welch t squared / independent one-way implementation",near(wt$statistic,t*t))
ok("Welch p / one-way implementation",near(wt$p.value,two$fit$p.value))
ok("Welch interval / integrated t critical",near(two$fit$conf.int,mean(a)-mean(b)+c(-1,1)*t_critical(df)*sqrt(va+vb)))

pair <- run_card("paired_t")
d <- pair$paired_data$after-pair$paired_data$before
t <- mean(d)/sqrt(sample_var(d)/length(d))
reference <- stats::t.test(d)
ok("paired / one-sample difference implementation",near(pair$fit$statistic,reference$statistic))
ok("paired / manual difference statistic",near(pair$fit$statistic,t))
ok("paired p / integrated density",near(pair$fit$p.value,t_tail(t,length(d)-1)))
ok("paired change interval / direct differences",near(pair$fit$conf.int,mean(d)+c(-1,1)*t_critical(length(d)-1)*sqrt(sample_var(d)/length(d))))

wilson <- run_card("proportion_interval")
score <- stats::prop.test(wilson$successes,wilson$total,correct=FALSE,conf.level=wilson$confidence)
ok("Wilson / native score inversion",near(wilson$interval,score$conf.int))
p <- wilson$p_hat; n <- wilson$total; z <- wilson$z
score_equation <- function(theta) (p-theta)^2-z^2*theta*(1-theta)/n
root1 <- stats::uniroot(score_equation,c(0,p),tol=1e-12)$root
root2 <- stats::uniroot(score_equation,c(p,1),tol=1e-12)$root
ok("Wilson / independently solved quadratic roots",near(wilson$interval,c(root1,root2)))
for(k in c(0L,1L,49L,50L)) {
 edge <- run_card("proportion_interval",list(successes=k))
 ok("Wilson bounds and estimate at count edges",all(edge$interval>=0 & edge$interval<=1) &&
      edge$interval[1L]<=k/50 && edge$interval[2L]>=k/50)
}

linear <- run_card("linear_regression")
x <- linear$study$x; y <- linear$study$y; X <- cbind(1,x)
b1 <- sum((x-mean(x))*(y-mean(y)))/sum((x-mean(x))^2)
b0 <- mean(y)-b1*mean(x)
normal_equations <- drop(solve(crossprod(X),crossprod(X,y)))
ok("OLS / centered moment coefficients",near(stats::coef(linear$fit),c(b0,b1)))
ok("OLS QR / normal equations",near(stats::coef(linear$fit),normal_equations))
res <- y-drop(X%*%normal_equations); mse <- sum(res^2)/(length(y)-2)
se_slope <- sqrt(mse/sum((x-mean(x))^2))
ok("OLS slope interval / integrated t critical",near(linear$interval[2L,],b1+c(-1,1)*t_critical(length(y)-2)*se_slope))

an <- run_card("anova_oneway")
ns <- lengths(an$samples); means <- vapply(an$samples,mean,numeric(1)); vars <- vapply(an$samples,sample_var,numeric(1))
w <- ns/vars; W <- sum(w); k <- length(ns); weighted_mean <- sum(w*means)/W
term <- sum((1-w/W)^2/(ns-1))
manual_f <- sum(w*(means-weighted_mean)^2)/((k-1)*(1+2*(k-2)*term/(k*k-1)))
df1 <- k-1; df2 <- (k*k-1)/(3*term)
ok("Welch ANOVA / weighted-means F",near(an$fit$statistic,manual_f))
ok("Welch ANOVA / Welch-Satterthwaite df",near(an$fit$parameter,c(df1,df2)))
f_density <- function(v) exp((df1/2)*log(df1/df2)+(df1/2-1)*log(v)-
  lbeta(df1/2,df2/2)-((df1+df2)/2)*log1p(df1*v/df2))
p_integrated <- stats::integrate(f_density,manual_f,Inf,rel.tol=1e-10)$value
ok("Welch ANOVA p / integrated beta-ratio density",near(an$fit$p.value,p_integrated))

dg <- run_card("regression_diagnostics")
X <- cbind(1,dg$study$x); y <- dg$study$y; p <- ncol(X)
H <- X%*%solve(crossprod(X))%*%t(X); h <- diag(H)
beta <- drop(solve(crossprod(X),crossprod(X,y))); fitted <- drop(X%*%beta)
e <- y-fitted; mse <- sum(e^2)/(nrow(X)-p)
manual_cook <- e^2*h/(p*mse*(1-h)^2)
ok("leverage / full projection matrix",near(dg$leverage,h))
ok("standardized residuals / direct formula",near(dg$standardized,e/sqrt(mse*(1-h))))
ok("Cook distance / algebraic influence",near(dg$cooks,manual_cook))
loo <- vapply(seq_len(nrow(X)),function(i) {
 coef <- solve(crossprod(X[-i,,drop=FALSE]),crossprod(X[-i,,drop=FALSE],y[-i]))
 sum((fitted-drop(X%*%coef))^2)/(p*mse)
},numeric(1))
ok("Cook distance / actual leave-one-out refits",near(dg$cooks,loo))

gl <- run_card("glm_binomial")
X <- cbind(1,gl$trial_data$x); y <- gl$trial_data$successes; totals <- gl$trial_data$total
log1pexp <- function(v) pmax(v,0)+log1p(exp(-abs(v)))
nll <- function(b) {eta<-drop(X%*%b);sum(totals*log1pexp(eta)-y*eta)}
grad <- function(b) drop(crossprod(X,totals*stats::plogis(X%*%b)-y))
opt <- stats::optim(c(0,0),nll,grad,method="BFGS",control=list(reltol=1e-12,maxit=5000))
ok("binomial GLM / independent BFGS likelihood optimizer",opt$convergence==0 && near(gl$beta,opt$par,2e-6))
intercept_for <- function(slope) stats::uniroot(function(intercept)
 sum(y-totals*stats::plogis(intercept+slope*gl$trial_data$x)),c(-100,100),tol=1e-12)$root
profile_score <- function(slope) sum(gl$trial_data$x*(y-totals*stats::plogis(intercept_for(slope)+slope*gl$trial_data$x)))
profile_slope <- stats::uniroot(profile_score,c(-10,10),tol=1e-10)$root
profile_beta <- c(intercept_for(profile_slope),profile_slope)
ok("binomial GLM / nested scalar likelihood-score roots",near(gl$beta,profile_beta,2e-7))
prob <- stats::plogis(drop(X%*%profile_beta))
information <- crossprod(X,X*as.numeric(totals*prob*(1-prob)))
ok("binomial GLM covariance / likelihood information",near(stats::vcov(gl$fit),solve(information),2e-6))
normal_critical <- stats::uniroot(function(q) .5+stats::integrate(function(x) exp(-x*x/2)/sqrt(2*pi),0,q)$value-.975,c(0,5),tol=1e-10)$root
ok("binomial Wald odds interval / score solution and normal integration",near(gl$odds_interval,exp(profile_slope+c(-1,1)*normal_critical*sqrt(solve(information)[2L,2L])),2e-6))
ok("binomial odds and probability scales",near(gl$result['odds_ratio'],exp(profile_slope)) &&
   near(gl$probability_at_zero,1/(1+exp(-profile_beta[1L]))))

set.seed(339L); saved_seed <- .Random.seed; saved_kind <- RNGkind()
boot <- run_card("bootstrap_mean")
ok("bootstrap preserves existing RNG state",identical(.Random.seed,saved_seed) && identical(RNGkind(),saved_kind))
again <- run_card("bootstrap_mean")
ok("bootstrap reproducible replicates",identical(boot$result$means,again$result$means))
manual_quantile6 <- function(x,prob) {
 x<-sort(x); n<-length(x); h<-(n+1)*prob; j<-floor(h); g<-h-j
 if(j<1) return(x[1]); if(j>=n) return(x[n]); (1-g)*x[j]+g*x[j+1]
}
ok("bootstrap percentile endpoints / order-statistic interpolation",near(boot$result$interval,
 vapply(c(.025,.975),function(p) manual_quantile6(boot$result$means,p),numeric(1))))
small <- c(2,5,8)
grid <- expand.grid(a=small,b=small,c=small)
exact_means <- rowMeans(grid)
exact_variance <- mean((exact_means-mean(small))^2)
ok("bootstrap exact enumeration mean",near(mean(exact_means),5))
ok("bootstrap exact enumeration variance identity",near(exact_variance,mean((small-mean(small))^2)/length(small)))
# Independent multinomial-count enumeration, not the ordered-index grid.
weight <- values <- numeric()
for(a in 0:3) for(b in 0:(3-a)) {
 d <- 3-a-b; weight <- c(weight,factorial(3)/(factorial(a)*factorial(b)*factorial(d))/27)
 values <- c(values,(2*a+5*b+8*d)/3)
}
ok("bootstrap two exhaustive enumeration schemes",near(sum(weight),1) &&
 near(sum(weight*values),mean(exact_means)) && near(sum(weight*(values-5)^2),exact_variance))
mc <- boot$bootstrap_mean(small,20000L,.95,841L)
# Fixed, conservative Monte Carlo tolerances: mean error < 6 standard errors;
# SD relative tolerance 6%, greater than six asymptotic normal-SE units here.
ok("bootstrap sampler / exact finite distribution",abs(mean(mc$means)-5)<.06 && abs(mc$standard_error/sqrt(exact_variance)-1)<.06)
rm('.Random.seed',envir=.GlobalEnv)
invisible(boot$bootstrap_mean(small,1000L,.95,841L))
ok("bootstrap preserves absent RNG state",!exists('.Random.seed',envir=.GlobalEnv,inherits=FALSE) && identical(RNGkind(),saved_kind))
assign('.Random.seed',saved_seed,envir=.GlobalEnv)

holm <- run_card("multiple_testing_holm")
pv <- unname(holm$raw_p); m <- length(pv); order_p <- order(pv)
manual <- numeric(m); manual[order_p] <- pmin(1,cummax((m-seq_len(m)+1)*pv[order_p]))
ok("Holm / sorted step-down arithmetic",near(holm$adjusted,manual))
closed <- numeric(m)
for(mask in seq_len(2^m-1L)) {
 included <- as.logical(intToBits(mask)[seq_len(m)])
 local_p <- min(1,sum(included)*min(pv[included]))
 closed[included] <- pmax(closed[included],local_p)
}
ok("Holm / exhaustive closed Bonferroni intersection tests",near(holm$adjusted,closed))
ok("Holm rejection decisions",identical(holm$result$reject,unname(closed)<=.05))
ok("Holm exact six-test example",near(holm$adjusted,c(.012,.07,.124,.4,.42,.18)))
ties <- run_card("multiple_testing_holm",list(raw_p=c(0,1,.05,.05)))
ok("Holm zero/one endpoints and ties",near(ties$adjusted,c(0,1,.15,.15)))

# Explicit numeric boundaries, without silently removing missing observations.
for(bad in c(NA_real_,NaN,Inf,-Inf)) {
 reject('one_sample_t',list(sample_values=c(1,2,bad)))
 reject('two_sample_t',list(group_a=c(1,2,bad)))
 d<-pair$paired_data;d$after[1L]<-bad;reject('paired_t',list(paired_data=d))
 reject('proportion_interval',list(successes=bad))
 d<-linear$study;d$x[1L]<-bad
 reject('linear_regression',list(study=d));reject('regression_diagnostics',list(study=d))
 s<-an$samples;s$A[1L]<-bad;reject('anova_oneway',list(samples=s))
 d<-gl$trial_data;d$x[1L]<-bad;reject('glm_binomial',list(trial_data=d))
 reject('bootstrap_mean',list(measurements=c(1,2,bad)))
 reject('multiple_testing_holm',list(raw_p=c(.01,bad)))
}
for(id in c('one_sample_t','two_sample_t','paired_t','proportion_interval','linear_regression','regression_diagnostics','glm_binomial','bootstrap_mean'))
 for(bad in c(0,1,-.1,1.1,NA_real_)) reject(id,list(confidence=bad))
for(bad in c(0,1,-.1,1.1,NA_real_)) reject('multiple_testing_holm',list(alpha=bad))
reject('one_sample_t',list(sample_values=c(2,2,2)))
reject('one_sample_t',list(sample_values=1))
reject('two_sample_t',list(group_b=numeric()))
d<-pair$paired_data;d$id[2]<-d$id[1];reject('paired_t',list(paired_data=d))
d<-pair$paired_data;d$after<-d$before;reject('paired_t',list(paired_data=d))
for(v in c(-1,.5,51)) reject('proportion_interval',list(successes=v))
for(v in c(0,-1,2.5)) reject('proportion_interval',list(total=v))
d<-linear$study;d$x<-1;reject('linear_regression',list(study=d))
s<-an$samples;s$A<-rep(1,3);reject('anova_oneway',list(samples=s))
d<-gl$trial_data;d$total[1]<-0;reject('glm_binomial',list(trial_data=d))
d<-gl$trial_data;d$successes[1]<-.5;reject('glm_binomial',list(trial_data=d))
d<-gl$trial_data;d$successes[1]<-0;reject('glm_binomial',list(trial_data=d))
for(v in c(0,999,1000.5,Inf)) reject('bootstrap_mean',list(B=v))
reject('bootstrap_mean',list(measurements=c(1,1)))
reject('bootstrap_mean',list(seed=-1))
reject('multiple_testing_holm',list(raw_p=c(.1,-.2)))
reject('multiple_testing_holm',list(raw_p=c(.1,1.2)))
grDevices::dev.off()
cat('Enterprise mathematical/validation checks PASS:',checks,
    '; ten workflow families; independent arithmetic/integration/optimization oracles.\n')