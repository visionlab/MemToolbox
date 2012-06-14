data = MemData(1);

model1 = StandardMixtureModel;
MemFit(data,model1)

model2 = StandardMixtureModelWithBias;
MemFit(data,model2)

MemFit(data, {model1, model2})

% model3 = StudentsTModelWithBias;
% MemFit(data,model3)

% MemFit(data, {model1, model2});