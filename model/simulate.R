library(latex2exp)
source("utils.R")
set.seed(1024)

Params = get_params(
    n_days = 49,
    n_obs_times = 98,
    # P-process
    P0     =  .01 ,
    K      =   10 ,
    r      =  .3 ,
    # N-process
    max_cov =  2,
    rate    = .2,
    # Measurement of P-process
    a1     =  .78 ,   # loading on purported construct
    b1     =  .744 ,  # scaling factor
    c1     =   3.14 ,
    s1     =  .5 ,
    # Measurement of N-process
    a2     =  .6 ,
    c2     =   0 ,
    s2     =  .5 ,
    N      =  NULL,
    obs_times = NULL
)


# Simulation (sd = .5)
sim = simulate(Params)
saveRDS( sim, "data/sim.RDS" )

# Simulation (sd = .1)
Params2 = Params
Params2$s1 = .1
Params2$s2 = .1
sim2 = simulate(Params2)
saveRDS( sim2, "data/sim2.RDS" )

#######################################
#### Plot measurement latent curve ####
#######################################
idx_obs = seq(1, sim$params$n_obs_times, by=1) |> 
    as.integer() |> unique()
with( c(sim$sim, sim$params) , {
    plot(1, type="n", ylim=c(-6, 11), xlim=c( 0, 50 ),
         xlab="Day", ylab="Measurement")
    # Process curve
    lines(obs_times, P, col=col.alpha(2,.8), lwd=2, lty=2)
    lines(obs_times, N+6.5, col=col.alpha(1,.65), lwd=2, lty=2 )
    # Measurement latent score
    lines( obs_times, M1, col=col.alpha(2,.5), lwd=2 )
    # lines( obs_times, M2, col=col.alpha("grey",.7) )
    # Measurement observed score
    points( obs_times[idx_obs], P_meas[idx_obs], pch=19, col=col.alpha(2,.8) )
    # points( obs_times[idx_obs], N_meas[idx_obs], pch=19, col=col.alpha("grey",.7) )
    legend(27,-1, c(
        TeX("Aversive Environmental Impact ($N_t$)"),
        TeX("Cognitive Reappraisal ($P_t$)"),
        TeX("Measurement (latent, $M_t$) "),
        TeX("Measurement (observed, $P_t^{obs}$)"),
        NULL
        ), 
           col = c(col.alpha(1,.65), col.alpha(2,.8), col.alpha(2,.8), col.alpha(2,.8)),
           lty = c(2,2,1,NA),
           pch = c(NA,NA,NA,19),
           lwd = 3)
})


