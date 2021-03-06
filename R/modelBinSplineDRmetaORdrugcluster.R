#******* jags model of spline dose-response model with binomial likelihood for OR

modelBinSplineDRmetaORdrugcluster <- function(){
  for (i in 1:ns) { ## for each study
    # binomial likelihood of number of events in the *refernce* dose level in a study i
    r[i,1] ~ dbinom(p[i,1],n[i,1])

    # logit parametrization of probabilities at each *refernce* dose level: by that exp(beta)= OR
    logit(p[i,1]) <- u[i]

    for (j in 2:(nd[i])) { ## for each dose
      # binomial likelihood of number of events for the *non-refernce* dose in a study i
      r[i,j] ~ dbinom(p[i,j],n[i,j])

      # logit parametrization of probabilities at each *non-refernce* dose level: by that exp(beta)= OR
      logit(p[i,j]) <- u[i] + delta[i,j]
      delta[i,j] <-   beta1_c[i,drug[i]]*(X1[i,j]-X1[i,1]) + beta2_c[i,drug[i]]*(X2[i,j]-X2[i,1])
    }

  }

  # distribution of random effects
  for(i in 1:ns) {
    beta1_c[i,drug[i]]~dnorm(b1_c[drug[i]],prec.beta.with)
    beta2_c[i,drug[i]]~dnorm(b2_c[drug[i]],prec.beta.with)
  }

  for (c in c(1:4,6)) {
    b1_c[c] ~dnorm(b1, prec.beta.betw)
    b2_c[c] ~dnorm(b2, prec.beta.betw)
  }

for (i in 1:ns) {
  u[i]~dnorm(0,0.001)
}
  # prior distribution for heterogenity within clusters
  prec.beta.with<-1/tau.sq.with
  tau.sq.with<-tau.with*tau.with
  tau.with~ dnorm(0,1)%_%T(0,)


  # prior distribution to b1 and b2
  b1 ~ dnorm(0,0.001)
  b2 ~ dnorm(0,0.001)

  # prior distribution to heterogenity between clusters
  prec.beta.betw<-1/tau.sq.betw
  tau.sq.betw<-tau.betw*tau.betw
  tau.betw~ dnorm(0,1)%_%T(0,)
}
