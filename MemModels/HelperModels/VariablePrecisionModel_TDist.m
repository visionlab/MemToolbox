% VARIABLEPRECISIONMODEL_TDIST returns a structure for an infinite scale mixture model
% with a gamma mixing distribution. This particular flavor of the infinite scale
% mixture model assumes that the shape of the error distribution for fixed precision
% is a wrapped normal.

function model = VariablePrecisionModel_TDist()
  model.name = 'Variable precision model';
	model.paramNames = {'g', 'sigma', 'df'};
	model.lowerbound = [0 0 0]; % Lower bounds for the parameters
	model.upperbound = [1 Inf 100]; % Upper bounds for the parameters
	model.movestd = [0.05, 1, 0.5];
	model.pdf = @ismpdf;
	model.start = [0.0, 0.2, 0.2;
                   0.2, 0.3, 1.0;
                   0.4, 0.1, 2.0;
                   0.6, 0.5, 5.0];
  model.generator = @ismgen;

  % To specify a prior probability distribution, change and uncomment
  % the following line, where p is a vector of parameter values, arranged
  % in the same order that they appear in model.paramNames:
  % model.prior = @(p) (1);

end

% To sample from this model
function r = ismgen(params, dims, displayInfo)
  paramsNew = {0, params{1}, params{2}, params{3}};
  model = VariablePrecisionModel_TDist_WithBias();
  r = model.generator(paramsNew, dims);
end

% call the student's t with bias, mu=0
function y = ismpdf(data,g,sigma,df)
    model = VariablePrecisionModel_TDist_WithBias();
    y = model.pdf(data, 0, g, sigma, df);
end
