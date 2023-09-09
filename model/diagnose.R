IDX_OBS = seq(1,98,by=1)
library(stom)
source("utils.R")
NC = 4
d = readRDS("data/sim2.RDS") |> subset_obs(IDX_OBS)
m0 = readRDS("data/m1-98-sd.RDS")
s0 = m0$summary()


pars = function(...) get_pars(s0, c(...))$variable
library(bayesplot)
color_scheme_set("viridisC")
mcmc_trace(m0$draws(inc_warmup = TRUE)[,,], 
           pars= pars("lp__", "P0", "r", "K", "a1", "b1", "c1", "s1", 
                      "a2", "c2", "s2", "max_cov", "rate"), 
           n_warmup = m0$metadata()$iter_warmup )
# mcmc_trace(m0$draws(inc_warmup = TRUE)[,,], 
#            pars= pars("N"), 
#            n_warmup = m0$metadata()$iter_warmup )


# Plot divergence
color_scheme_set("darkgray")
# nuts_params(m0)
# mcmc_parcoord(m0$draws()[,c(1,3),] )
library(dplyr)
diver = nuts_params(m0) #|> filter( Chain %in% c(3,4,7,8) )
mcmc_pairs(m0$draws()[,,], np=diver,
           pars = c(
               "r", "K", "P0", "lp__", "a1", "b1", "N[8]", 
               #"c2", "a2"
               NULL
            )
)


s = lapply( 1:NC, function(chain) {
    m0$draws()[,chain,] |> 
        posterior::as_draws_df() |> 
        summary()
})


post_predict = function(chain, params) {
    if ( chain == 0 ) {
        # Use simulation
        sim = simulate(params)
        return(sim)
    }
    if ( chain == 100 ) {
        s = s0  # Use all chains
    } else {
        s = s[[chain]]
    }
    
    # Collect estimated parameters
    sim_pars = params
    for ( p in names(params) ) {
        dt = stom::get_pars(s, p)
        if ( nrow(dt) == 0 ) next
        if ( nrow(dt) > 1 ) {
            sim_pars[[p]] = stom::erect(dt, p)
        } else {
            sim_pars[[p]] = dt$mean
        }
    }
    
    message( "Posterior mean prediction with parameters:" )
    message( str(sim_pars) )
    sim = simulate(sim_pars)
    return(sim)
}
x = post_predict(0, d$params)
# str(x)

chains = c( 0, 100 #, #,
        #1:NC
        )
for ( chain in chains ) {
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
}



#####################################
###### Estimation of N-process ######
#####################################
N_est = get_pars(s0, "N")
plot(d$params$N, pch=19, ylim=c(-5, 5), xlab="Days", ylab="N")
for ( i in 1:d$params$n_obs_times )
    lines( c(i,i), c(N_est$q5[i], N_est$q95[i]), col=col.alpha(2,.3), lwd=3 )
points( N_est$mean, col=2 )

