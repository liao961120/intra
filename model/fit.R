library(stom)
source("utils.R")
sim = readRDS("data/sim.RDS")
N_CORES = 4

# Initial parameter values for MCMC sampler
write_init_files = function(n_obs_times,
                            dir="init", 
                            chains=1:N_CORES, 
                            seed=50) {
    old <- .Random.seed
    on.exit( { .Random.seed <<- old } )
    set.seed(seed)
    
    sapply( chains, function(chain) {
        init = tibble::lst(
                P0 = rnorm(1, 0, .5) |> abs(),
                r  = rbeta(1, 1.7, 2),
                K  = rnorm(1, 10, 3) |> abs(),
                s1 = rnorm(1) |> abs(),
                a1 = rbeta(1, 3.8, 2.5),
                b1 = rbeta(1, 2, 1),
                c1 = rnorm(1, 0, 2) |> abs(),
                s2 = rnorm(1) |> abs(),
                a2 = rbeta(1, 3, 3),
                c2 = rnorm(1),
                eta = rnorm(n_obs_times, 0, .5),
                max_cov = rnorm(1, 0, 3) |> abs(),
                rate = rnorm(1, 0, .3) |> abs()
                
        )
        fp = file.path(dir, paste0(chain,".json") )
        cmdstanr::write_stan_json(init, fp)
        fp
    })
}


####################################
######   m1: single measure   ######
####################################
dat = subset_obs( sim, seq(1,98,by=2) )
dat = c(dat$params, dat$sim)
m = cmdstanr::cmdstan_model("m1.stan")
m = m$sample(data=dat, 
             chains=N_CORES, parallel_chains=N_CORES,
             iter_sampling=150, iter_warmup=300,
             refresh = 50,
             seed = 1234,
             save_warmup = TRUE,
             init = write_init_files(dat$n_obs_times, seed=40)
)
save_model(m, fp = "data/m1-49.RDS")


#####################################################
######  m1: single measure, more observations  ######
#####################################################
dat = subset_obs( sim, seq(1,98,by=1) )
dat = c(dat$params, dat$sim)
m = cmdstanr::cmdstan_model("m1.stan")
m = m$sample(data=dat, 
             chains=N_CORES, parallel_chains=N_CORES,
             iter_sampling=150, iter_warmup=300,
             refresh = 50,
             seed = 1234,
             save_warmup = TRUE,
             init = write_init_files(dat$n_obs_times, seed=40)
)
save_model(m, fp = "data/m1-98.RDS")


###############################################################
######  m1: single measure, more observations, small sd  ######
###############################################################
sim2 = readRDS("data/sim2.RDS")
dat = subset_obs( sim2, seq(1,98,by=1) )
dat = c(dat$params, dat$sim)
m = cmdstanr::cmdstan_model("m1.stan")
m = m$sample(data=dat, 
             chains=N_CORES, parallel_chains=N_CORES,
             iter_sampling=150, iter_warmup=300,
             refresh = 50,
             seed = 1234,
             save_warmup = TRUE,
             init = write_init_files(dat$n_obs_times, seed=40)
)
save_model(m, fp = "data/m1-98-sd.RDS")


##################################
######   m2: two measures   ######
##################################
dat = subset_obs( sim, seq(1,98,by=2) )
dat = c(dat$params, dat$sim)
m = cmdstanr::cmdstan_model("m2.stan")
m = m$sample(data=dat, 
             chains=N_CORES, parallel_chains=N_CORES,
             iter_sampling=150, iter_warmup=300,
             refresh = 50,
             seed = 5432,
             save_warmup = TRUE,
             init = write_init_files(dat$n_obs_times, seed=40)
)
save_model(m, fp = "data/m2-49.RDS")
