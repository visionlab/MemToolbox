% HIERARCHICAL fits many subjects data at once using a hierarchical model
% over subjects. This function wraps a model+data and turns it into a new
% model which can then be fit with MAP, MLE or MCMC.
%
%    hModel = Hierarchical(data, model)
%
% We treat all of the subjects' parameters as having been samples from
% an underlying population normal distribution and infer the global mean
% and SD for each parameter. This causes shrinkage of each
% subject's parameter estimates towards the population mean and totally
% eliminates outrageous parameter values (e.g., subjects with high guess
% rates getting g=0, SD=200). Furthermore, rather than discarding
% differences in within-subject measurement errors (some subjects data
% constrain the parameters better than others), we can make use of these
% differences in automatically weighting the more reliable subjects'
% estimates more.
%
% Warning: Our fitting functions aren't quite up to the level of doing this
% modeling for >10-15 subjects right now (or at least, it sometimes takes
% forever).
%
% Example usage:
%
%   data = {MemDataset(1), MemDataset(2), MemDataset(3)};
%   hModel = Hierarchical(data, StandardMixtureModel());
%   params = MAP(data, hModel);
%   fit = OrganizeHierarchicalParams(hModel, params);
%
function newModel = Hierarchical(data, model)
  nParams = length(model.paramNames);
  nSubs = length(data);

  % Check model
  model = EnsureAllModelMethods(model);

  % Format: Take [param1, param2] and turn into [param1_groupSD,
  % param2_groupSD, param1_groupMean, param2_groupMean, param1_subject1,
  % param2_subject1, ... param1_subjectN, params2_subjectN]
  newModel.paramNames = [strcat('sd_',model.paramNames), ...
    strcat('mn_',model.paramNames), ...
    repmat(model.paramNames, [1 nSubs])];
  newModel.lowerbound = [zeros(size(model.lowerbound)) ...
    repmat(model.lowerbound, [1, nSubs+1])];
  newModel.upperbound = [inf(size(model.upperbound)) ...
    repmat(model.upperbound, [1, nSubs+1])];

  % Start off by assuming population mean is same as subject means, and
  % population SD is one half of subject means
  newModel.movestd = [model.movestd./3 ...
    repmat(model.movestd, [1, nSubs+1])];

  % Initialize with means from independent fits
  start = FitMultipleSubjects_MAP(data, model);
  start.paramsSubs = start.paramsSubs';
  newModel.start  = [std(start.paramsSubs,[],2)' start.paramsMean start.paramsSubs(:)'];
  meanChoices = [start.paramsMean; start.paramsSubs'];
  for i=2:4
    means = meanChoices(randi(size(meanChoices,1)), :);
    stdevs = std(start.paramsSubs,[],2)';
    newStart = [stdevs means];
    for j=1:nSubs
      while true
        paramVals = randn(1,length(means)).*stdevs+means;
        if ~any(paramVals>model.upperbound | paramVals<model.lowerbound)
          break;
        end
      end
      newStart = [newStart paramVals];
    end
    newModel.start(i,:) = newStart;
  end

  % Create logpdf and logprior
  newModel.logprior = @(params) HierarchicalPrior(model.prior, params, nParams);
  newModel.logpdf = @(varargin) HierarchicalPDF(model.pdf, ...
    nParams, varargin);

  % Original info
  newModel.originalNParams = nParams;
end

function p = HierarchicalPrior(oldPrior, params, nParams)
  popParamsStd = GetParams(1);
  popParamsMean = GetParams(2);

  % Population means should have same prior constraints as each individual
  % parameter
  p = sum(log(oldPrior(popParamsMean)));

  % Sum each of the priors from individual parameters
  nSubs = (length(params)/nParams) - 2*nParams;
  for i=1:length(nSubs)
    subjectParams = GetParams(i+2);
    p = p + sum(log(oldPrior(subjectParams)));
  end

  % Fetch a certain set of parameters from params (e.g., fetch
  % param1_subject1 and param2_subject1)
  function c = GetParams(which)
    c = params((1+nParams*(which-1)):(0+nParams*which));
  end
end

function likeVal = HierarchicalPDF(oldPdf, nParams, varargin)
  data = varargin{1}{1};
  popParamsStd = GetParams(1);
  popParamsMean = GetParams(2);

  % Likelihood is each subject's likelihood times the likelihood of that
  % subject's parameters under the global normal distribution
  likeVal = 0;
  for i=1:length(data)
    subjectParams = GetParams(i+2);
    likeVal = likeVal + ...
      sum(log(oldPdf(data{i}, subjectParams{:})));
    likeVal = likeVal + ...
      sum(log(normpdf([subjectParams{:}], ...
      [popParamsMean{:}], [popParamsStd{:}])));
  end
  if isnan(likeVal) || isinf(likeVal)
    likeVal = double(intmin());
  end

  % Fetch a certain set of parameters from varargin (e.g., fetch
  % param1_subject1 and param2_subject1)
  function params = GetParams(which)
    params = varargin{1}((2+nParams*(which-1)):(1+nParams*which));
  end
end


