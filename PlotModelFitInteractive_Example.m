function PlotModelFitInteractive_Example()
  d = load('data.mat');
  model = StandardMixtureModelWithBias();
  PlotModelFitInteractive(model, [0 .5 10], d.data(:));
end