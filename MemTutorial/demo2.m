% MemToolbox demo 2: Choosing a different model
clear all;
model = WithBias(StandardMixtureModel());
errors = [-89, 29, -2, 6, -16, 65, 43, -12, 10, 0, 178, -42, 52, 1, -2];
MemFit(errors, model);