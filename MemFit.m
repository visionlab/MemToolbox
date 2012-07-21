% MemFit - A general-purpose fitting tool from the MemToolbox
%
%   Usage example:
%   data = MemDataset(1);
%   fit = MemFit(data);
%
%   It can handle many different use cases, including:
%   MemFit(data)
%   MemFit(errors)
%   MemFit(data,model)
%   MemFit(model,data)
%   MemFit(errors,model)
%   MemFit(model,errors)
%   MemFit(data, {model1, model2, model3, ...})
%   MemFit({subj1data,subj2data,...}, model)
%
%   All of the 2-argument versions can optionally take a third parameter,
%   verbosity, which controls the amount of text printed to the command window.
%   If verbosity is 0, output is suppressed. If verbosity is 1, output is
%   minimal. If verbosity is 2, then MemFit is verbose. The default is 2.
%

%-----------------------------
function fit = MemFit(varargin)
  % This function (MemFit) just dispatches the real work to the functions
  % below:
  %
  %    MemFit_SingleData(data,model), which fits the model to the data
  %    MemFit_MultipleSubjects({data1,data2,...}, model), which fits a 
  %       hierarchical model
  %    MemFit_ModelComparison(data, {model1,model2,...}), which performs 
  %       model comparison
  % 
  % If you want to see how MemFit() works, you should look at those
  % functions, located below this one.
  
  % Verbosity controls the amount of output. if verbosity is 0, output is
  % suppressed completely. if verbosity is 1, output is minimal. if verbosity
  % is 2, then it's verbose. here, check for verbosity and then chop it off.
  if nargin == 3
    verbosity = varargin{3};
    nArguments = 2;
  else
    verbosity = 2;
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
      fit = MemFit(data, StandardMixtureModel('Bias', false), 1);
      
    elseif(isfield(varargin{1}, 'afcCorrect'))
      warning('MemToolbox:MemFit:InputFormat', ...
        'It looks like you passed in 2AFC data. Trying to fit with TwoAFC(StandardMixtureModel()).');
      fit = MemFit_SingleData(varargin{1}, TwoAFC(StandardMixtureModel()), 2);
      
    elseif(any(isfield(varargin{1}, {'errors','error'})))
      data = varargin{1};
      fit = MemFit(data, StandardMixtureModel('Bias', false), 1);
      
    elseif(isCellArrayOfDataStructs(varargin{1}))
      data = varargin{1};
      fit = MemFit(data, StandardMixtureModel('Bias', false), 1);
      
    else
      error('MemToolbox:MemFit:InputFormat', 'Input format is wrong.');
      fit = -1;
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
      fit = MemFit_MultipleSubjects(dataCellArray, model, verbosity);
      
    else
      error('MemToolbox:MemFit:InputFormat', ...
        'Sorry, MTB doesn''t support that input format.');
    end
    
  else
    % if we get here, throw an error
    error('MemToolbox:MemFit:TooManyInputs', 'That''s just too much to handle.');
  end
end

