function PlotModelFitInteractive_Example()
  data = MemDataset(1);
  model = WithBias(StandardMixtureModel);
  PlotModelFitInteractive(model, [0, .5, 10], data);
end
