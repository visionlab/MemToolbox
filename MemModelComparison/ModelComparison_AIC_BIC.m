% ModelComparison_AIC_BIC - Calculates AIC, AICc, and BIC values for models

function [AIC, BIC, logLike, AICc] = ModelComparison_AIC_BIC(data, models)
  
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
       
     % Get max posterior
     [params, logLike(md)] = MAP(data, models{md});
     
     % Calc AIC/AICc/BIC
     k = length(models{md}.upperbound);
     AIC(md) = -2*logLike(md) + 2*k;
     AICc(md)= AIC(md) + (2*k*(k+1))/(dataLen-k-1);
     BIC(md) = -2*logLike(md) + log(dataLen)*length(models{md}.upperbound);
   end   
end
