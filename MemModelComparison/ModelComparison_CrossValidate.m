% MODELCOMPARISON_CROSSVALIDATE Cross validates model likelihood by fitting on part of data
% Fits model to (X-1)/Xs of the data and evaluating the model on 1/X of the
% data. 
% 
%  [logLike, params] = ...
%        ModelComparison_CrossValidate(data, models, [optionalParameters])
%
% As a default, 1/10 of the data is used for cross-validation. You may
% change this by changing the optional parameter 'Splits' to a number other
% than 10.
%
% In theory, cross-validation eliminates any benefit models have from being
% more flexible/having more parameters. However, it does not penalize
% models for being too complex; a too complex model will provide an equal
% (although not better) fit compared to the correct model.
%
function [logLike, params] = ModelComparison_CrossValidate(data, models, varargin)
  
  if length(models) < 2
    error('Model comparison requires a cell array of at least two models.');
  end
  
   % Default: split data into 10 parts, use 9 for training, 1 for test
   args = struct('Splits', 10);
   args = parseargs(varargin, args);
     
   % Fit each model...
   for md = 1:length(models)
     models{md} = EnsureAllModelMethods(models{md});
     logLike(md) = 0;
     
     % Split data into parts parts, use most for training, 1 for test
     segments = round(linspace(1,length(data.errors), args.Splits));
     for s = 1:length(segments)-1       
       % Setup training and test
       curHoldoutData = segments(s):(segments(s+1)-1);
       trainingData = data;
       trainingData.errors(curHoldoutData) = NaN;
       testData = data;
       testData.errors(~ismember(1:length(data.errors), curHoldoutData)) = NaN;
       
       % Fit mle()
       paramsSeg{md}(s,:) = MLE(trainingData, models{md});
       
       % Get likelihood on hold-out set
       asCell = num2cell(paramsSeg{md}(s,:));
       logLike(md) = logLike(md) + models{md}.logpdf(testData, asCell{:});
     end
     params{md} = mean(paramsSeg{md}, 1);
   end   
end
