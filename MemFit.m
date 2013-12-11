% MemFit - A general-purpose fitting tool from the MemToolbox
%
%   Usage example:
%     data = MemDataset(1);
%     fit = MemFit(data);
%
%   It can handle many different use cases, including:
%
%     MemFit(data)
%     MemFit(errors)
%     MemFit(data, model)
%     MemFit(model, data)
%     MemFit(errors, model)
%     MemFit(model, errors)
%     MemFit(data, {model1, model2, model3, ...})
%     MemFit({subj1data,subj2data,...}, model)
%
%   All of the 2-argument versions can take an optional parameter, 'Verbosity',
%   which controls the amount of text printed to the command window.
%   If Verbosity is 0, output is suppressed. If Verbosity is 1, output is
%   minimal. If Verbosity is 2, then MemFit is verbose. The default is 2.
%   e.g.,
%      MemFit(model, data, 'Verbosity', 0)
%   runs MemFit in silent mode, with no output.
%
%   Fitting multiple subjects at once, as in MemFit({subj1data,subj2data,...},
%   model), has two modes of operation. The default is to fit the data independently
%   for each subject, as though you had run MemFit separately for each dataset.
%   Alternatively, MemFit supports fitting a hierarchical model (see the paper and
%   tutorial for more), that treats each subjects' parameters as having been sampled
%   from a single normal distribution and fits all of the parameters jointly.
%   To fit subjects hierarchically, you can call MemFit with the optional parameter
%   'UseHierarchical' set to true.
%
%-----------------------------
function fit = MemFit(varargin)
  % This function (MemFit) just dispatches the real work to the functions
  % below:
  %
  %    MemFit_SingleData(data,model), which fits the model to the data
  %    MemFit_MultipleSubjects({data1,data2,...}, model), which fits to
  %       multiple subject at once
  %    MemFit_ModelComparison(data, {model1,model2,...}), which performs
  %       model comparison
  %
  % If you want to see how MemFit() works, you should look at those
  % functions, located below this one.

  % Verbosity controls the amount of output. If verbosity is 0, output is
  % suppressed completely. If verbosity is 1, output is minimal. If verbosity
  % is 2, then it's verbose. Here, check for verbosity and then chop it off.
  if nargin > 2
    args = struct('Verbosity', 2, 'UseHierarchical', false);
    args = parseargs(varargin, args);
    verbosity = args.Verbosity;
    hierarchy = args.UseHierarchical;
    nArguments = 2;
  else
    verbosity = 2;
    hierarchy = false;
    nArguments = nargin;
  end

  if nArguments < 1
    % No arguments - just open the tutorial
    fprintf('\nOpening the tutorial using your default PDF viewer...\n\n');
    open('tutorial.pdf');

  elseif nArguments == 1
    % One input argument, assumed to be (errors) or (data).
    if(isnumeric(varargin{1}))
      data = struct('errors', varargin{1});
      fit = MemFit(data, StandardMixtureModel(), 'Verbosity', 1);

    elseif(isfield(varargin{1}, 'afcCorrect'))
      warning('MemToolbox:MemFit:InputFormat', ...
        'It looks like you passed in 2AFC data. Trying to fit with TwoAFC(StandardMixtureModel()).');
      fit = MemFit_SingleData(varargin{1}, TwoAFC(StandardMixtureModel()), 2);

    elseif(any(isfield(varargin{1}, {'errors','error'})))
      data = varargin{1};
      fit = MemFit(data, StandardMixtureModel(), 'Verbosity', 1);

    elseif(isCellArrayOfDataStructs(varargin{1}))
      data = varargin{1};
      fit = MemFit(data, StandardMixtureModel(), 'Verbosity', 1);

    else
      error('MemToolbox:MemFit:InputFormat', 'Input format is wrong.');
    end

  elseif nArguments == 2

    % Two input arguments, so many possibilities...
    if(isnumeric(varargin{1}) && isModelStruct(varargin{2}))
      % (errors, model)
      data = struct('errors', varargin{1});
      model = varargin{2};
      fit = MemFit_SingleData(data, model, verbosity);

    elseif(isModelStruct(varargin{1}) && isnumeric(varargin{2}))
      % (model, errors)
      data = struct('errors', varargin{2});
      model = varargin{1};
      fit = MemFit_SingleData(data, model, verbosity);

    elseif(isModelStruct(varargin{1}) && isDataStruct(varargin{2}))
      % (model, data)
      data = ValidateData(varargin{2});
      model = varargin{1};
      fit = MemFit_SingleData(data, model, verbosity);

    elseif(isDataStruct(varargin{1}) && isModelStruct(varargin{2}))
      % (data, model) - preferred format
      data = ValidateData(varargin{1});
      model = varargin{2};
      fit = MemFit_SingleData(data, model, verbosity);

    elseif(isnumeric(varargin{1}) && isCellArrayOfModelStructs(varargin{2}))
      % (errors, {model1,model2,model3,...})
      data = ValidateData(struct('errors', varargin{1}));
      models = varargin{2};
      fit = MemFit_ModelComparison(data, models, verbosity);

    elseif(isDataStruct(varargin{1}) && isCellArrayOfModelStructs(varargin{2}))
      % (data, {model1,model2,model3,...})
      data = ValidateData(varargin{1});
      models = varargin{2};
      fit = MemFit_ModelComparison(data, models, verbosity);

    elseif(isCellArrayOfDataStructs(varargin{1}) && isModelStruct(varargin{2}))
      % ({data1,data2,data3,...}, model)
      dataCellArray = varargin{1};
      model = varargin{2};
      for i = 1:length(dataCellArray)
        dataCellArray{i} = ValidateData(dataCellArray{i});
      end
      fit = MemFit_MultipleSubjects(dataCellArray, model, verbosity, hierarchy);

    else
      error('MemToolbox:MemFit:InputFormat', ...
        'Sorry, MTB doesn''t support that input format.');
    end

  else
    % If we get here, throw an error
    error('MemToolbox:MemFit:TooManyInputs', 'That''s just too much to handle.');
  end
