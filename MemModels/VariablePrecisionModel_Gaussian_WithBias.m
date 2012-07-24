% VariablePrecisionModel_Gaussian_WithBias() returns a structure for a  
% variable precision mixture model, in which the standard deviations of 
% observers' reports are assumed to be themselves distributed as a normal 
% distribution.
function model = VariablePrecisionModel_Gaussian_WithBias()
  model.name = 'Variable precision model (gaussian over sd) with bias';
	model.paramNames = {'g', 'mu', 'mnSTD', 'stdSTD'};
	model.lowerbound = [0 -180 0 0]; % Lower bounds for the parameters
	model.upperbound = [1 180 100 100]; % Upper bounds for the parameters
	model.movestd = [0.02, 0.25, 0.25, 0.15];
	model.pdf = @vp_pdf;
  model.modelPlot = @model_plot;
	model.start = [0.0, 0.0, 30, 10;
                   0.2, 5.0, 10, 5];
  
  % For speed, calculate these all out here
  stdsSumOver = linspace(0.5, 100, 500); 
  kValues = deg2k(stdsSumOver)';
  baseK = log(besseli(0, kValues, 1)) + kValues;
  lastX = [];
  
  function y = vp_pdf(data,g,mu,mnSTD,stdSTD)
    % Probability of each of these
    probEachSD = normpdf(stdsSumOver, mnSTD, stdSTD);
    probEachSD = probEachSD./sum(probEachSD);
    
    if length(data.errors)~=length(lastX) || any(data.errors~=lastX)
      % Calculate pdf for each STD; only do if the data is different than
      % last time
      model.x = repmat(data.errors(:), [1 length(kValues)]);
      model.k = repmat(kValues', [length(data.errors) 1]);
      model.newBaseK = repmat(baseK', [length(data.errors) 1]);
      lastX = data.errors;
    end
    
    % Make final model prediction and sum
    v = exp((model.k.*cos((pi/180)*(model.x-mu))) - (log(360) + model.newBaseK));
    probDataUnderThisNormal = (1-g).*v + (g).*1/360;
    probEachSDBig = repmat(probEachSD, [size(probDataUnderThisNormal,1), 1]);
    y = sum(probDataUnderThisNormal.*probEachSDBig,2);
  end
  
  % Just call the version with no bias
  function figHand = model_plot(data, params, varargin)
    subModel = VariablePrecisionModel_Gaussian();
    figHand = subModel.modelPlot(data, params, varargin);
  end
end