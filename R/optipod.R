#' optipod
#'
#' Function to estimate the option implied probability of default according
#' to "Vilsmeier, J. (2014). Updating the option implied probability of default
#' methodology." Available at SSRN 2797025. Note that the code was provided
#' by Johannes Vilsmeier but was refactored, therefore possible errors might
#' were included in original code.
#'
#' @param mu vector of option prices
#' @param K  vector of strike prices
#' @param r annual risk free interest rate (in decimals)
#' @param ttm time to maturity in years
#' @param Lweights weights assigned to option contract
#' @param multiplicationFactor multiplication factor to define upper bound of domain
#' @param visualise if TRUE, plots the resulting probability density function
#' @param ticker ticker which will be displayed in title of plot
#' @param date date which will be displayed in title of plot
#'
#' @return data.frame with necessary results (one row)
optipod <- function(mu=mu, K=K, r=r, ttm=ttm, Lweights=Lweights,
                    multiplicationFactor=5,
                    visualise=F, ticker=NA, date=NA){

  # mu: vector of option prices;
  # K: vector of strikes which has to be consistent with mu wrt ordering
  # r: annual discount rate
  # T: maturity in years
  # Lweights: liquidity weights which should be derived from outstanding volume;

  # ---------------------------------------------------------------------------.
  # model parameters ----
  # ---------------------------------------------------------------------------.
  # discount factor
  DF <- exp(-r*ttm)
  # number of option contracts/strikes
  B <- length(K)
  # initial values for lambda
  initialLambdas <- lambda <- seq(0.01, 0.01, length.out=B)
  # minimum value of stock price (always set to 0)
  Vmin <- 0
  # maximum value of stock price (use large multiple, e.g. 5 times)
  Vmax <- mu[1]*multiplicationFactor
  # minimum value of D
  D <- Dmin <- 1
  # maximum value of D
  Dmax <- 20
  # domain of asset value
  V <- 0:Vmax
  # number of option contracts/strikes
  Kmax <- length(K)

  # ---------------------------------------------------------------------------.
  # Objective Function as defined in Vilsmeier 2015 ----
  # ---------------------------------------------------------------------------.

  objectiveFunction<-function(lambda,D,Vmax,Vmin,mu,K){

    # -------------------------------------------------------------------------.
    # support functions for data handling ----
    # -------------------------------------------------------------------------.
    lambdared<-function(x,y){lambda[x:y]}
    Lweightsred<-function(x,y){Lweights[x:y]}
    Kred<-function(x,y){K[x:y]}
    mured<-function(x,y){mu[x:y]}

    # -------------------------------------------------------------------------.
    # calculate objective function ----
    # -------------------------------------------------------------------------.

    # first term in log() -----------------------------------------------------.
    firstTerm <- exp((-Lweights*lambda)%*%mu)*(D-Vmin)

    # second term in log() ----------------------------------------------------.
    secondTermCalc <- function(uB, lB){

      kIndex <- which(K==uB)

      nom1 <- exp((Lweightsred(1,(kIndex-1))*lambdared(1,(kIndex-1)))%*%(DF*(uB-Kred(1,(kIndex-1)))
                -mured(1,kIndex-1))-sum(Lweightsred(kIndex,B)*lambdared(kIndex,B)*mured(kIndex,B)))
      nom2 <- exp((Lweightsred(1,(kIndex-1))*lambdared(1,(kIndex-1)))%*%(DF*(lB-Kred(1,(kIndex-1)))
                -mured(1,(kIndex-1)))-sum(Lweightsred(kIndex,B)*lambdared(kIndex,B)*mured(kIndex,B)))
      nominator <- nom1-nom2

      denominator <- DF*sum(Lweightsred(1,(kIndex-1))*lambdared(1,kIndex-1))

      return(nominator/denominator)
    }

    upperBound <- K[2:B]
    lowerBound <- K[1:(B-1)]
    secondTerm <- mapply(secondTermCalc, upperBound, lowerBound)

    # third term in log() -----------------------------------------------------.
    thirdTermCalc <- function(Kmax, Vmax){

      nom1 <- exp((Lweightsred(1,B)*lambdared(1,B))%*%(DF*(Vmax-D-Kred(1,B))-mured(1,B)))
      nom2 <- exp((Lweightsred(1,B)*lambdared(1,B))%*%(DF*(Kmax-Kred(1,B))-mured(1,B)))
      nominator <- nom1-nom2

      denominator <- DF*sum(Lweightsred(1,B)*lambdared(1,B))

      return(nominator/denominator)
    }

    Kmax <- K[B]
    thirdTerm <- thirdTermCalc(Kmax, Vmax)

    # calculate objective function --------------------------------------------.
    result <- log(1/(Vmax-Vmin)) + log(firstTerm + sum(secondTerm) + thirdTerm)
    return(result)
  }

  # ---------------------------------------------------------------------------.
  # estimate probability of default for given default barrier D ----
  # ---------------------------------------------------------------------------.
  estimatePoD <- function(D,final=T){

    optimised<-try(
      optim(
        par=initialLambdas,
        fn=objectiveFunction,
        D=D,
        Vmax=Vmax,
        Vmin=Vmin,
        mu=mu,
        K=K,
        gr=NULL,
        control=list(maxit=10000,reltol=10^-7)
      ), silent=TRUE
    )

    lambda <- optimised$par

    # for what is this function??
    g<-Vectorize(function(V,K=K,D=D,mu=mu){
      ifelse((V-K-D)>0,DF*(V-K-D),0)-mu
    },vectorize.arg=c("K","mu"))

    # prior uniform distribution
    prior<-function(V,Vmin,Vmax){dunif(V,Vmin,Vmax)}

    # posterior distribution
    posterior<-function(V, D, lambda){
      nominator <- (prior(V,Vmin=Vmin,Vmax=Vmax)*exp(g(V,K,D,mu)%*%(Lweights*lambda)))
      denominator <- as.numeric(exp(objectiveFunction(lambda=lambda,D=D,Vmax=Vmax,Vmin=Vmin,mu=mu,K=K)))
      return(as.vector(nominator/denominator))
    }

    # obtain probability of default
    integ <- try(integrate(posterior, D=D, Vmin, D, lambda=lambda),silent=TRUE)
    PoD0<-as.numeric(integ[1])
    if(final){

      if(visualise){

        if(!is.na(ticker) & !is.na(date)){
          title = paste0("estimated posterior for ", ticker, " (", date, ")")
        } else {
          title = NA
        }

        plot(posterior(Vmin:Vmax,D,lambda),type="l",
             main=title, xlab="Value of Asset", ylab="Density")
        abline(v=D,lty=2)
      }

      df <- data.frame(
        "PoD" = PoD0,
        "lambdas" = paste(lambda, collapse=";"), # leads to neglectable rounding errors
        "Dopt" = D,
        "Vmin" = Vmin,
        "Vmax" = Vmax
      )
      return(df)
      # return(list(PoD0, lambda, D, Vmin, Vmax))
    } else {
      return(c(PoD0))
    }

  }

  # ---------------------------------------------------------------------------.
  # estimate probability of default ----
  # ---------------------------------------------------------------------------.

  # estimate PoD for every D
  PoDs <- estimates <-do.call("c", lapply(Dmin:Dmax, estimatePoD, final=F))

  # calculate average PoD over all D
  PoDavg <- mean(PoDs, na.rm=T)

  # identify the optimal D (D which yields PoD closest to average PoD)
  D <- Dopt <- ifelse(is.na(PoDavg), 1, which.min(abs(PoDs-PoDavg)))

  # final estimates / parameters for optimal D
  final.estimates <- estimatePoD(Dopt, final=T)

  return(final.estimates)

}
