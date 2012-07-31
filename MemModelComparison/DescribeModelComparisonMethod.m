% DESCRIBEMODELCOMPARISONMETHOD Describe in words the various model comparsion metrics
%   
%   DescribeModelComparisonMethod(name);
%
%  Given the name of a model comparison metric (e.g., 'AIC'), prints a
%  description of its meaning.
%
function DescribeModelComparisonMethod(name)
  switch name
     case 'Log Bayes factor'
       str = 'When comparing models A:B, the log Bayes factor for model A is the change in log odds in favor of that model after seeing the data, with positive values ruling in favor of model A. Typically, a log Bayes factor between 0 and 0.5 is not worth more than a mention, one between 0.5 and 1 is substantial support, one between 1 and 2 is strong support, and one above 2 is decisive.';
     case 'AIC'
       str = 'The Akaike Information Criterion is a measure of goodness of fit that includes a penalty term for each additional model parameter. Lower AIC denotes a better fit. To compare models A:B, look at the difference AIC(A) - AIC(B). Positive values provide evidence in favor of model B, negative in favor of model A.';
     case 'AICc'
       str = 'The corrected Aikaike Information is the same as the AIC, but it includes a correction for finite data. It can be interpreted in the same way.';
     case 'BIC'
       str = 'The Bayesian Information Criterion is similar to AIC, with different assumptions about the prior of models, and thus a more stringent penalty for more complex models. It can be interpreted in the same way.';
     case 'DIC'
       str = 'The Deviance Information Criterion is a generalization of the AIC and BIC that includes a penality for the effective number of parameters, estimated from the dispersion in the posterior of the models.';
     case 'Posterior odds'
       str = 'Computed from the Bayes factor, this gives the posterior odds of each model, a measure of degree-of-belief in each after having seen the data.';
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