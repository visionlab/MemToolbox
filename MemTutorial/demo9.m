% MemToolbox demo 9: Fitting 2AFC or change detection data
clear all;
data.changeSize = [180 180 180 180 180 180 20 20 20 20 20 20];
data.afcCorrect = [1 1 1 1 1 1 0 0 0 1 1 1];
MemFit(data);
