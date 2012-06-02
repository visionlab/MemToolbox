% FitMultipleSubjects_Independent({subject1Data, subject2Data, subject3Data...}, model)
function [paramsMean, paramsSE, ...
    paramsSubs] = FitMultipleSubjects_MLE_Independent(data, model)
  for i=1:length(data)
    paramsSubs(i,:) = MLE(data{i}, model);
  end
  paramsMean = mean(paramsSubs);
  paramsSE = std(paramsSubs)./sqrt(length(data));
end