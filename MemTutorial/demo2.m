errors = [-89, 29, -2, 6, -16, 65, 43, -12, 10, 0, 178, -42, 52, 1, -2];
model = WithBias(StandardMixtureModel());
MemFit(errors, model);