%-----------------------------
function fit = MemFit_SingleData(data, model, verbosity)
  if(verbosity > 0)
    % tell the user what's to come;
    if isfield(data, 'errors')
      fprintf('\nError histogram:   ')
      PlotAsciiHist(data.errors);
    elseif isfield(data, 'afcCorrect')
      fprintf('\nMean percent correct: %0.2f\n', mean(data.afcCorrect));      
    end
    fprintf('          Model:   %s\n', model.name);
    fprintf('     Parameters:   %s\n', prettyPrintCellArray(model.paramNames));
    pause(1);
    fprintf('\nJust a moment while MTB fits a model to your data...\n');
    pause(0.5);
  end
  
  % do the fitting
  posteriorSamples = MCMC(data, model, 'Verbosity', verbosity-1);
  fit = MCMCSummarize(posteriorSamples);
  fit.posteriorSamples = posteriorSamples;
  
  if(verbosity > 0)
    % display the results
    fprintf('\n...finished. Now let''s view the results:\n\n')
    fprintf('parameter\tMAP estimate\tlower CI\tupper CI\n')
    fprintf('---------\t------------\t--------\t--------\n')
    for paramIndex = 1:length(model.paramNames)
      fprintf('%s\t\t%3.3f\t\t%3.3f\t\t%3.3f\n', ...
        model.paramNames{paramIndex}, ...
        fit.maxPosterior(paramIndex), ...
        fit.lowerCredible(paramIndex), ...
        fit.upperCredible(paramIndex));
    end
  end
  
  if(verbosity > 0)
    % optional interactive visualization
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
      % Show a figure with each parameter's correlation with each other
      h = PlotPosterior(posteriorSamples, model.paramNames);
      subfigure(2,2,1, h);
      
      % Show fit
      h = PlotModelParametersAndData(model, posteriorSamples, data);
      subfigure(2,2,2, h);
      
      % Posterior predictive
      h = PlotPosteriorPredictiveData(model, posteriorSamples, data);
      subfigure(2,2,3, h);
    end
  end
  if(verbosity > 0)
    fprintf('\nThis analysis was performed using a\nbeta release of the MemToolbox.\n\n')
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
              prettyPrintCellArray(modelCellArray{modelIndex}.paramNames));
      fprintf('            MLE:   %s\n', ...
          prettyPrintCellArray(cellstr(num2str(MLE(data, modelCellArray{modelIndex})'))));
      fprintf('\n');
    end
    
    fprintf('\nJust a moment while MTB fits these models to your data...\n\n');
  end
  
  % Model comparison & results
  [fit.bayesFactor,fit.posteriorOdds,fit.fullPosterior] = ...
    ModelComparison_BayesFactor(data, modelCellArray);
  
  fprintf('model\tlog L\tAIC\tprop. preferred\tlog Bayes factor\n');
  fprintf('-----\t-----\t---\t---------------\t----------------\n');
  for modelIndex = 1:length(modelCellArray)
      
      [logLike,i] = max(fit.fullPosterior{modelIndex}.logLikeMatrix(:));      
      AIC = 2*(length(modelCellArray{modelIndex}.paramNames)) - 2*logLike;
      fit.AIC(modelIndex) = AIC;
      fprintf('%d\t%0.f\t%0.f\t%0.4f\t\t%3.2f\n',  ...
        modelIndex, ...
        logLike,  ...
        AIC, ...
        -Inf, ... % in the works.
        fit.bayesFactor(modelIndex));
  end

end

%-----------------------------
function fit = MemFit_MultipleSubjects(dataCellArray, model, verbosity)
  if length(dataCellArray) == 1
    fit = MemFit(dataCellArray{1}, model, verbosity);
    return
  end
  if verbosity > 0
    fprintf('\nYou''ve chosen to fit multiple subjects'' data together...\n\n');
    pause(1);
    for i = 1:length(dataCellArray)
      fprintf(' Subject number:   %d\n', i)
      fprintf('Error histogram:   ')
      PlotAsciiHist(dataCellArray{i}.errors);
      fprintf('\n')
    end
    fprintf('          Model:   %s\n', ...
        ['Hierarchical ' lower(model.name(1)) model.name(2:end)]);    
    fprintf('     Parameters:   %s\n\n', prettyPrintCellArray(model.paramNames));
    pause(1);
    fprintf('Hang in there while MTB fits the model to your data...\n');
  end
  [fit.paramsMean, fit.paramsSE, fit.paramsSubs] = ...
    FitMultipleSubjects_Hierarchical(dataCellArray, model);
end


%-----------------------------
% Helper functions
%-----------------------------

% Converts a cell array {'a', 'b', 'c'} to string 'a, b, c'
function str = prettyPrintCellArray(array)
  str = [sprintf('%s, ', array{1:end-1}) array{end}];
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
