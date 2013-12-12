% MemToolbox demo 16: Advanced MCMC diagnostics
clear all;
data.errors = [-10 0 10];
model = StandardMixtureModel();

posteriorSamples = MCMC(data, model, 'ConvergenceVariance', Inf, ...
                                     'BurnInSamplesBeforeCheck', 5000, ...
                                     'PostConvergenceSamples', 15000)

figHand = PlotConvergence(posteriorSamples, model.paramNames);
