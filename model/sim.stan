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
}
data {
    // Data
    int n_days;
    int n_obs_times;  // number of time points with observations
    array[n_obs_times] real<lower=0,upper=n_days> obs_times;  // times with observations
    real<lower=0> K;  // Carrying capacity

    // Parameters (to infer later)
    real<lower=0> P0;       // Initial condition 
    real<lower=0> r;        // P-process growth rate
    vector[n_obs_times] N;  // N-process (simulated in R)
    
    // Measurement params
    real<lower=0> a1;
    real<lower=0> b1;   // scaling factor (b/t 0 & 1)
    real<lower=0> c1;
    real<lower=0> s1;
    
    real<lower=0> a2;
    real c2;
    real<lower=0> s2;
}
generated quantities {
    // Simulated variables
    vector[n_obs_times] P_meas;
    vector[n_obs_times] N_meas;
    vector[n_obs_times] M1;
    vector[n_obs_times] M2;

    // Compute Dynamics
    array[n_obs_times] vector[1] P = ode_rk45(
        ode,               // ODE function
        rep_vector(P0,1),  // initial states
        0.0,               // initial time
        obs_times,         // times to return ODE states 
        // rel_tol, abs_tol, max_num_steps,  // ODE integrator arguments
        r, K           // ODE Parameters
    );

    // Measurement model
    for ( t in 1:n_obs_times ) {
        M1[t] = b1*(a1*P[t,1] - (1-a1)*N[t]) - c1;
        M2[t] = a2*N[t] - c2;
        P_meas[t] = normal_rng( M1[t], s1 );
        N_meas[t] = normal_rng( M2[t], s2 );
    }
}
