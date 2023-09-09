library(stom)
library(deSolve)

lpg = function(Time, State, Pars) {
    with( as.list(c(State, Pars)), {
        dP = r * P * (1 - P/K)
        return( list(c(dP)) )   
    })
}

ODE = function( r=.3, K=10, P0=.01 ) {
    pars = c( r = r, K = K)
    init = c( P = P0 )
    times = seq(0, 49, by=.01)
    out = ode( init, times, lpg, pars ) 
    out
}


par( mfrow= c(1, 2) )

plot(1, type="n", xlab = "Day", ylab = "P", ylim=c(0,10), xlim=c(0,50))
lines( ODE(r=.2, K=10, P0=.01), col = col.alpha(2,1), lwd=2)
lines( ODE(r=.3, K=10, P0=.01), col = col.alpha(2,1), lwd=3)
lines( ODE(r=.4, K=10, P0=.01), col = col.alpha(2,1), lwd=4)
legend(30, 2.5, c("r = .2  K = 10", 
                  "r = .3  K = 10", 
                  "r = .4  K = 10"),
       col=2, lwd=2:4)


plot(1, type="n", xlab = "Day", ylab = "P", ylim=c(0,10), xlim=c(0,50))
abline(h=c(10,8,6), col="grey", lty="dashed", lwd=2)
lines( ODE(r=.3, K=10, P0=.01), col = 4, lwd=4)
lines( ODE(r=.3, K= 8, P0=.01), col = 4, lwd=3)
lines( ODE(r=.3, K= 6, P0=.01), col = 4, lwd=2)
legend(30, 2.5, c("r = .3  K = 10", 
                  "r = .3  K =  8", 
                  "r = .3  K =  6"),
       col=4, lwd=4:2 )



##########################
#### Integrated form #####
##########################
log_curve = function(t, r, K, P0) {
    K / ( 1 + exp(-r*t)*(K-P0)/P0 )
}


curve(log_curve(x,r=.4,K=10,P0=.001), 0,50)
curve(log_curve(x,r=.3,K=10,P0=.001), 0,50, add=T, col=2)

