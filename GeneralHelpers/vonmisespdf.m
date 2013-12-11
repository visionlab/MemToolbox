function y = vonmisespdf(x,mu,k)
  % y = vonmisespdf(x,mu,k)
  % Generate a probability distribution function over the values x of a von
  % mises distribution with mean (mu) and spread kappa (k) parameters.
  %
  % Computations done in log space to allow much larger k's without overflowing
	y = (exp( (k.*cos((pi/180).*(x-mu))) - (log(360) + log(besseli(0, k, 1)) + k)));
end
