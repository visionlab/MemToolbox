% TestSamplingAndFitting - sample from a model and then attempt to recovers
% parameters
%
% Example usage:
%   model = StandardMixtureModelWithBias();
%   paramsIn = {0,0.1,10}; % mu, g , K
%   numTrials = round(logspace(1,4,4)); % 10, 100, 1000, and 10000 trials
%   numItems = 3; % set size of displays to simulate
%   [paramsOut, lowerCI, upperCI] = TestSamplingAndFitting(model, paramsIn, numTrials, numItems)
%
% or just:
%   model = StandardMixtureModelWithBias();
%   [paramsOut, lowerCI, upperCI] = TestSamplingAndFitting(model)
%
% Takes optional parameter 'Verbosity'. 1 (default) print information about
% the fitting process. 2 also makes a plot of the credible interval and
% fit for each parameter at the end.
%
function [paramsOut, lowerCI, upperCI] = ...
    TestSamplingAndFitting(model, paramsIn, numTrials, numItems, varargin)
  
  % Optional parameters
  args = struct('Verbosity', 1); 
  args = parseargs(varargin, args);
  
  % Generate error data using parameters from the initial start position of
  % the model
  if(nargin < 2)
    paramsIn = num2cell(model.start(1,:));
  end
  
  % Use 10, 100, 1000, and 10,000 trials
  if(nargin < 3)
    numTrials = round(logspace(1,4,4));
  end
  
  % Simulate displays with 3 items on them
  if(nargin < 4)
    numItems = 3;
  end
  
  if args.Verbosity > 0
    % Print model and parameters being simulated:
    fprintf('\nModel: %s\n\n', model.name);
    fprintf('parameter\tvalue\n')
    fprintf('---------\t-----\n')
    for paramIndex = 1:length(model.paramNames)
      fprintf('%s\t\t%4.4f\n', ...
        model.paramNames{paramIndex}, ...
        paramsIn{paramIndex});
    end
  end
  
  for i = 1:length(numTrials)
    if args.Verbosity > 0
      fprintf('\nNow running pipeline with %d trials.', numTrials(i))
    end
    
    % Generate displays
    displays = GenerateDisplays(numTrials(i), numItems);

    % Generate error data for these displays:
    data = displays;
    data.errors = SampleFromModel(model, paramsIn, [numTrials(i),1], displays);
    
    % Now try to recover the parameters that led to these errors:
    posteriorSamples = MCMC(data, model, 'Verbosity', 0);
    fit = MCMCSummarize(posteriorSamples);
    paramsOut(i,:) = fit.posteriorMean;
    lowerCI(i,:) = fit.lowerCredible;
    upperCI(i,:) = fit.upperCredible;
  end
  
  if args.Verbosity > 1
    % Make plot:
    figure;
    for i = 1:length(paramsIn)
      subplot(length(paramsIn), 1, i);
      semilogx(numTrials(1), max(paramsOut(:,i)));
      boundedline(numTrials,  ...
        paramsOut(:,i), ...
        [paramsOut(:,i) - lowerCI(:,i),  ...
        upperCI(:,i) - paramsOut(:,i)]);
      line([numTrials(1), numTrials(end)], [paramsIn{i} paramsIn{i}], ...
        'LineStyle', '--', 'Color', 'r');
      title(model.paramNames{i});
    end
  end
end

