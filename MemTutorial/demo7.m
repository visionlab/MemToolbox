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
% XXX : It seems like it would be ideal if we could reparameterize this
% model, so rather than using df and sigma, it uses the scale and shape of
% the gamma instead
model3 = VariablePrecisionWithBiasModel();
MemFit(data,model3)

% Now compare:
MemFit(data, {model2, model3});