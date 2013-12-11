function y = wrappednormpdf(x, mu, sigma, varargin)
%WRAPPEDNORMPDF Wrapped normal probability density function (pdf).
%   y = normpdf(X, MU, SIGMA) returns the pdf of the wrapped normal
%   distribution with mean MU and standard deviation SIGMA, evaluated
%   at the values in X.

if nargin < 1
	error('MemToolbox:wrappednormpdf:TooFewInputs', 'Input argument X is undefined.');
end

if nargin < 2
	mu = 0;
end
if nargin < 3
	sigma = 1;
end

% return NaN for out of range parameters
sigma(sigma <= 0) = NaN;

y = zeros(size(x)); % preallocate output vector

% if user doesn't specify a number of wraps, default to 100
if(length(varargin) > 0)
	nWraps = varargin{:};
else
	nWraps = 100;
end

% do the actual work of wrapping
for i = 1:length(x)
	xfork = (x(i)-nWraps*2*pi):(2*pi):(x(i)+nWraps*2*pi);
	y(i) = sum(normpdf(xfork, mu, sigma));
end
