% DESCRIBEMODELCOMPARISONMETHOD Describe in words the various model comparsion metrics
%
%   DescribeModelComparisonMethod(name);
%
%  Given the name of a model comparison metric (e.g., 'AIC'), prints a
%  description of its meaning.
%
function DescribeModelComparisonMethod(name)
  switch name
     case 'AIC'
       str = 'The Akaike Information Criterion is a measure of goodness of fit that includes a penalty term for each additional model parameter. Lower AIC denotes a better fit. To compare models A:B, look at the difference AIC(A) - AIC(B). Positive values provide evidence in favor of model B, negative in favor of model A.';
     case 'AICc'
       str = 'The corrected Aikaike Information is the same as the AIC, but it includes a correction for finite data. It can be interpreted in the same way.';
     case 'BIC'
       str = 'The Bayesian Information Criterion is similar to AIC, with different assumptions about the prior of models, and thus a more stringent penalty for more complex models. It can be interpreted in the same way.';
     case 'DIC'
       str = 'The Deviance Information Criterion is a generalization of the AIC and BIC that includes a penalty for the effective number of parameters, estimated from the dispersion in the posterior of the models.';
     case 'Log likelihood'
       str = 'The log likelihood of the parameters given the data.';
     otherwise
       str = 'There is no description available for this comparison.';
  end
  lines = linewrap(str, 50);
  for i = 1:length(lines)
    fprintf('%s\n', lines{i});
  end
end
