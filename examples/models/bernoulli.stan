data {
  int<lower=0> N;
  array[N] int<lower=0,upper=1> y; // or int<lower=0,upper=1> y[N];
}
parameters {
  real<lower=0,upper=1> theta;
}
model {
  theta ~ beta(1,1);  // uniform prior on interval 0,1
  y ~ bernoulli(theta);
}
generated quantities {
  real<lower=0, upper=1> theta_rep;
  array[N] int y_sim;
  // use current estimate of theta to generate new sample
  for (n in 1:N) {
    y_sim[n] = bernoulli_rng(theta);
  }
  // estimate theta_rep from new sample
  theta_rep = sum(y_sim) * 1.0 / N;
}
