par(oma = rep(0,4), mar=c(4.1, 2.1, 1.1, 1))
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

set.seed(10)
plot(1, type="n", xlim=c(0,50), ylim=c(-5,5.4), xlab="Day", ylab = "N")
for ( i in 2:5 ) {
    N = MASS::mvrnorm( 1, rep(0,length(obs_times)), GPkernal )
    lines( obs_times, N, col=stom::col.alpha(i,.3), lwd=2 )
    points( obs_times, N, col=stom::col.alpha(i,.8), pch=c(15,17,23,19)[i-1] )
}
legend(-1.1, 5.4, paste("draw",1:4), col = 2:5, pch=c(15,17,23,19), 
       lty=1, lwd=2, cex=1.1 )


# library(latex2exp)
# curve( 2 * exp( - 0.2 * x^2 ), from=0, to=9.5, lwd=2,
#        ylab = "K (covariance)", xlab = "distance" ) 
# curve( 2 * exp( - 0.1 * x^2 ),  add=T, lwd=2, col=2 ) 
# curve( 2 * exp( - 0.05 * x^2 ), add=T, lwd=2, col=4 ) 
# legend( 7.5, 2, TeX( paste0("\\rho = ",c(.2,.1,.05)) ), lwd=3, col=c(1,2,4) )