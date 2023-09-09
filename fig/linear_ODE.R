library(deSolve)

dxdt = function(Time, State, Pars) {
    with( as.list(c(State, Pars)), {
        dX = a1 * x + b1 * y
        dY = a2 * x + b2 * y
        return( list(c(dX,dY)) )   
    })
}

ODE = function( a1=1, b1=2, a2=2, b2=1, x0=1, y0=-1 ) {
    pars = c( a1=a1, b1=b1, a2=a2, b2=b2 )
    init = c( x=x0, y=y0 )
    times = seq(0,500, by=.01)
    out = ode( init, times, dxdt, pars ) 
    
    # Stability analysis
    p = a1 + b2
    q = a1*b2 + a2*b1
    delta = p^2 - 4*q
    list( p=p, q=q, delta=delta ) |> print()
    out
}

out = ODE( a1=1, b1=1, a2=-4, b2=-1, x0=1, y0=-1 )
plot(1, type="n", xlab = "Day", ylab = "X", ylim=c(-3,3), 
     xlim=c(0,10))
lines( out[,1], out[,2], col = 2, lwd=2)
lines( out[,1], out[,3], col = 4, lwd=2)


# cor( out[,2], out[,3] )
ts = out[,1]
ts = ts[ ts > 2.8 & ts < 5.1 ]
i = out[,1] %in% ts
cor( out[i,2], out[i,3] )


