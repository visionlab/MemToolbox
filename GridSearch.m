function [logLikeMatrix, valuesUsed] = GridSearch(data, model, mleParams, nPointsPerParam)
  % Use MLE parameters to center the grid search if any parameters have Inf
  % upper or lowerbound
  if (any(isinf(model.upperbound)) || any(isinf(model.lowerbound))) && nargin<3
    mleParams = MLE(data, model);
  end
  
  % Number of parameters
  Nparams = length(model.paramNames);
  
  % Default to 5000 total points
  if nargin<4
    nPointsPerParam = round(nthroot(5000,Nparams));
  end
  
  % Figure out what values to search
  which = linspace(0,1,nPointsPerParam);
  for i=1:Nparams
    if ~isinf(model.upperbound(i))
      MappingFunction{i} = @(percent) (model.lowerbound(i) ...
        + (model.upperbound(i)-model.lowerbound(i))*percent);
    else
      if isinf(model.lowerbound(i))
        error('Can''t have lower and upperbound of a parameter be Inf');
      else
        MappingFunction{i} = @(percent) (-log(1-(percent./1.01))*mleParams(i)*2);
      end
    end
    valuesUsed{i} = MappingFunction{i}(which);
  end
  
  % Convert to full factorial
  [allVals{1:Nparams}] = ndgrid(valuesUsed{:});
  
  % Evaluate
  logLikeMatrix = zeros(size(allVals{1}));
  parfor i=1:numel(allVals{1})
    curParams = num2cell(cellfun(@(x)x(i), allVals));
    logLikeMatrix(i) = sum(log(model.pdf(data, curParams{:})));
  end
end
