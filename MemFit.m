% Yet another wrapper for the MemToolbox. The goal here is to have a general
% purpose function that just works, excatly as a first-time user would expect.
% Ideally, you can run MemFit(data) and get a report of everything you'd
% ever really want to know about your data.
%
% Usage example:
% d = load('MemData/3000+trials_3items_SUBJ#1.mat');
% fit = MemFit(d.data);
%
% It can handle many different use cases, including:
% MemFit(data)
% MemFit(errors)
% MemFit(data,model)
% MemFit(model,data)
% MemFit(errors,model)
% MemFit(model,errors)
% MemFit(data, {model1, model2, model3, ...})
% MemFit({subj1data,subj2data,...}, model)
%
% All of the 2-arugment versions can take a third parameter, verbosity, which
% controls the amount of text printed to the command window. If verbosity is
% 0, output is suppressed. If verbosity is 1, output is minimal. If verbosity
% is 2, then MemFit is verbose. The default is 2.
%
% To dos include:
%   1. If called with no parameters, give a tutorial-like walkthrough

function fit = MemFit(varargin)
  
    % verbosity controls the amount of output. if verbosity is 0, output is
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
      error('MemToolbox:MemFit:TooFewInputs', 'MemFit requires at least 1 input argument.');
    
    %
    % One input argument, assumed to be (errors).
    %
    elseif nArguments == 1

        if(isnumeric(varargin{1}))
            data = struct('errors', varargin{1});
        elseif(isfield(varargin{1}, 'errors'))
            data = varargin{1};
        else
            error('MemToolbox:MemFit:InputFormat', 'Input format is wrong.'); 
        end
        fit = MemFit(data, StandardMixtureModelWithBias);
        return
            
    %
    % Two input arguments, so many possibilities...
    %
    % There are three arrangments that do the real work:
    %    MemFit(data,model), which fits the model to the data
    %    MemFit({data1,data2,...}, model), which fits a hierarchical model
    %    MemFit(data, {model1,model2,...}), which performs model comparison
    %
    elseif nArguments == 2
        
        % (errors, model)
        if(isnumeric(varargin{1}) && isModelStruct(varargin{2}))
            
            data = struct('errors', varargin{1});
            model = varargin{2};
            fit = MemFit(data,model);
        
        % (model, errors)
        elseif(isModelStruct(varargin{1}) && isnumeric(varargin{2}))
            
            data = struct('errors', varargin{2});
            model = varargin{1};
            fit = MemFit(data,model);
            
        % (model, data)
        elseif(isModelStruct(varargin{1}) && isDataStruct(varargin{2}))
            
            data = varargin{2};
            model = varargin{1};
            fit = MemFit(data, model);
            
        % (data, model)
        elseif(isDataStruct(varargin{1}) && isModelStruct(varargin{2}))

            data = validatedata(varargin{1});
            model = varargin{2};
          
            if(verbosity > 0)
            
              % tell the user what's to come;
              fprintf('\nError histogram:   ')
              hist_ascii(data.errors);
              fprintf('          Model:   %s\n', model.name);
              fprintf('     Parameters:   %s\n', paramNames2str(model.paramNames));
              
              pause(1);
              
              fprintf('\nJust a moment while MTB fits a model to your data...\n');
              
              pause(0.5);
            
            end

            % do the fitting
            stored = MCMC_Convergence(data, model, verbosity>1);
            fit = MCMC_Summarize(stored);
            fit.stored = stored;

            if(verbosity > 0)
              
              % display the results
              fprintf('\n...finished. Now let''s view the results:\n\n')

              fprintf('parameter\tMAP estimate\tlower CI\tupper CI\n')
              fprintf('---------\t------------\t--------\t--------\n')
              for paramIndex = 1:length(model.paramNames)
                  fprintf('%s\t\t%4.4f\t\t%4.4f\t\t%4.4f\n', ...
                          model.paramNames{paramIndex}, ...
                          fit.maxPosterior(paramIndex), ...
                          fit.lowerCredible(paramIndex), ...
                          fit.upperCredible(paramIndex));
              end
            end
            
            if(verbosity>1)

              % optional interactive visualization
              fprintf('\n');
              r = input('Would you like to see the fit? (y/n): ', 's');
              if(strcmp(r,'y'))
                  PlotModelFitInteractive(model, fit.maxPosterior, data);
              end

              % optional convergence visualization
              fprintf('\n');
              r = input(['Would you like to see the MCMC chains, tradeoffs ' ...
                         'between parameters, samples from the posterior distribution '...
                         'and a posterior predictive check? (y/n): '], 's');
              if(strcmp(r,'y'))
                  h = MCMC_Convergence_Plot(stored, model.paramNames);
                  subfigure(2,2,1, h);

                  % Show a figure with each parameter's correlation with each other
                  h = MCMC_Plot(stored, model.paramNames);
                  subfigure(2,2,2, h);

                  % Show fit
                  h = PlotModelParametersAndData(model, stored, data);
                  subfigure(2,2,3, h);

                  % Posterior predictive
                  h = PlotPosteriorPredictiveData(model, stored, data);
                  subfigure(2,2,4, h);        
              end
            end
            
            if(verbosity > 0)
              fprintf('\nThis analysis was performed using an alpha release of the MemToolbox.\n')
            end
                        
        % (errors, {model1,model2,model3,...})
        elseif(isnumeric(varargin{1}) && isCellArrayOfModelStructs(varargin{2}))

            data = struct('errors', varargin{1});
            models = varargin{2};
            fit = MemFit(data, models);
        
        % (data, {model1,model2,model3,...})
        elseif(isDataStruct(varargin{1}) && isCellArrayOfModelStructs(varargin{2}))
              
            data = validatedata(varargin{1});
            modelCellArray = varargin{2};

            % Introduction & model listing

            fprintf('\nYou''ve chosen to compare the following models:\n')
            for modelIndex = 1:length(modelCellArray)
               fprintf('  %d. %s\n', modelIndex, modelCellArray{modelIndex}.name); 
            end

            fprintf('\nJust a moment while MTB fits these models to your data...\n\n');
            
            
            % Model comparison & results

            [fit.MD, fit.params, fit.stored] = ...
                ModelComparison_BayesFactor(varargin{1}, modelCellArray);

            fprintf('model\tlog L\tprop. preferred\tlog Bayes factor\n');
            fprintf('-----\t-----\t---------------\t----------------\n');
            for modelIndex = 1:length(modelCellArray)
               fprintf('%d\t%0.f\t%0.4f\t\t%3.2f\n',  ...
                       modelIndex, ...
                       max(fit.stored{modelIndex}.like),  ...
                       fit.MD(modelIndex), ...
                       log(fit.MD(modelIndex)) - log(sum(fit.MD([1:(modelIndex-1) (modelIndex+1):end]))))
            end

            fprintf('\nBest parameters:\n');
            disp(fit.params);


        % ({data1,data2,data3,...}, model)
        elseif(isCellArrayOfDataStructs(varargin{1}) && isModelStruct(varargin{2}))
          
            dataCellArray = varargin{1};
            
            % validate all of the data
            for i = 1:length(dataCellArray)
              dataCellArray{i} = validatedata(dataCellArray{i});
            end
            
            model = varargin{2};
            
            fprintf('\nYou''ve chosen to fit multiple subjects'' data together...\n\n');
            
            pause(1);
            
            for i = 1:length(dataCellArray)
              fprintf(' Subject number:   %d\n', i)
              fprintf('Error histogram:   ')
              hist_ascii(dataCellArray{i}.errors);
              fprintf('     Parameters:   %s\n\n', paramNames2str(model.paramNames));
            end
          
            pause(1);
          
            fprintf('Hang in there while MTB fits the model to your data...\n');
            
            [fit.paramsMean, fit.paramsSE, fit.paramsSubs] = ...
                FitMultipleSubjects_Hierarchical(dataCellArray, model);
          
        else
            error('MemToolbox:MemFit:InputFormat', ...
                  'Sorry, MTB doesn''t support that input format.'); 
        end
      
    elseif nArguments == 3
      
      
    else
    
      % if we get here, throw an error
      error('MemToolbox:MemFit:TooManyInputs', 'That''s just too much to handle.');
    end
