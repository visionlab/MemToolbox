% EXPONENTIALDECAYMODEL returns a struct for a model where objects drop out
% of memory indepdendently at a constant rate over time, somewhat like the
% model proposed by Zhang & Luck (2009), though without an initial period of
% stability. (This is a pure death process over objects.)
%
% Parameters: tau, K, sd
%   Tau is the mean lifetime of an object (in ms), K is the capacity of
%   working memory, and sd is the precision with which items are remembered.
%
% In addition to data.errors, requires data.n (the set size for each trial)
% as well as data.time (the delay before test in each trial; in milliseconds).
%
function model = ExponentialDecayModel()
  model.name = 'Exponential decay model';
	model.paramNames = {'tau', 'K', 'sd'};
	model.lowerbound = [0 0 0]; % Lower bounds for the parameters
	model.upperbound = [Inf Inf Inf]; % Upper bounds for the parameters
	model.movestd = [20, 1, 1];
	model.pdf = @sdpdf;

	model.start = [1000, 4, 12;  % tau, k, sd
                 2000, 2, 20;
                 10000, 6, 30];

  % To specify a prior probability distribution, change and uncomment
  % the following line, where p is a vector of parameter values, arranged
  % in the same order that they appear in model.paramNames:
  % model.prior = @(p) (1);
end

function y = sdpdf(data, tau, k, sd)
  B = min(k, data.n); % maximum contribution of working memory

  % the probability of remembering is exponential in time
  p = B.*exp(data.time/-tau) ./ data.n;
  g = 1 - p; % the guess rate

  y = ((1-g(:)).*vonmisespdf(data.errors(:),0,deg2k(sd)) + ...
          (g(:).*unifpdf(data.errors(:),-180,180)));
end

