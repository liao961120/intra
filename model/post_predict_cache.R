library(stom)
source("utils.R")
N_DRAWS = 20

# Cache posterior draws
for ( i in 1:4 ) {
    fp = paste0("data/", c("m1-49","m1-98","m1-98-sd","m2-49"), ".RDS" )[i]
    subset_by = c(2,1,1,2)[i]
    outfp = file.path( "data", paste0("draws_",basename(fp)) )
    m = readRDS(fp)
    
    sim = readRDS("data/sim.RDS") |> subset_obs(seq(1,98,by=subset_by))
    pars = sim$params
    
    set.seed(1234)
    i_draws = sample(1:n_samples(m), N_DRAWS)
    post_samp = post_draw(i_draws, m, pars, "sim.stan")
    saveRDS(post_samp, outfp)
}
