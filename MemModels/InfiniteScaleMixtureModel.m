% INFINITESCALEMIXTURE() returns a structure for an infinite scale mixture model
% with a gamma mixing distribution. This particular flavor of the infinite scale
% mixture model assumes that the shape of the error distribution for fixed precision 
% is a wrapped normal.
%
% still in the works.

% TODO: Convert to use Memoize() instead of this way of caching

function model = InfiniteScaleMixtureModel()
	model.paramNames = {'g', 'sigma', 'df'};
	model.lowerbound = [0 0 0]; % Lower bounds for the parameters
	model.upperbound = [1 Inf Inf]; % Upper bounds for the parameters
	model.movestd = [0.02, 0.1, 0.25];
	model.pdf = @(data, g, sigma, df) ...
    (1-g).*tDistWrapped(data,0,sigma,df)' + (g).*unifpdf(data,-pi,pi);
	model.start = [0.0, 0.2, 0.2;
                   0.2, 0.3, 1.0;
                   0.4, 0.1, 2.0;
                   0.6, 0.5, 5.0];
end

function p = tDistWrapped(x, mu, sigma, df)
  persistent m;
  if isempty(m)
    m = containers.Map();
  end
  hash = DataHash(x);
  if ~m.isKey(hash)
    m(hash) = CreateFastWrappedT(x);
  end
  f = m(hash);
  p = f(mu,sigma,df);
end

function f = CreateFastWrappedT(x)
  valsRange = 100;
  addVals = (-valsRange:valsRange)' * (zeros(1,length(x))+2*pi);
  if size(x,1) > size(x,2)
    x = x';
  end
  xVals = repmat(x, [valsRange*2+1, 1]);
  combinedX = addVals+xVals;
  f = @(mu,sigma,df)(sum( ...
    (exp(gammaln((df + 1) / 2) - gammaln(df/2)) ...
    ./ (sqrt(df*pi).*(1+(((combinedX-mu)./sigma).^2)./df).^((df + 1)/2))) ...
    ./sigma, 1));
end
