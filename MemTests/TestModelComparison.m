% TESTMODELCOMPARISON sample from a model and then attempt to recover this model
%
%  [successAIC, successBIC, successAICc] = ...
%      TestModelComparison(trueModel, foilModels, paramsIn, ...
%                      numTrials, numItems, [optionalParameters])
%
%  successAIC/BIC/AICc are the percentage of time that the respective model
%  comparison metric correctly selected the true model as opposed to one of
%  the foil models.
%
% Example usage:
%   model = StandardMixtureModel();
%   foilModels = {SwapModel(), ...
%                 StandardMixtureModel('Bias', true)};
%   TestModelComparison(model, foilModels);
%
% You can also specify the parameters of the fits: e.g.,
%
%   paramsIn = {0.1, 10}; % g, SD
%   numTrials = [500 1000];
%   numItems = 3; % Set size of displays to simulate
%   TestModelComparison(model, foilModels, paramsIn, numTrials, numItems)
%
% Takes optional parameter 'Verbosity'. 1 (default) print information about
% the model comparison process.
%
function [successAIC, successBIC, successAICc] = ...
    TestModelComparison(trueModel, foilModels, paramsIn, ...
    numTrials, numItems, varargin)

  % Optional parameters
  args = struct('Verbosity', 1);
  args = parseargs(varargin, args);

  % Generate error data using parameters from the initial start position of
  % the model
  if(nargin < 3)
    paramsIn = num2cell(trueModel.start(1,:));
  end

  % Use 10, 100, 1000 and 3000 trials
  if(nargin < 4)
    numTrials = [10 100 1000 3000];
  end

  % Simulate displays with 3 items on them
  if(nargin < 5)
    numItems = 3;
  end

  if args.Verbosity > 0
    % Print model and parameters being simulated:
    fprintf('\nTrue model: %s\n\n', trueModel.name);
    fprintf('parameter\tvalue\n')
    fprintf('---------\t-----\n')
    for paramIndex = 1:length(trueModel.paramNames)
      fprintf('%s\t\t%4.4f\n', ...
        trueModel.paramNames{paramIndex}, ...
        paramsIn{paramIndex});
    end
    fprintf('\nFoil models:\n');
    for i=1:length(foilModels)
      fprintf('\t%s\n', foilModels{i}.name);
    end
  end

  for i = 1:length(numTrials)
    if args.Verbosity > 0
      fprintf('\nTrying with %d trials.\n', numTrials(i))
    end
    parfor j=1:30
      % Generate displays
      displays = GenerateDisplays(numTrials(i), numItems);

      % Generate error data for these displays:
      data = displays;
      data.errors = SampleFromModel(trueModel, paramsIn, [numTrials(i),1], displays);

      % Now try to recover the parameters that led to these errors:
      [aic,bic,loglike,aicc] = ModelComparison_AIC_BIC(data, {trueModel, foilModels{:}});
      successAIC(i,j) = argmin(aic)==1;
      successAICc(i,j) = argmin(aicc)==1;
      successBIC(i,j) = argmin(bic)==1;
    end
    if args.Verbosity > 0
      fprintf('  AIC success rate:  %0.1f%%\n', mean(successAIC(i,:))*100);
      fprintf('  AICc success rate: %0.1f%%\n', mean(successAICc(i,:))*100);
      fprintf('  BIC success rate:  %0.1f%%\n', mean(successBIC(i,:))*100);
    end
  end
end

function b = argmin(v)
  [tmp, b] = min(v);
end

