% VariablePrecisionWithBiasModel() - an infinite scale mixture model
% with a gamma mixing distribution. This particular flavor of the infinite scale
% mixture model assumes that the shape of the error distribution for fixed precision 
% is a wrapped normal.
%

function model = VariablePrecisionWithBiasModel()
  model.name = 'Variable precision model with bias';
	model.paramNames = {'mu', 'g', 'sigma', 'df'};
	model.lowerbound = [-180 0 0 0]; % Lower bounds for the parameters
	model.upperbound = [180 1 Inf Inf]; % Upper bounds for the parameters
	model.movestd = [1, 0.02, 1, 0.25];
	model.pdf = @(data, mu, g, sigma, df) ...
    (1-g).*tDistWrapped(data.errors,mu,sigma,df)' + ...
      (g).*unifpdf(data.errors(:),-180,180);
	model.start = [1,  0.0, 20, 0.2;
                  -1,  0.2, 30, 1.0;
                   5, 0.4, 10, 2.0;
                  -5, 0.6, 50, 5.0];
  model.generator = @VariablePrecisionWithBiasGenerator;
end

% XXXX may not work right, check!!
function allT = VariablePrecisionWithBiasGenerator(parameters, dims)
  n = prod(dims);
  allT = parameters{3}*trnd(parameters{4},n,1)+parameters{1};
  allT = mod(allT+pi, 360)-180;
  guesses = logical(rand(n,1) < parameters{2}); % figure out which ones will be guesses
  allT(guesses) = rand(sum(guesses),1)*360 - 180;
  allT = reshape(allT, dims); % reshape to requested dimensions
end

% Wrapper function
function p = tDistWrapped(x, mu, sigma, df)
  persistent m;
  if isempty(m)
    m = containers.Map();
  end
  hash = datahash(x);
  if ~m.isKey(hash)
    m(hash) = CreateFastWrappedT(x);
  end
  f = m(hash);
  p = f(mu,sigma,df);
end

% Fast wrapped t (precomputed for a particular set of x)
function f = CreateFastWrappedT(x)
  valsRange = 30; % how many times to wrap around the circle
  addVals = (-valsRange:valsRange)' * (zeros(1,length(x))+360);
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
