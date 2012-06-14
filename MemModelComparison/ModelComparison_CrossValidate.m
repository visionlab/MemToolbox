%---------------------------------------------------------------------
% TOGO: Use all start positions for all models, rather than just the first
% one
function [logLike, AIC, params] = ModelComparison_CrossValidate(data, models, varargin)

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
       trainingData = data.errors;
       curHoldoutData = segments(s):(segments(s+1)-1);
       testData = data.errors(curHoldoutData);
       trainingData(curHoldoutData) = [];
       
       % Fit mle()
       paramsSeg{md}(s,:) = mle(struct('errors', trainingData), 'pdf', models{md}.pdf, 'start', models{md}.start(1,:), ...
         'lowerbound', models{md}.lowerbound, 'upperbound', models{md}.upperbound);
       
       % Get likelihood on hold-out set
       asCell = num2cell(paramsSeg{md}(s,:));
       logLike(md) = logLike(md) + sum(log(models{md}.pdf(struct('errors', testData), asCell{:})));
     end
     params{md} = mean(paramsSeg{md}, 1);
     AIC(md) = 2*length(models{md}.lowerbound) - 2*logLike(md);
   end   
end
