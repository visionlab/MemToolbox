function y = wrappedtpdf(x, mu, sigma, df, nWraps)
    if (nargin < 5)
        nWraps = 200;
    end
	range = (-nWraps:nWraps);
	add = range(ones(numel(x), 1), :)'.*2*pi;
	x2 = repmat(x(:)', nWraps*2+1, 1);
	a = tlspdf(x2+add, mu, sigma, df);
	y = reshape(sum(a, 1), size(x));
end

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
    y = tpdf((x - mu)./sigma, df)./sigma;
end

