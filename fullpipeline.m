% recovers parameters
%
% currently supports:
%   StandardMixtureModel
%   StandardMixtureModelWithBias
%   StandardMixtureModelWithBiasSD
%
% example usage:
%   model = StandardMixtureModelWithBias;
%   paramsIn = {0,0.1,10}; % mu, g , K
%   numTrials = round(logspace(1,4,4)); % 10, 100, 1000, and 10000 trials
%   numItems = 3;
%   [paramsOut, lowerCI, upperCI] = fullpipeline(model, paramsIn, numTrials, numItems)
%
% or just:
%   model = StandardMixtureModelWithBias;
%   [paramsOut, lowerCI, upperCI] = fullpipeline(model)
%
function [paramsOut, lowerCI, upperCI] = fullpipeline(model, paramsIn, numTrials, numItems)
    
  % generate error data using parameters from the first element in the MCMC chain
  if(nargin < 2)
    paramsIn = num2cell(model.start(1,:));
  end
  
  if(nargin < 3)
    numTrials = round(logspace(1,4,4));
  end
  
  if(nargin < 4)
    numItems = 3;
  end
      
  fprintf('\nModel: %s\n\n', model.name);
  
  fprintf('parameter\tvalue\n')
  fprintf('---------\t-----\n')
  for paramIndex = 1:length(model.paramNames)
      fprintf('%s\t\t%4.4f\n', ...
              model.paramNames{paramIndex}, ...
              model.start(1,paramIndex));
  end
  
  % generate data using the model's internal generator if it exists
  if ~isfield(model, 'pdf') % if no pdf, create one from logpdf
    model.pdf = @(varargin)(exp(model.logpdf(varargin{:})));
  end
  
  
  for i = 1:length(numTrials)
    
    % generate displays
    data.displays = generateDisplays(numTrials(i), numItems);
        
    fprintf('\nNow running pipeline with %d trials.\n', numTrials(i))
    
    data.errors = modelrnd(model, paramsIn, [numTrials(i),1]);
    
    % now try to recover the parameters
    stored = MCMC_Convergence(data, model, 'Verbosity', 0);
    fit = MCMC_Summarize(stored);
    paramsOut(i,:) = fit.posteriorMean;
    lowerCI(i,:) = fit.lowerCredible;
    upperCI(i,:) = fit.upperCredible;
  end
  
  % figure(1);
  % for i = 1:length(paramsIn)
  %   subplot(length(paramsIn), 1, i);
  %   semilogx(numTrials(1), max(paramsOut(:,i)));
  %   boundedline(numTrials,  ...
  %               paramsOut(:,i), ...
  %               [paramsOut(:,i) - lowerCI(:,i),  ...
  %                upperCI(:,i) - paramsOut(:,i)]);
  %   
  % end

end