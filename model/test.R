m1.49    = readRDS("data/m1-49.RDS")
m1.98    = readRDS("data/m1-98.RDS")
m1.98.sd = readRDS("data/m1-98-sd.RDS")
m2       = readRDS("data/m2-49.RDS")
# 
# for ( i in 1:4 ) {
#     m = c(m1.49, m1.98, m1.98.sd, m2)[[i]]
#     n = c("m1.49", "m1.98", "m1.98.sd", "m2")[i]
#     cat("-------------\n")
#     cat("[", n, "]\n")
#     print( m$diagnostic_summary() )
# }




library(stom)
source("utils.R")

sim = readRDS("data/sim.RDS") |> 
    subset_obs(seq(1,98,by=1))
pars = sim$params
# PS = stom::extract(m1.49)

m = m1.98
i_draws = sample(1:n_samples(m), 20)
post_mean = post_mean_predict( m$summary(), pars, "sim.stan" )
post_samp = post_draw(i_draws, m, pars, "sim.stan")
true = post_draw(1, NULL, pars, "sim.stan")

# Plot
obs_times = pars$obs_times
plot(1, type="n", ylim=c(-6, 15), xlim=c( 0, 49 ),
     xlab="Day", ylab="Measurement")
# Process curve (true)
lines(obs_times, as.vector(true$P), col=col.alpha(2), lwd=3, lty=2 )
lines(obs_times, as.vector(true$N), col=col.alpha(1), lwd=3, lty=2 )
# Process curve (est_mean)
# lines(obs_times, post_mean$P, col=col.alpha(2), lwd=2 )
# lines(obs_times, post_mean$N, col=col.alpha(1), lwd=2 )
# Process curve (draws)
for ( i in 1:length(i_draws) ) {
    lines(obs_times, post_samp$P[i,], col=col.alpha(2,.25), lwd=1)
    lines(obs_times, post_samp$N[i,], col=col.alpha(1,.25), lwd=1)
    # Measurement latent score
    lines( obs_times, post_samp$M1[i,], col=col.alpha(2,.25) )
    # lines( obs_times, post_samp$M2[i,], col=col.alpha(2,.25) )
}
emp_obs = sim$sim
points( obs_times, emp_obs$P_meas, pch=19, col=col.alpha(2,.7) )



# Measurement latent score
lines( obs_times, M1, col=col.alpha(2,.7) )
lines( obs_times, M2, col=col.alpha("grey",.7) )
# Measurement observed score
emp_obs = d$sim
points( obs_times, emp_obs$P_meas, pch=19, col=col.alpha(2,.7) )
points( obs_times, emp_obs$N_meas, pch=19, col=col.alpha("grey",.7) )
title(main = chain)

    




library(stom)
source("utils.R")
NC = 4
IDX_OBS = seq(1,98,by=1)
# d = readRDS("data/sim2.RDS") |> subset_obs(IDX_OBS)
# m0 = readRDS("data/m1-98-sd.RDS")
# s0 = m0$summary()


set.seed(985)
post = post_predict( chain, d$params )

# Plotting
with( c(post$sim, post$params) , {
    plot(1, type="n", ylim=c(-6, 11), xlim=c( 0, 50 ),
         xlab="Day", ylab="Measurement")
    # Process curve
    lines(obs_times, P, col=col.alpha(2), lwd=2, lty=2)
    lines(obs_times, N+6.5, col="grey", lwd=2, lty=2 )
    # Measurement latent score
    lines( obs_times, M1, col=col.alpha(2,.7) )
    lines( obs_times, M2, col=col.alpha("grey",.7) )
    # Measurement observed score
    emp_obs = d$sim
    points( obs_times, emp_obs$P_meas, pch=19, col=col.alpha(2,.7) )
    points( obs_times, emp_obs$N_meas, pch=19, col=col.alpha("grey",.7) )
    title(main = chain)
})
