% FITMULTIPLESUBJECTS_MAP fits many subjects data using MAP
% estimation. This is just a shortcut for a loop over subjects that calls
% MAP for each one.
%
%  fit = FitMultipleSubjects_MAP(data, model)
%
% Uses maximum a posterior estimation to get parameter estimates for each
% of the subject's data; the output averages across subjects. Data for each
% subject should be specfied as a structure array, and the model is the one
% used for each subject. paramsMean is the model parameter estimates averaged
% across subjects. paramsSE is the standard error across subjects.
% paramsSubs is a matrix with the value of each parameter (columns) for
% each participant (rows).
%
% Example usage:
%   data{1} = MemDataset(1);
%   data{2} = MemDataset(2);
%   fit = FitMultipleSubjects_MAP(data, model);
%
function fit = FitMultipleSubjects_MAP(data, model)
  for i=1:length(data)
    fit.paramsSubs(i,:) = MAP(data{i}, model);
  end
  fit.paramsMean = mean(fit.paramsSubs);
  fit.paramsSE = std(fit.paramsSubs)./sqrt(length(data));
end
