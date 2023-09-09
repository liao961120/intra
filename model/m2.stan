/*
    Model with a single measurement
*/
functions {
    vector ode(
            real time,
            vector P,       // states
            real r, real K  // Parameters
            ) {
        vector[1] dP_dt;
        dP_dt[1] = r * P[1] * ( 1 - P[1]/K );
        return dP_dt;
    }
    // Gaussian process kernel function
    matrix GP(array[] real x, real max_cov, real rate) {
        // https://mc-stan.org/docs/functions-reference/gaussian-process-covariance-functions.html
        // return max_cov * exp( - rate * distMat );
        return gp_exp_quad_cov( x, sqrt(max_cov), inv_sqrt(2*rate) );
    }
}
data {
    int n_days;
    int n_obs_times;  // number of time points with observations
    array[n_obs_times] real<lower=0,upper=n_days> obs_times;  // times with observations
    array[n_obs_times] real P_meas;
    array[n_obs_times] real N_meas;
}
transformed data {
    real delta = 1e-9;
}
parameters {
    // P-process parameters
    real<lower=0> r;   // Process growth rate
    real<lower=0> K;   // Carrying capacity
    real<lower=0> P0;  // Initial condition
    
    // Non-centered parameterization for N
    vector[n_obs_times] eta;
    real<lower=0> max_cov;
    real<lower=0> rate;

    // P Measure params
    real<lower=0> s1;
    real<lower=0,upper=1> a1;
    real<lower=0,upper=1> b1;  // measurement scaling factor (b/t 0 & 1)
    real<lower=0> c1;

    // N Measure params
    real<lower=0> s2;
    real<lower=0,upper=1> a2;
    real c2;
}
transformed parameters {
    vector[n_obs_times] N;  // N-process
    {   
        matrix[n_obs_times, n_obs_times] K_GP = GP(obs_times, max_cov, rate);
        for ( i in 1:n_obs_times ) 
            K_GP[i,i] += delta;  // add tiny positive value to ensure positive definite
        N = cholesky_decompose(K_GP) * eta;  // Noncentered parameterization
    }
}
model {
    // P-process priors
    r ~ beta(1.7, 2);
    K ~ normal(10, 3);
    P0 ~ normal(0, .5);

    // Measurement priors
    s1 ~ std_normal();
    a1 ~ beta(3.8, 2.5);
    b1 ~ beta(2, 1);
    c1 ~ normal(0, 2);

    a2 ~ beta(3, 3);
    s2 ~ std_normal();
    c2 ~ std_normal();

    // Compute Dynamics
    array[n_obs_times] vector[1] P = ode_rk45(
        ode,               // ODE function
        rep_vector(P0,1),  // initial states
        0.0,               // initial time
        obs_times,         // times to return ODE states 
        // rel_tol, abs_tol, max_num_steps,  // ODE integrator arguments
        r, K           // ODE Parameters
    );

    // N-process priors (see transformed parameters)
    max_cov ~ normal(0, 3);
    rate ~ normal(0, .3);
    eta ~ std_normal();

    // Measurement model
    for ( t in 1:n_obs_times ) {
        real Nt = N[t];
        P_meas[t] ~ normal( b1*(a1*P[t,1] - (1-a1)*Nt) - c1, s1 );
        N_meas[t] ~ normal( a2*Nt - c2, s2 );
    }
}
