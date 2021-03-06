#******* jags model of spline dose-response model with binomial likelihood for OR

modelBinSplineDRmetaORwithRes <- function(){
  for (i in 1:ns) { ## for each study
    # binomial likelihood of number of events in the *refernce* dose level in a study i
    r[i,1] ~ dbinom(p[i,1],n[i,1])

    # logit parametrization of probabilities at each *refernce* dose level: by that exp(beta)= OR
    logit(p[i,1]) <- u[i]


    # omega[i,1] <- 0
    # w[i,1] <- 0
    for (j in 2:(nd[i])) { ## for each dose
      # binomial likelihood of number of events for the *non-refernce* dose in a study i
      r[i,j] ~ dbinom(p[i,j],n[i,j])

      # logit parametrization of probabilities at each *non-refernce* dose level: by that exp(beta)= OR
      logit(p[i,j]) <- u[i] + delta[i,j]
      delta[i,j] <-   beta1[i]*(X1[i,j]-X1[i,1]) + beta2[i]*(X2[i,j]-X2[i,1]) + omega[i,j]
    }
  }

  b[1] <-0
  for (i in 1:ns) {
      #% random effect for residual heterogenity
      omega[i,2:(nd[i])]  ~ dmnorm(w[i,2:(nd[i])], xi.sq*ximat[(b[i]+1):(b[i]+nd[i]-1),1:(nd[i]-1)]-tau.sq*taumat[(b[i]+1):(b[i]+nd[i]-1),1:(nd[i]-1)]-
                        rho*rhomat[(b[i]+1):(b[i]+nd[i]-1),1:(nd[i]-1)])


    #*(1-step(xi.sq*ximat[(b[i]+1):(b[i]+nd[i]-1),1:(nd[i]-1)]-(tau.sq*taumat[(b[i]+1):(b[i]+nd[i]-1),1:(nd[i]-1)]+ rho*rhomat[(b[i]+1):(b[i]+nd[i]-1),1:(nd[i]-1)])))+
                                                             #(xi.sq*ximat[(b[i]+1):(b[i]+nd[i]-1),1:(nd[i]-1)]-(tau.sq*taumat[(b[i]+1):(b[i]+nd[i]-1),1:(nd[i]-1)]+ rho*rhomat[(b[i]+1):(b[i]+nd[i]-1),1:(nd[i]-1)]))*(step(xi.sq*ximat[(b[i]+1):(b[i]+nd[i]-1),1:(nd[i]-1)]-(tau.sq*taumat[(b[i]+1):(b[i]+nd[i]-1),1:(nd[i]-1)]+ rho*rhomat[(b[i]+1):(b[i]+nd[i]-1),1:(nd[i]-1)]))))) #inverse(xi.sq*ximat[(b[i]+1):(b[i]+nd[i]-1),1:(nd[i]-1)]))-
      b[i+1] <- b[i]+ nd[i]-1

     for (j in 2:nd[i]) {
       w[i,j]~dnorm(0,0.001)
     }

  }

  # distribution of random effects
  for(i in 1:ns) {
    beta1[i]~dnorm(beta1.pooled,prec.beta)
    beta2[i]~dnorm(beta2.pooled,prec.beta)
    u[i]~dnorm(0,0.001)
  }

  # prior distribution for heterogenity
  prec.beta<-1/tau.sq
  tau.sq<-tau*tau
  tau~ dnorm(0,1)%_%T(0,)
#
  prec.xi <- 1/xi.sq
  #xi.sq<- xi*xi
  xi.sq~dunif(0,f.tau.rho)
f.tau.rho <- tau.sq*Amax + 4*rho*Bmax
  #
  rho~dunif(0,1)

  # prior distribution for both regression coeff beta1 and beta2
  beta1.pooled ~ dnorm(0,0.001)
  beta2.pooled ~ dnorm(0,0.001)


}

#
