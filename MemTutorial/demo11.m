% MemToolbox demo 11: Fitting models that require data from multiple set sizes
clear all;
data = MemDataset(10)
data.n
MemFit(data, SlotsPlusAveragingModel)
