% ModelComparison_AIC_BIC - Calculates AIC, AICc, and BIC values for models
%
%
% References:
%
%   Akaike, H. (1974). A new look at the statistical model identification.
%   IEEE Transactions on Automatic Control, AC-19, 716-723. 
%   
%   Schwarz, G. E. (1978). Estimating the dimension of a model. Annals of 
%   Statistics, 6(2), 461–464.
%
%   Burnham, K. P., and Anderson, D.R. (2002). Model selection and multimodel 
%   inference: A practical information-theoretic approach. Springer-Verlag.
%
%   Spiegelhalter, D. J., Best, N. G., Carlin, B. P. and Van Der Linde, A. 
%   (2002), Bayesian measures of model complexity and fit. Journal of the 
%   Royal Statistical Society: Series B (Statistical Methodology), 64, 583–639.
%   

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
     [params, logLike(md)] = MLE(data, models{md});
     
     % Calc AIC/AICc/BIC
     k = length(models{md}.upperbound);
     AIC(md) = -2*logLike(md) + 2*k;
     AICc(md)= AIC(md) + (2*k*(k+1))/(dataLen-k-1);
     BIC(md) = -2*logLike(md) + log(dataLen)*length(models{md}.upperbound);
   end   
end
