% FitMultipleSubjects_Bootstrap({subject1Data, subject2Data,
%                                       subject3Data...}, model, [nSamples])
% Bootstrapping seems to provide less within-subject noise and better recover
% the population estimate in my simple tests
function [paramsMean, paramsSE, ...
    paramsRaw] = FitMultipleSubjects_MLE_Bootstrap(data, model, nSamples)
  
  % Default number of bootstrap samples
  if nargin<3
    nSamples = 300;
  end
 
  for m=1:nSamples
    curData = [data{randsample(length(data),length(data),true)}];
    paramsRaw(m,:) = MLE(curData, model);
  end
  
  paramsMean = mean(paramsRaw,1);
  paramsSE = std(paramsRaw);
end