end

%-----------------------------
function fit = MemFit_SingleData(data, model, verbosity)
  if isfield(data, 'errors')
    if (all(isInRange(data.errors,-90,90)) && ...
      (countInRanges(data.errors,[-90,-80],[80,90]) > 10) && ...
      (countInRanges(data.errors,[-100,-91],[91,100]) == 0)) && ...
      ~isfield(model, 'isOrientationModel')
       % Should we do this automatically for people, like we do for 2AFC data?
       fprintf(['WARNING: It looks like your data is from an orientation\n'...
       'experiment or something else where the errors can only span from\n'...
       '-90 to 90. If so, you should wrap your model with the function\n'...
       'Orientation() so that the MemToolbox knows that it should wrap the\n'...
       'distributions at +/-90 rather than +/-180.\n']);
    end
  end

  if(verbosity > 0)
    % Tell the user what's to come;
    if isfield(data, 'errors') && ~isfield(model, 'isOrientationModel')
      fprintf('\nError histogram:   ')
      PlotAsciiHist(data.errors);
    elseif isfield(data, 'afcCorrect')
      fprintf('\nMean percent correct: %0.2f\n', mean(data.afcCorrect));
    end
    fprintf('          Model:   %s\n', model.name);
    fprintf('     Parameters:   %s\n', prettyPrintParams(model.paramNames));
    pause(1);
  end

  % Do the fitting
  if(isempty(model.paramNames))
    fit.maxPosterior = [];
  else
    if(verbosity > 0)
      fprintf('\nJust a moment while MTB fits a model to your data...\n');
      pause(0.5);
    end
    posteriorSamples = MCMC(data, model, 'Verbosity', verbosity-1, ...
      'PostConvergenceSamples', max([4500 1500*length(model.paramNames)]), ...
      'BurnInSamplesBeforeCheck', 200);
    fit = MCMCSummarize(posteriorSamples);
    fit.posteriorSamples = posteriorSamples;

    if(verbosity > 0)
      % Display the results
      fprintf('\n...finished. Now let''s view the results:\n\n')
      fprintf('parameter\tMAP estimate\tlower CI\tupper CI\n')
      fprintf('---------\t------------\t--------\t--------\n')
      for paramIndex = 1:length(model.paramNames)
        fprintf('%8s\t%12.3f\t%8.3f\t%8.3f\n', ...
          model.paramNames{paramIndex}, ...
          fit.maxPosterior(paramIndex), ...
          fit.lowerCredible(paramIndex), ...
          fit.upperCredible(paramIndex));
      end
    end
  end

  if(verbosity > 0)
    % Optional interactive visualization
    fprintf('\n');
    r = input('Would you like to see the fit? (y/n): ', 's');
    if(strcmp(r,'y'))
      PlotModelFitInteractive(model, fit.maxPosterior, data);
    end
  end

  if(verbosity > 0)
    % Optional posterior visualization
    fprintf('\n');
    r = input(['Would you like to see the tradeoffs\n' ...
      'between parameters, samples from the posterior\n'...
      'distribution and a posterior predictive check? (y/n): '], 's');
    if(strcmp(r,'y'))

      if(isempty(model.paramNames))
        % Posterior predictive for zero-parameter models
        h = PlotPosteriorPredictiveData(model, [], data);
        subfigure(2,2,1, h);
      else
        % Show a figure with each parameter's correlation with each other
        h = PlotPosterior(posteriorSamples, model.paramNames);
        subfigure(2,2,1, h);

        % Show fit
        h = PlotModelParametersAndData(model, posteriorSamples, data);
        subfigure(2,2,2, h);

        % Posterior predictive plot
        h = PlotPosteriorPredictiveData(model, posteriorSamples, data);
        subfigure(2,2,3, h);
      end

      % Customizable model-based plot
      if isfield(model, 'modelPlot')
        h = model.modelPlot(data, posteriorSamples);
        subfigure(2,2,4, h);
      end
    end
  end
  if(verbosity > 0)
    fprintf('\nThis analysis was performed using MemToolbox version 1.0.0.\n\n')
  end
