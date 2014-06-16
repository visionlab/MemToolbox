% MODELCOMPARISON_AIC_BIC Calculates AIC, AICc, and BIC values for models
%
%  [AIC, BIC, logLike, AICc] = ModelComparison_AIC_BIC(data, models)
%
% The Akaike Information Criterion is a measure of goodness of fit that
% includes a penalty term for each additional model parameter. Lower AIC
% denotes a better fit. To compare models A:B, look at the difference
% AIC(A) - AIC(B). Positive values provide evidence in favor of model B,
% negative in favor of model A.
%
% The corrected Aikaike Information is the same as the AIC, but it includes
% a correction for finite data. It can be interpretted in the same way.
%
% The Bayesian Information Criterion is similar to AIC, with different
% assumptions about the prior of models, and thus a more stringent penalty
% for more complex models. Its values should be compared the same way.
%
% Note that none of these values is appropriate to consider for hierarchical
% models, because they overestimate the number of degrees of freedom that
% the model has (since its parameter depend on each other).
%
%  Example usage:
%   data = MemDataset(3);
%   AIC = ModelComparison_AIC_BIC(data, {SwapModel(), StandardMixtureModel()})
%   aicDiff = AIC(1) - AIC(2)
%
% Optional parameters:
%  'MLEParams' - If you have already calculated the MLE parameters for each
%  model, you may include them as an optional argument. This should be a
%  cell array with the parameters for each model as a vector inside each
%  cell, e.g., 'MLEParams', {[0.1, 0.1, 30], [0.4, 20]}.
%
% References:
%
%   Akaike, H. (1974). A new look at the statistical model identification.
%   IEEE Transactions on Automatic Control, AC-19, 716-723.
%
%   Schwarz, G. E. (1978). Estimating the dimension of a model. Annals of
%   Statistics, 6(2), 461-464.
%
%   Burnham, K. P., and Anderson, D.R. (2002). Model selection and multimodel
%   inference: A practical information-theoretic approach. Springer-Verlag.
%
%   Spiegelhalter, D. J., Best, N. G., Carlin, B. P. and Van Der Linde, A.
%   (2002), Bayesian measures of model complexity and fit. Journal of the
%   Royal Statistical Society: Series B (Statistical Methodology), 64, 583-639.
%

function [AIC, BIC, logLike, AICc] = ModelComparison_AIC_BIC(data, models, ...
    varargin)
  args = struct('MLEParams', []);
  args = parseargs(varargin, args);

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
     if isempty(args.MLEParams)
       [params, logLike(md)] = MLE(data, models{md});
     else
       params = args.MLEParams{md};
       toCell = num2cell(params);
       logLike(md) = models{md}.logpdf(data, toCell{:});
     end

     % Calc AIC/AICc/BIC
     k = length(models{md}.upperbound);
     AIC(md) = -2*logLike(md) + 2*k;
     AICc(md)= -2*logLike(md) + 2*k * (dataLen / (dataLen - k - 1));
     BIC(md) = -2*logLike(md) + (log(dataLen)+log(2*pi))*k;
   end
end
