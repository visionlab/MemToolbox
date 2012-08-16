% MemToolbox demo 5: Model comparison
clear all;
data = MemDataset(1);

% First model:
model1 = StandardMixtureModel();
MemFit(data,model1);

% Second model:
model2 = WithBias(StandardMixtureModel);
MemFit(data,model2);

% Now compare:
MemFit(data, {model1, model2});

% Specify a prior for model comparison
model = StandardMixtureModel();
model.priorForMC = @(p) (betapdf(p(1), 1.25, 2.5) * ... % for g
                         lognpdf(deg2k(p(2)), 2.5, 0.5)); % for sd

% Plot the noninformative prior
PlotPrior(model)

% Plot the prior used for model comparsion
PlotPrior(model, 'UseModelComparisonPrior', true)