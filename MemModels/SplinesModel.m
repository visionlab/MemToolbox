function model = SplinesModel()
  model.name = 'Splines model';
  model.knotX = [0:3:33 40 50 75 100 150 300 360] ./ 180 .* pi;
  model.stdX = linspace(0.05,max(model.knotX),100);
  model.paramNames = repmat({'knot'}, size(model.knotX));
  model.lowerbound = zeros(size(model.knotX)); % Lower bounds for the parameters
  model.upperbound = inf(size(model.knotX)); % Upper bounds for the parameters
  model.movestd = repmat(0.01, size(model.knotX));
  
  model.pdf = @(d,varargin)(PrecisionModelFast(d, model.knotX, model.stdX, cell2mat(varargin)));
  model.start = [rand(size(model.knotX)).*linspace(1,0,length(model.knotX)); ...
    rand(size(model.knotX)).*linspace(1,0,length(model.knotX)); ...
    rand(size(model.knotX)).*linspace(1,0,length(model.knotX)); ...
    rand(size(model.knotX)).*linspace(1,0,length(model.knotX))];
  
  % Prior on knot locations and smoothness
  [knotMu, knotSigma] = GetPrior(length(model.knotX), 0.2, 0.1);   
  
  model.prior = @(params) mvnpdf(params, knotMu, knotSigma);
end

%-------------------------------------------------------------------------
function [knotMu,knotSigma] = GetPrior(knots, knotStd, knotSmooth)
  knotMu  = zeros(1,knots); % Knots want to be near 0
  knotSigma = zeros(knots, knots);
  for i=1:knots
    knotSigma(i,i) = knotStd;
    knotSigma(i+1,i) = knotSmooth;
    knotSigma(i,i+1) = knotSmooth;
  end
  knotSigma = knotSigma(1:knots, 1:knots);
end

%-------------------------------------------------------------------------
function p = PrecisionModelFast(data, knotX, X, curSplineVals)
  % Cache wrapped normal distributions for this x parameter
  persistent SDs cachedX;
  if isempty(SDs) || ~strcmp(DataHash(data), cachedX)
    for i=1:length(X)
      SDs{i} = WrappedNormal(data, 0, X(i));
    end
    cachedX = DataHash(data);
  end
  
  % Higher-order likelihood function
  precisionDist = interp1(knotX, curSplineVals, X, 'pchip');
  precisionDist = precisionDist ./ sum(precisionDist(:));
  
  p = zeros(size(data));
  for i=1:length(precisionDist)
    p = p + precisionDist(i) * SDs{i};
  end
end

%-------------------------------------------------------------------------
function p = WrappedNormal(x, m, s)
  % Wraps at 360
  n = 1./sqrt(2*pi.*s.*s);
  sm = 0;
  for j=-20:20 % sum from infinity to -infinity; larger sum = better approx.
    sm = sm + exp((-(x-m-(2*pi*j)).^2)./(2.*s.*s));
  end
  p = n*sm;
end
