% TEMPLATEMODEL is a model template whose comments explain each of the required
% and optional components. (It happens to be NoGuessingModel, with bias, and
% parameterized by the concentration parameter kappa of the von Mises.)
function model = TemplateModel()

  % The model should be given a unique name. This name is used by MemFit and
  % the model testing functions to let the user know which model is being
  % tested. Example model names are 'Slots+averaging model' and 'Swap model'.
  model.name = 'Template model';

  % What are the names of the model's parameters? Later, we're going to define
  % a likelihood function that specifies a probability distribution over data
  % sets for each possible setting of the model's parameters. The only
  % constraint in naming them is that they should probably use names that will
  % work as MATLAB variables, like 'g', 'sd', or 'precision', but not '12x'
  % or 'mean-sd'. We recommend giving them descriptive names.
	model.paramNames = {'p1', 'p2'};

  % What is the lowest value that the parameter can possibly be? This can
  % be any real number, or -Inf for variables that are unbounded in the
  % negative direction.
	model.lowerbound = [-180 0];

  % What is the greatest value that the parameter can possibly be?
	model.upperbound = [180 Inf];

  % Define the model's likelihood function. This function should have
  % 1+N parameters, where N is the number of parameters in the model. The
  % first parameter is always 'data', which is a MemToolbox data structure.
  % The next N parameters give the model's parameters. You should use the
  % same names as you did in model.paramNames.
  %
  % Sometimes it is possible to write a one-line likelihood function, and for
  % that you can use an anonymous function, like this:
  %
  % model.pdf = @(data, p1, p2) (vonmisespdf(data.errors(:),p1,p2));
  %
  % On other occasions, it might be necessary to define a more complex function
  % that is unwiedly when anonymous, and for this you can define a separate
  % function, and then define model.pdf as that function's handle, like this:
  model.pdf = @modelPDF;

  % Some of the stochastic search techniques used in the toolbox require that
  % you specify starting states for each of the parameters. This is used as the
  % starting states for MCMC and the algorithm used for MLE.
	model.start = [0.2, 10;  % p1, p2
                 0.4, 15;
                 0.1, 20];

  % Markov Chain Monte Carlo proposes small jumps from the current parameter
  % settings to new settings. How big should those jumps initially be for each
  % parameter? Pick
  model.movestd = [0.02, 1];

  % (optional)
  % Bayesian methods update a set of prior beliefs based on observed data.
  % What are your prior beliefs? For the purposes of exploratory data analysis,
  % it is common to use a noninformative or weakly informative prior that
  % spreads the probability thinly over a swath of plausible parameter values.
  % Following this tradition, the existing models in the toolbox use the
  % Jeffreys prior, a class of noninformative priors that is invariant under
  % reparameterization of the model (Jeffreys, 1946; Jaynes1968). With
  % sufficient data, these noninformative priors have almost no influence on
  % the final inferences, serving only to limit the range of parameters to
  % those that are meaningful. There's a subfolder MemModels/Priors that
  % has many priors that you might find useful.
  %
  % If you do not specify a model.prior, the toolbox defaults to using an
  % improper prior that any value is equally likely.
  %
  % The prior is a function of the parameters (specified as a vector), that
  % returns a probability. To recreate the toolbox's default behavior when no
  % model is specified (i.e., the behavior you would get if you commented out
  % the following line), you would define the prior as follows:
  model.prior = @(p) (1);

  % (optional)
  % Some of the toolbox's functionality, like posterior predictive checks,
  % simulate data from the model. The toolbox includes a general purpose
  % sampler, but this is often slow and it is considerably faster to specify
  % your own generator function. The generator function takes three parameters.
  % The first is a cell array of values for the model's parameters. The second
  % is the number of data points to simulate, in the form of the dimensions of
  % the output. The third is a displayInfo structure that can include details
  % about the specific displays if the model requires it.
  model.generator = @modelGenerator;

end

% The model's likelihood function.
function y = modelPDF(data, p1, p2)
    y = vonmisespdf(data.errors(:),p1,p2);
end

% The model's random number generator function
function r = modelGenerator(parameters, dims, displayInfo)
  r = vonmisesrnd(parameters{1}, parameters{2}, dims);
end

