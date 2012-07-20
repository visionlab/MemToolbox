% ModelComparison_AIC_BIC - Calculates AIC and BIC values for models

function [aic, bic, logLike] = ModelComparison_AIC_BIC(data, models)
  
  if length(models) < 2
    error('Model comparison requires a cell array of at least two models.');
  end
  
   % Fit each model...
   for md = 1:length(models)
     models{md} = EnsureAllModelMethods(models{md});
     if isfield(data, 'errors')
       dataLen = length(data.errors);
     else
       dataLen = length(data.afcCorrect);
     end
       
     % Get likelihood
     params = MLE(data, models{md});
     asCell = num2cell(params);
     logLike(md) = models{md}.logpdf(data, asCell{:});
     
     % Calc AIC/BIC
     aic(md) = -logLike(md) + 2*length(models{md}.upperbound);
     bic(md) = -logLike(md) + log(dataLen)*length(models{md}.upperbound);
   end   
end