end

% RESPONSE2ERROR(RESPONSE,TARGET) returns the error given the target and response.
% Wants things in radians. This is just the circular distance formula...
function err = response2error(response, target)
    
    if nargin < 2
        error('MemToolbox:MemFit:TooFewInputs', 'Too few inputs.');
    end

    err = angle(exp(1i*response)./exp(1i*target));
end

% converts a cell array of strings {'a', 'b', 'c'} to string 'a, b, c'
function str = paramNames2str(paramNames)
    str = [];
    for i = 1:length(paramNames)
        str = [str paramNames{i}];
        if(i < length(paramNames))
            str = [str ', '];
        end
    end
end


% is the object an MTB model struct? passes iff the object is a struct 
% containing a field called 'pdf' or 'logpdf'. 
function pass = isModelStruct(object)
    pass = (isstruct(object) && any(isfield(object,{'pdf','logpdf'})));
end

% is the object an MTB data struct? passes iff the object is a struct
% containing a field called 'errors'.
function pass = isDataStruct(object)
    pass = (isstruct(object) && isfield(object,'errors'));
end

function pass = isCellArrayOfModelStructs(object)
    pass = isCellArrayOfType(object,@isModelStruct)
end

function pass = isCellArrayOfDataStructs(object)
   pass = isCellArrayOfType(object,@isDataStruct);
end

% is object a cell array whose elements all return true
% when the function typeChecker is applied to them?
function pass = isCellArrayOfType(object,typeChecker)
    c1 = iscell(object);
    c2 = false(size(object));
    for i = 1:length(object)
        c2(i) = typeChecker(object{i});
    end
    pass = c1 && all(c2);
end