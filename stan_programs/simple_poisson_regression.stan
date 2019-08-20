data {
  int<lower=1> N; // number of data points, which must be at least 1
  int<lower=0> complaints[N]; // array of length N of number of complaints, which can't be negatove
  vector<lower=0>[N] traps; // array (vector) of number of traps, note difference in syntax
}
parameters {
  real alpha;
  real beta;
}
transformed parameters {
  // could declare 'eta' here if we want to save it 
  // could also just remove this block if not needed
}
model {
  // could use:
  // complaints ~ poisson(exp(alpha + beta * traps))
  // BUT poisson_log(x) is more efficient and stable alternative to poisson(exp(x))
  complaints ~ poisson_log(alpha + beta * traps);
  
  // weakly informative priors:
  // we expect negative slope on traps and a positive intercept,
  // but we will allow ourselves to be wrong
  // prior parameters could also be passed in and defined in data block
  alpha ~ normal(log(7), 1);
  beta ~ normal(-0.25, 0.5);
} 
generated quantities {
  // optional, could be done back in R
  
  // predict (replicate or rep) values for input data using fitted model (in sample)
  int y_rep[N];
  for (n in 1:N) {
    // on first iterations with randomly initialised alpha and beta values likely to get
    // error messages (e.g. overflows) and/or unrealistic values. Limit eta to some
    // max value to prevent this (model does exp(eta))
    real eta = alpha + beta * traps[n];
    if (eta > 20.79) eta = 20.79;
    
    // randomly sample from poisson distribution with fitted parameters
    y_rep[n] = poisson_log_rng(eta);

  }
}
