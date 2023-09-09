# library(stom)
source("utils.R")
TeX = latex2exp::TeX

          # b,   l,   t,  r
inner = c(4.1, 4.1, 1.8, .5)
par( mfrow=c(2,2), oma=c(0,0,0,0), mar=inner )
for ( i in 1:4 ) {
    ns = c(49, 98, 98, 98)[i]
    pre_ = paste("Model", c(1,1,1,2))[i]
    suf_ = c("","", "($\\sigma$ = .1)", "(49 for each measure)")[i]
    M = c( "m1-49", "m1-98", "m1-98-sd", "m2-49" )[i]
    BY = c( 2, 1, 1, 2)[i]
    
    m = readRDS( paste0("data/", M, ".RDS") )
    if ( M != "m1-98-sd") {
        sim = readRDS("data/sim.RDS") |> subset_obs(seq(1,98,by=BY))
    } else {
        sim = readRDS("data/sim2.RDS") |> subset_obs(seq(1,98,by=BY))
    }
        
    pars = sim$params
    
    # post_mean = post_mean_predict( m$summary(), pars, "sim.stan" )
    true = post_draw(1, NULL, readRDS("data/sim.RDS")$params, "sim.stan")
    post_samp = readRDS( paste0("data/draws_", M, ".RDS") )
    
    # Plot
    obs_times = pars$obs_times
    plot(1, type="n", ylim=c(-13, 18), xlim=c( 0, 49 ),
         # xlab="", ylab=""
         xlab="", ylab="Measurement"
         )
    # Process curve (true)
    lines(true$obs_times, as.vector(true$P), col=col.alpha(2,.8), lwd=3, lty=1 )
    lines(true$obs_times, as.vector(true$N)-6.5, col=col.alpha(1,.5), lwd=3, lty=1 )
    # Process curve (draws)
    for ( i in 1:nrow(post_samp$P) ) {
        lines(obs_times, post_samp$P[i,], col=col.alpha(2,.3), lwd=1)
        lines(obs_times, post_samp$N[i,]-6.5, col=col.alpha(1,.15), lwd=1)
        # Measurement latent score
        lines( obs_times, post_samp$M1[i,], col=col.alpha(2,.2) )
        if ( M == "m2-49" )
            lines( obs_times, post_samp$M2[i,], col=col.alpha(1,.15) )
    }
    emp_obs = sim$sim
    points( obs_times, emp_obs$P_meas, pch=19, col=col.alpha(2,.7), cex=.7 )
    if ( M == "m2-49" )
        points( obs_times, emp_obs$N_meas, pch=19, col=col.alpha(1,.6), cex=.7 )
    title( main = TeX(paste(pre_, "with", ns, "obs.", suf_)) )
}
