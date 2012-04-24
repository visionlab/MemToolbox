% Yet another wrapper for the MemToolbox. The goal here is to have a general
% purpose function that just works, excatly as a first-time user would expect.
% Ideally, you can run MemFit(data) and get a report of everything you'd
% ever really want to know about your data.
%
% Usage example:
% d = load('MemData/3000+trials_3items_SUBJ#1.mat');
% fit = MemFit(d.data);
%
% MemFit(data)
% MemFit(data,model)
% MemFit(data, {model1, model2, model3, ...})
% MemFit(responses, stimuli, whichIsTarget)
%
% To dos include:
%   1. If called with no parameters, give a tutorial-like walkthrough

function fit = MemFit(varargin)
    
    if nargin < 1
      error('MemToolbox:MemFit:TooFewInputs', 'MemFit requires at least 1 input argument.');
    end
    
    %
    % One input argument, assumed to be (errors).
    %
    if nargin == 1

        if(isnumeric(varargin{1}))
            fit = MemFit(varargin{1}, StandardMixtureModelWithBias);
            return
        else
            error('MemToolbox:MemFit:InputFormat', 'Input format is wrong.'); 
        end
    end
    
    %
    % Two input arguments, assumed to be either (model, errors), or (errors, model)
    %
    if nargin == 2
        
        % (errors, model)
        if(isnumeric(varargin{1}) && isstruct(varargin{2}))
            data = varargin{1};
            [data, pass] = validateData(data);
            model = varargin{2};
        
        % (model, errors)
        elseif(isstruct(varargin{1}) && isnumeric(varargin{2}))
            data = varargin{2};
            [data, pass] = validateData(data);
            model = varargin{1};
                
        % (data, {model1,model2,model3, ...})
        elseif(isnumeric(varargin{1}) && iscell(varargin{2}))
          
            data = varargin{1};
            [data, pass] = validateData(data);
            
            allModels = varargin{2};
            
            % Introduction & model listing
            
            fprintf('\nYou''ve chosen to compare the following models:\n')
            for modelIndex = 1:length(allModels)
               fprintf('  %d. %s\n', modelIndex, allModels{modelIndex}.name); 
            end
            
            fprintf('\nJust a moment while MTB fits these models to your data...\n\n');
            
            
            % Model comparison & results
            
            [MD, params, stored] = ModelComparison_BayesFactor(varargin{1}, allModels);
            
            fprintf('model\tlog L\tprop. preferred\tlog Bayes factor\n')
            fprintf('-----\t-----\t---------------\t----------------\n')
            for modelIndex = 1:length(allModels)
               fprintf('%d\t%0.f\t%0.4f\t\t%3.2f\n',  ...
                       modelIndex, ...
                       max(stored{modelIndex}.like),  ...
                       MD(modelIndex), ...
                       log(MD(modelIndex)) - log(sum(MD([1:(modelIndex-1) (modelIndex+1):end]))))
            end

            fprintf('\nBest parameters:\n');
            disp(params);

            return
        else
            error('MemToolbox:MemFit:InputFormat', 'Input format is wrong.'); 
        end

        % tell the user what's to come
        fprintf('\nJust a moment while MTB fits a model to your data...\n\n');
        fprintf('Error histogram:   ')
        hist_ascii(data);
        fprintf('          Model:   %s\n', model.name);
        fprintf('     Parameters:   %s\n', paramNames2str(model.paramNames));
        
        % do the fitting
        stored = MCMC_Convergence(data, model, false);
        fit = MCMC_Summarize(stored);
        fit.stored = stored;
        
        % display the results
        fprintf('\n\n...finished. Now let''s view the results.\n\n')
        
        fprintf('parameter\tMAP estimate\tlower CI\tupper CI\n')
        fprintf('---------\t------------\t--------\t--------\n')
        for paramIndex = 1:length(model.paramNames)
            fprintf('%s\t\t%4.4f\t\t%4.4f\t\t%4.4f\n', ...
                    model.paramNames{paramIndex}, ...
                    fit.maxPosterior(paramIndex), ...
                    fit.lowerCredible(paramIndex), ...
                    fit.upperCredible(paramIndex));
        end
        
        % optional interactive visualization
        fprintf('\n');
        r = input('Would you like to visualize the fit? (y/n): ', 's');
        if(strcmp(r,'y'))
            PlotModelFitInteractive(model, fit.maxPosterior, data)
        end
        
        % optional convergence visualization
        fprintf('\n');
        r = input(['Would you like to visualize the MCMC chains, tradeoffs ' ...
                   'between parameters, samples from the posterior distribution '...
                   'and a posterior predictive check? (y/n): '], 's');
        if(strcmp(r,'y'))
            h = MCMC_Convergence_Plot(stored, model.paramNames);
            subfigure(2,2,1, h);

            % Show a figure with each parameter's correlation with each other
            h = MCMC_Plot(stored, model.paramNames);
            subfigure(2,2,2, h);

            % Show fit
            h = PlotModelParametersAndData(model, stored, data(:));
            subfigure(2,2,3, h);

            % Posterior predictive
            h = PlotPosteriorPredictiveData(model, stored, data(:));
            subfigure(2,2,4, h);        
        end
        
        fprintf('\nModeling complete. This analysis was performed using MemToolbox 0.1.\n')
        
        return
    end
    
    %
    % Three input arguments
    % in the works
    if nargin == 3
        
        % (responses, stimuli, whoIsTarget)
        if(isnumeric(varargin{1}) && isnumeric(varargin{2} && isnumeric(varargin{3})))
            targets = varargin{2}(varargin{3});
            data = response2error(varargin{1}, targets);
            fit = MemFit(data);
            
        else % add other cases
            
        end
    end
    
    if nargin == 4
        
    end
    
    % if we get here, throw an error
    error('MemToolbox:MemFit:TooManyInputs', 'That''s just too much to handle.');
    fit = -1;
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

% checks to make sure that the data is in the expected format (in the range 
% [-pi,pi]. if it's not, throws errors. 
function [data, pass] = validateData(data)

    pass = false; % assume failure, unless...
    
    if(~isnumeric(data))
        throwRangeError();   
          
    % vomit if range is unintelligeble
    elseif(any(data < -pi | data > pi))
        throwRangeError()
        
    else
      pass = true;
      
    end

    %   
    % % otherwise, assume it's (-pi,pi), (0,2*pi), (-180,180), or (0, 360),
    % % throw a warning if it isn't (-pi,pi), and convert to -pi,pi.
    % if(any(data < -pi)) % then it must be in range (-180, 180)
    %     throwRangeWarning();
    %     data = deg2rad(data);
    % 
    % elseif(any(data > 180)) % then it must be in range (0,360)
    %     throwRangeWarning();
    %     data = deg2rad(data-180);
    % 
    % elseif(any(data > pi)) % then it must be in range (0, 2*pi)
    %     throwRangeWarning();
    %     data = data-pi;
    %     
    % else % okay, it's in the range (-pi,pi), so leave it be.
    %     pass = true;
    % end
end

function throwRangeError()
    error('Yuck. Data should be in the range (-pi, pi)');
end
