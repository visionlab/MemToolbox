function PlotModelFitInteractive_Example()
  data = MemData(1);
  model = StandardMixtureModelWithBias();
  PlotModelFitInteractive(model, [0 .5 10], data);
end