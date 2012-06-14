function y = wrappedtpdf(x, mu, sigma, df, nWraps)
	if (nargin < 5) nWraps = 200; end
	n = prod(size(x));
	range = (-nWraps:nWraps);
	add = range(ones(n,1), :)'.*2*pi;
	x2 = repmat(x(:)', nWraps*2+1, 1);
	a = tlspdf(x2+add, mu, sigma, df);
	y = reshape(sum(a,1),size(x));
end

% function y = wrappedtpdf(x, mu, sigma, df, w)
% 	
% 	if (nargin < 5) w = 200; end
% 	
% 	n = prod(size(x));
% 	y = zeros(n,1); % preallocate
% 	tau = 2*pi;
% 	
% 	for i = 1:n
% 		y(i) = sum(tpdf(([(x(i) - w*tau : tau : x(i) + w*tau)] - mu)./sigma, df));
% 	end
% 	y = reshape(y, size(x));

% function p = wrappedtpdf(x, mu, sigma, df)
%     valsRange = 200;
%     add = (-valsRange:valsRange)' * (zeros(1,length(x))+2*pi);
%     x = repmat(x', [valsRange*2+1, 1])
%     a = tlspdf(x+add,mu,sigma,df);
%     p = sum(a,1);
% end
% 
% % ------------------------------------------------------------------------
% % From Wikipedia:
% % This distribution results from compounding a Gaussian distribution with 
% % mean mu and unknown precision (the reciprocal of the variance), with a 
% % gamma distribution with parameters a = df / 2 and b = df / 2*prec. In other 
% % words, the random variable X is assumed to have a normal distribution
% % with an unknown precision distributed as gamma, and then this is 
% % marginalized over the gamma distribution. (The reason for the usefulness
% % of this characterization is that the gamma distribution is the conjugate
% % prior distribution of the precision of a Gaussian distribution. As a 
% % result, the three-parameter Student's t distribution arises naturally 
% % in many Bayesian inference problems.)
function y = tlspdf(x, mu, sigma, df)
     y = tpdf((x - mu)./sigma,df)./sigma;
end

