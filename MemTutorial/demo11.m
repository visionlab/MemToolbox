% MemToolbox demo 11: Fitting models that require data from multiple set sizes
clear all;
data.errors = [-12 3 38 27 -29 21 -22 52 -2 -19 21 17 38 6 34 25 44];
data.n = [2 2 2 2 2 2 3 3 3 3 3 3 4 4 4 4 4];
MemFit(data, SlotsPlusAveragingModel)