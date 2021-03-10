// The input data.
data {
  int<lower=0> N;   // number of observations
  int<lower=0> C;   // number of covariates
  int<lower=0> K;   // number of patterns
  matrix[N, C] x;   // covariate matrix
  vector[N] y;      // outcome vector
  
  matrix<lower=0>[N,K] ewa;    // mu for patterns
  matrix<lower=0>[N,K] sd_ewa; // std dev for patterns
}

// The parameters accepted by the model.
parameters {
  real alpha;              // intercept
  real<lower=0> sigma;     // error scale
  
  vector[C] beta_c;        // coefficients for covariates
  
  vector[K] beta_p;        // coefficients for patterns
  matrix<lower=0>[N,K] WA; // pattern score with uncertainty
}

// The model to be estimated.
//  With no prior in the model block, the effect is an improper prior on all real numbers. 
model {
  // sigma ~ inv_gamma(0.001, 0.001); // prior on error
  // Cite: stat.columbia.edu/~gelman/research/published/taumain.pdf
  alpha ~ normal(100, 15); // prior on alpha = IQ

  // beta coefficient priors
  // student t parameters: degrees of freedom nu, location mu, and scale sigma
  // smaller nu, fatter tails
  // beta_c ~ normal(0,5); // student_t(1, 0, 2.5);
  //  beta_p ~ normal(0,5); // student_t(1, 0, 2.5);
  
  for (n in 1:N) { // prior on data
    for (k in 1:K) {
      WA[n,k] ~ normal(ewa[n,k], sd_ewa[n,k]);
    }}
  
  y ~ normal(((WA * beta_p) + (x * beta_c) + alpha), sigma);  // likelihood

}

// to get predicted values
generated quantities {
  real y_tilde[N] = normal_rng(((WA * beta_p) + (x * beta_c) + alpha), sigma);
}



