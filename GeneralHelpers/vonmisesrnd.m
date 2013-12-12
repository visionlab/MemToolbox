function thetas = vonmisesrnd(mu, kappa, varargin)
%VONMISESRND Random arrays from the von Mises distribution
% theta = vonmisesrnd(mu, kappa, n) returns an n-by-n matrix containing pseudorandom
% values drawn from a von Mises distribution with mean mu and spread kappa. Similarly,
% vonmisesrnd(mu, kappa, [M,N,P]) returns and M-by-N-by-P-by-... array.
%
% References:
%	[1] Best, D.J. & Fisher, N.I. (1979). Efficient simulation of the von Mises distribution.
% 		Journal of the Royal Statistical Society Series C, 28(2), 152-157.
%

% check dimensions
if(length(varargin) < 1)
	dims = [1,1];
elseif(length(varargin) == 1)
	dims = varargin{:};
else
	error('memToolbox:vonMisesRnd:tooManyDims','Too many dimension arguments specified.');
end

% if only one dimension n is given, return an n x n matrix, like randn does.
if(length(dims) == 1)
	dims = [dims, dims];
end

n = prod(dims);

% if kappa is 0, draw from uniform
if(kappa == 0)
	thetas = reshape((rand(n,1)*2-1)*180, dims);
	return;
end

% set up constants using kappa
tau = 1 + (1 + 4*(kappa^2))^0.5;
rho = (tau - (2*tau)^0.5)/(2*kappa);
r = (1+rho^2)/(2*rho);

% preallocate arrays
f = zeros(n,1);
c = zeros(n,1);

pass = false(n,1);
while(~all(pass));

	% generate new random numbers for each sample that has not yet passed
	u = rand([sum(~pass), 2]);
	cosd(180*u(:, 1));

	f(~pass) = (1 + r.*cosd(180.*u(:,1)))./(r+cosd(180.*u(:,1)));
	c(~pass) = kappa.*(r-f(~pass));

	% check if the new samples pass
	conditionOne = c(~pass).*(2-c(~pass))-u(:,2) > 0;
	conditionTwo = log(c(~pass)./u(:,2))+1-c(~pass) >= 0;
	pass(~pass) = conditionOne | conditionTwo;
end

thetas = reshape(mod(mu + 180 + sign(rand(n,1)-0.5).*acosd(f),360) - 180, dims);