end

%-----------------------------
function fit = MemFit_ModelComparison(data, modelCellArray, verbosity)

  % Introduction & model listing
  if verbosity > 0
    fprintf('\nYou''ve chosen to compare the following models:\n\n')

    for modelIndex = 1:length(modelCellArray)
      fprintf('        Model %d:   %s\n',  ...
        modelIndex, modelCellArray{modelIndex}.name);
      fprintf('     Parameters:   %s\n', ...
        prettyPrintParams(modelCellArray{modelIndex}.paramNames));
      fprintf('\n');
    end

    fprintf('Computing log likelihood, AIC, AICc and BIC...\n\n');
  end

  % Model comparison & results
  [fit.AIC, fit.BIC, fit.logLike, fit.AICc] = ModelComparison_AIC_BIC(data, modelCellArray);

  % Print stats
  if verbosity > 0
    printStat('Log likelihood', fit.logLike, @max);
    printStat('AIC', fit.AIC, @min);
    printStat('AICc', fit.AICc, @min);
    printStat('BIC', fit.BIC, @min);
  end

  if verbosity > 0
    r = input(['Would you like to compute the DIC (note that this can be slow,\n' ...
      'since it requires running MCMC on each model)? (y/n): '], 's');
    fprintf('\n');
  end

  if verbosity == 0
    r = 'y';  % compute dic and bayes factors
  end

  posteriorSamples = [];
  if(strcmp(r,'y'))
    if verbosity > 0
      fprintf('Computing DIC...\n');
    end
    for m=1:length(modelCellArray)
      posteriorSamples{m} = MCMC(data, modelCellArray{m}, ...
        'Verbosity', 0, 'PostConvergenceSamples', 5000);
    end
    fit.DIC = ModelComparison_DIC(data, modelCellArray, 'Verbosity', verbosity, ...
      'PosteriorSamples', posteriorSamples);
    if verbosity > 0
      fprintf('\n');
      printStat('DIC', fit.DIC, @min);
    end
  end

  function printStat(name,stats,bestF,f)
    DescribeModelComparisonMethod(name);
    % Print headers
    fprintf(['\nmodel  \t' name '\n']);
    fprintf(['-----  \t' repmat('-', 1, length(name)) '\n']);
    % Print model-specific stats
    for curModel = 1:length(stats)
      fprintf('%2d     %0.2f\n', curModel, stats(curModel));
    end
    % Print model vs. model stats, default is difference
    if nargin < 4
      f = @(s,m1,m2) (s(m1) - s(m2));
    end
    if(~strcmp(name,'Posterior odds'))
      combos = combnk(1:length(stats),2);
      for i = 1:size(combos,1)
        fprintf('%d:%d  \t%0.2f\n', combos(i,1), combos(i,2), ...
          f(stats, combos(i,1), combos(i,2)));
      end
    end
    [tmp, best] = bestF(stats);
    fprintf('Preferred model: %d (%s)\n', best, modelCellArray{best}.name);
    fprintf('\n');
  end
