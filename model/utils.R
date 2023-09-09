# Gaussian process kernel
GPkernal = function(max_cov, rate, obs_times) {
    obs_dist = dist(obs_times, diag=T, upper=T) |> as.matrix()
    max_cov * exp( - rate * obs_dist^2 ) 
}


# Parameters
get_params = function(n_days, n_obs_times, P0, K, r, max_cov, rate, 
                      a1, b1, c1, s1, a2, c2, s2, N, obs_times ) {
    deltaT = .001
    if ( is.null(obs_times) )
        obs_times = seq(deltaT, n_days - deltaT, length=n_obs_times)
    
    # N-process
    if ( is.null(N) ) {
        cov_mat = GPkernal( max_cov, rate, obs_times )
        N = MASS::mvrnorm( 1, mu=rep(0,n_obs_times), Sigma = cov_mat )
        names(N) = NULL    
    }
    list(
        n_days      = n_days,
        n_obs_times = n_obs_times,
        obs_times   = obs_times,
        N = N,
        P0 = P0, K = K, r = r, max_cov = max_cov, rate = rate,
        a1 = a1, b1 = b1, c1 = c1, s1 = s1, a2 = a2, c2 = c2, s2 = s2
    )
}


# Call Stan for simulation
simulate = function(Params, file="sim.stan") {
    m = cmdstanr::cmdstan_model(file)
    sim = m$sample(data=Params, seed=123, 
                   fixed_param=TRUE, chains=1, iter_sampling=1)
    
    sim_pars = c("P", "M1", "M2", "P_meas", "N_meas")
    sim = lapply(sim_pars, function(p) sim$draws(variables=p) |> as.vector())
    names(sim) = sim_pars
    list( sim=sim, params=Params )
}


# Adjust sampling rate for time series observations 
subset_obs = function( sim, idx=seq( 1, 98, by=1 ) ) {
    if ( !"sim" %in% names(sim) )
        return( subset_obs_base(sim,idx) )
    sim$sim    = subset_obs_base(sim$sim, idx)
    sim$params = subset_obs_base(sim$params, idx)
    sim
}
subset_obs_base = function( sim, idx=seq( 1, 98, by=1 ) ) {
    for ( p in names(sim) ) {
        if ( length(sim[[p]]) > 1 ) sim[[p]] = sim[[p]][idx]
        if ( p == "n_obs_times" ) sim[[p]] = length(idx)
    }
    sim
}


###############################
#### Statistical Inference ####
###############################
post_mean_predict = function(s=NULL, params=NULL, sim_file="model/sim.stan") {
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
    sim = simulate(sim_pars, sim_file)
    return( c(sim$sim, sim$params)  )
}


#' Posterior prediction
#'
#' To generate true values, simply pass NULL to fit `PS`
#' 
#' @param idx_s Numeric indicies to posterior samples
#' @param fit cmdstanfit object. If NULL, use default parameters
#'        provided in the argument `params`.
#' @param sim_file Path to stan file for simulation.
post_draw = function(idx_s, fit, params, sim_file) {
    len_idx_s = length(idx_s)
    PS = data.frame()
    if ( !is.null(fit) )
        PS = stom::extract(fit)
    samples = lapply( idx_s, function(i) 
        post_draw_single(i,PS,params,sim_file) )
    OUT = lapply( samples[[1]], function(x) {
        l = length(x)
        if ( l > 1 )
            return( matrix(nrow=len_idx_s, ncol=l) )
        return( rep(NA_real_, l) )
    })
    names(OUT) = names(samples[[1]])
    for ( i in 1:len_idx_s ) {
        for ( nm in names(OUT) ) {
            if ( is.matrix(OUT[[nm]]) ) {
                OUT[[nm]][i,] = samples[[i]][[nm]]
            } else {
                OUT[[nm]][i] = samples[[i]][[nm]]
            }
        }
    }
    OUT
}


#' Posterior prediction for one posterior draw
#'
#' To generate true values, simply pass an empty data.frame to `PS`
post_draw_single = function(idx_s, PS, params, sim_file) {
    # Collect estimated parameters
    sim_pars = params
    for ( p in names(pars) ) {
        d_post = stom::get_pars( PS, pars=p )
        if ( ncol(d_post) >= 1 ) {
            x = unlist( d_post[idx_s,] )
            names(x) = NULL
            sim_pars[[p]] = x
        }
        
    }
    sim = simulate(sim_pars, sim_file)
    return( c(sim$sim, sim$params) )
}



####################
##### Helpers ######
####################
col.alpha = function(acol, r = 0.5) {
    acol = col2rgb(acol)
    acol = rgb(acol[1]/255, acol[2]/255, acol[3]/255, r)
    acol
}

standardize = function(x, m=0, s=1) {
    center = (x - mean(x)) / sd(x)
    center * s + m
}




