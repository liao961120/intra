par(oma = rep(0,4), mar=c(4.1, 2.1, 1.1, 1))
P_growth = function(t, r, K, P0) {
    K / ( 1 + exp(-r*t)*(K-P0)/P0 )
}

# Simulate time series with Gaussian process
GP = function(max_cov, rate, distMat, delta=0) {  # Gaussian kernel function
    m = max_cov * exp( - rate * distMat^2 )   
    diag(m) = diag(m) + delta
    m
}
n_days = 49
obs_times = seq(0, n_days, length=150)
obs_dist = dist(obs_times, diag=T, upper=T) |> as.matrix()
GPkernal = GP( max_cov=2, rate=.15, distMat=obs_dist )

gamma = .3
P = P_growth(obs_times, r=.3, K=10, P0=.01)

set.seed(10)
plot(1, type="n", xlim=c(0,50), ylim=c(-7,10), xlab="Day", ylab = "")
lines(obs_times, P, lwd=3, col=stom::col.alpha(2))
for ( i in 2:5 ) {
    N = MASS::mvrnorm( 1, -gamma * P, GPkernal )
    lines( obs_times, N, col=stom::col.alpha(i,.3), lwd=2 )
    points( obs_times, N, col=stom::col.alpha(i,.8), pch=c(15,17,23,19)[i-1] )
}
legend(-1.1, 10, paste("draw",1:4), col = 2:5, pch=c(15,17,23,19),
       lty=1, lwd=2, cex=1.1 )