end

%-----------------------------
function fit = MemFit_MultipleSubjects(dataCellArray, model, verbosity, hierarchy)
  if length(dataCellArray) == 1
    fit = MemFit(dataCellArray{1}, model, 'Verbosity', verbosity);
    return
  end
  if verbosity > 0
    fprintf('\nYou''ve chosen to fit multiple subjects'' data at once...\n\n');
    if hierarchy
      fprintf('... using a hierarchical model to fit the subjects together\n\n');
    end
    pause(1);
    for i = 1:length(dataCellArray)
      fprintf(' Subject number:   %d\n', i)
      fprintf('Error histogram:   ')
      PlotAsciiHist(dataCellArray{i}.errors);
      fprintf('\n')
    end
    fprintf('          Model:   %s\n', ...
        [lower(model.name(1)) model.name(2:end)]);
    fprintf('     Parameters:   %s\n\n', prettyPrintParams(model.paramNames));
    pause(1);
    fprintf('MTB will now fit the model to your datasets...\n');
  end
  if ~hierarchy
    for i = 1:length(dataCellArray)
      fit{i} = MemFit(dataCellArray{i}, model, 'Verbosity', 0);
    end
  else
    hModel = Hierarchical(dataCellArray, model);
    params = MAP(dataCellArray, hModel);
    fit = OrganizeHierarchicalParams(hModel, params);
  end
end


%-----------------------------
% Helper functions
%-----------------------------

% Converts a cell array {'a', 'b', 'c'} to string 'a, b, c'
function str = prettyPrintParams(array)
  if(isempty(array))
    str = '(none)';
  else
    str = [sprintf('%s, ', array{1:end-1}) array{end}];
  end
end

% Is the object an MTB model struct? passes iff the object is a struct
% containing a field called 'pdf' or 'logpdf'.
function pass = isModelStruct(object)
  pass = (isstruct(object) && any(isfield(object,{'pdf','logpdf'})));
end

% Is the object an MTB data struct? passes iff the object is a struct
% containing a field called 'errors'.
function pass = isDataStruct(object)
  pass = (isstruct(object) && (any(isfield(object,{'errors','error'})) || ...
          isfield(object, 'afcCorrect')));
end

% Is object a cell array whose elements all return true
% when the function isModelStruct is applied to them?
function pass = isCellArrayOfModelStructs(object)
  pass = iscell(object) && all(cellfun(@isModelStruct, object));
end

% Is object a cell array whose elements all return true
% when the function isDataStruct is applied to them?
function pass = isCellArrayOfDataStructs(object)
  pass = iscell(object) && all(cellfun(@isDataStruct, object));
end
