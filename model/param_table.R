sim = readRDS("data/sim.RDS")


pars_nm = "T,$r$,$K$,$P_0$,$\\eta$,$\\rho$,$\\sigma$,$a$,$b$,$c$"
pars = "n_obs_times,r,K,P0,max_cov,rate,s1,a1,b1,c1"
pars = strsplit(pars, ",")[[1]]
pars_nm = strsplit(pars_nm, ",")[[1]]
vals = rep(0, length(pars))
for ( i in seq_along(pars) )
    vals[i] = sim$params[[pars[i]]]
pars = paste0( '`', pars, '`' )

tbl = data.frame( pars_nm, pars, vals )
colnames(tbl) = c("Parameter", "Coded name", "Value")

pander::set.alignment('center', row.names = 'right')
pander::pandoc.table( tbl, style="rmarkdown", 
                      digits = 2,
                      keep.trailing.zeros = T )
