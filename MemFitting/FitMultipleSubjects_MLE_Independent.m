% [m se ps] = FitMultipleSubjects_Independent({s1Data, s2Data, ...}, model) 
% uses maximum likelihood estimation to get parameter estimates for each
% of the subject's data; the output averages across subjects. Data for each 
% subject should be specfied as a structure array, and the model is the one 
% used for each subject. M is the model parameter estimates averaged across 
% subjects. SE is the standard error across subjects. PS is a matrix with the 
% value of each parameter (columns) for each participant (rows).

function [paramsMean, paramsSE, ...
    paramsSubs] = FitMultipleSubjects_MLE_Independent(data, model)
  for i=1:length(data)
    paramsSubs(i,:) = MLE(data{i}, model);
  end
  paramsMean = mean(paramsSubs);
  paramsSE = std(paramsSubs)./sqrt(length(data));
end