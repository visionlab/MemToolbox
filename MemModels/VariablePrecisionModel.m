% VariablePrecisionModel() returns a structure for an infinite scale mixture model
% with a gamma mixing distribution. This particular flavor of the infinite scale
% mixture model assumes that the shape of the error distribution for fixed precision 
% is a wrapped normal.

function model = VariablePrecisionModel()
  model.name = 'Variable Precision Model';
	model.paramNames = {'g', 'sigma', 'df'};
	model.lowerbound = [0 0 0]; % Lower bounds for the parameters
	model.upperbound = [1 Inf Inf]; % Upper bounds for the parameters
	model.movestd = [0.02, 0.1, 0.25];
	model.pdf = @ismpdf;
	model.start = [0.0, 0.2, 0.2;
                   0.2, 0.3, 1.0;
                   0.4, 0.1, 2.0;
                   0.6, 0.5, 5.0];
  model.generator = @ismgen;
end

% To sample from this model
function r = ismgen(params, dims)
  paramsNew = {0, params{1}, params{2}, params{3}};
  model = VariablePrecisionWithBiasModel();
  r = model.generator(paramsNew, dims);
end
  
% call the student's t with bias, mu=0
function y = ismpdf(data,g,sigma,df)
    model = VariablePrecisionWithBiasModel();
    y = model.pdf(data, 0, g, sigma, df);
end