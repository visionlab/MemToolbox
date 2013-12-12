% MODELCOMPARISON_DIC Calculates DIC values for models
%
%    [dic, pD] = ModelComparison_DIC(data, models, [optionalParameters])
%
%  DIC is a generalization of Akaike's Information Criterion (AIC)
%  designed for hierarchical models.  It estimates the "effective number of
%  parameters" based on the spread of the posterior distribution, and thus
%  does not penalize models for having more parameters but rather penalizes
%  them for being more flexible (not all parameters give equal flexibility).
%
%  Differences in DIC should be interpreted in much the same way as
%  differences in AIC. E.g.,
%
%   > 10 - rules out model with higher DIC
%   5-10 - substantial support
%   < 5  - unclear support
%
%  Calculating the DIC requires running MCMC on each model, which in many
%  cases you will have already done. Thus, ModelComparison_DIC takes an
%  optional parameter 'PosteriorSamples', which is a cell array the same
%  length as the cell array of models that contains these samples. E.g.,
%
%   posteriorSamples1 = MCMC(data, model1);
%   posteriorSamples2 = MCMC(data, model2);
%   [dic, pD] = ModelComparison_DIC(data, {model1, model2}, ...
%       'PosteriorSamples', {posteriorSamples1, posteriorSamples2});
%
%  ModelComparison_DIC returns two parameters, dic, the DIC value for each
%  model, as well as pD, the effective number of parameters for each model.
%

function [dic, pD] = ModelComparison_DIC(data, models, varargin)
  args = struct('Verbosity', 1, 'PosteriorSamples', []);
  args = parseargs(varargin, args);

  if length(models) < 2
    error('Model comparison requires a cell array of at least two models.');
  end

  if args.Verbosity > 0
    fprintf('\nComparing %d models by DIC:\n', length(models));
  end

   % Fit each model...
   for md = 1:length(models)
     models{md} = EnsureAllModelMethods(models{md});
     if args.Verbosity > 0
       fprintf('- Sampling from model %d: %s\n', md, models{md}.name);
     end
     if isempty(args.PosteriorSamples)
       posteriorSamples = MCMC(data, models{md}, 'Verbosity', 0);
     else
       posteriorSamples = args.PosteriorSamples{md};
     end

     % Calculate mean deviance from posterior samples
     meanDeviance = mean(-2.*posteriorSamples.like);

     % Calculate the deviance of the posterior mean
     posteriorMean = MCMCSummarize(posteriorSamples, 'posteriorMean');
     asCell = num2cell(posteriorMean);
     devianceOfMean = -2 .* (models{md}.logpdf(data, asCell{:}) ...
       + models{md}.logprior(posteriorMean));

     % Effective number of parameters is the difference of these two values
     pD(md) = meanDeviance - devianceOfMean;

     % Final DIC calculation
     dic(md) = pD(md) + meanDeviance;
   end
end


