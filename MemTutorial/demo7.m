data = MemDataset(1);

% First model:
model1 = StandardMixtureModel();
MemFit(data,model1);

% Second model:
model2 = StandardMixtureModel('Bias', true);
MemFit(data,model2);

% Now compare:
MemFit(data, {model1, model2});


% Third model:
model3 = VariablePrecisionWithBiasModel();
MemFit(data,model3)

% Now compare:
MemFit(data, {model2, model3});