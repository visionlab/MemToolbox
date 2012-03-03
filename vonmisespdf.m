function l = vonmisespdf(x,mu,k) 
% Computations done in log space to allow much larger k's without
% overflowing
	l = (exp( (k.*cos(x-mu)) - (log(2*pi) + log(besseli(0, k, 1)) + k)));
end