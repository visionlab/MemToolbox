% VARIABLEPRECISIONMODEL_TDIST_WITHBIAS an infinite scale mixture model with a gamma mixing distribution.
% This particular flavor of the infinite scale mixture model assumes that 
% the shape of the error distribution for fixed precision 
% is a wrapped normal.
%

% XXX : It seems like it would be ideal if we could reparameterize this
% model, so rather than using df and sigma, it uses the scale and shape of
% the gamma instead
%    prec = 1/(params(2)*params(2));
%    df = params(3);
%
%    shape = df/2;
%    scale = df/(2*prec);
%
% Not sure if sampling would work as well, but I suspect it would be fine.
%

function model = VariablePrecisionModel_TDist_WithBias()
  model.name = 'Variable precision model with bias';
	model.paramNames = {'mu', 'g', 'sigma', 'df'};
	model.lowerbound = [-180 0 0 0]; % Lower bounds for the parameters
	model.upperbound = [180 1 Inf 100]; % Upper bounds for the parameters
	model.movestd = [0.5, 0.02, 0.5, 0.05];
	model.pdf = @(data, mu, g, sigma, df) ...
    (1-g).*tDistWrapped(data.errors,mu,sigma,df)' + ...
      (g).*unifpdf(data.errors(:),-180,180);
	model.start = [3,  0.1, 10, 0.2;
                -3,  0.3, 30, 3.0];
  model.generator = @VariablePrecisionWithBiasGenerator;
end

% To sample from it
function allT = VariablePrecisionWithBiasGenerator(parameters, dims, displayInfo)
  n = prod(dims);
  allT = parameters{3}*trnd(parameters{4},n,1)+parameters{1};
  allT = mod(allT+180, 360)-180;
  guesses = logical(rand(n,1) < parameters{2}); % figure out which ones will be guesses
  allT(guesses) = rand(sum(guesses),1)*360 - 180;
  allT = reshape(allT, dims); % reshape to requested dimensions
end

% Wrapper function to make everything faster if we get called with the same
% data over and over
function p = tDistWrapped(x, mu, sigma, df)
  persistent lastX f;
  if isempty(lastX) || (length(lastX) ~= length(x)) || any(x~=lastX)
    f = CreateFastWrappedT(x);
    lastX = x;
  end
  p = f(mu,sigma,df);
end

% Fast wrapped t (precomputed for a particular set of x)
function f = CreateFastWrappedT(x)
  valsRange = 100; % how many times to wrap around the circle
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


