% MemToolbox demo 10: Fitting orientation data
clear all;
data.errors = [-12 3 38 27 -29 21 -22 52 -2 -19 21 17 38 6 34 25 44];
MemFit(data, Orientation(WithBias(StandardMixtureModel), [1,3]))
