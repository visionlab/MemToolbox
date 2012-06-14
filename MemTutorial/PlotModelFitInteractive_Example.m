function PlotModelFitInteractive_Example()
  data = load('MemData/data.mat');
  model = StandardMixtureModelWithBias();
  PlotModelFitInteractive(model, [0 .5 10], data);
end