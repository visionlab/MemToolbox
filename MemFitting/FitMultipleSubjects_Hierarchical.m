% FitMultipleSubjects_Hierarchical({subject1Data, subject2Data, subject3Data...}, model)
% 
% The right way to do inference, in theory -- treat all subjects parameters
% as having been samples from an underlying normal distribution and infer
% the global mean and SD for each parameter. This causes shrinkage of each
% subjects' parameter estimates towards the population mean and totally
% eliminates outrageous parameter values (e.g., subjects with high guess
% rates getting g=0, SD=200). 
%
% However, our MCMC function isn't quite up to the level of doing this
% modeling for >7-8 subjects right now (or at least, even after it
% converges it has very low acceptance rates, so we should definitely be
% taking many more posterior samples and trimming some to remove
% autocorrelation).
%
% Example usage:
%   data{1} = load('MemData/3000+trials_3items_SUBJ#1.mat');
%   data{2} = load('MemData/3000+trials_3items_SUBJ#2.mat');
%   paramsMean = FitMultipleSubjects_Hierarchical(data, model);
%
function [paramsMean, paramsSE, ...
    paramsSubs] = FitMultipleSubjects_Hierarchical(data, model)
  
  nParams = length(model.paramNames);
  nSubs = length(data);
  
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
  
  % By default assume population mean is same as subject means, and
  % population SD is one half of subject means
  newModel.movestd = [model.movestd./3 ...
    repmat(model.movestd, [1, nSubs+1])];
  
  % Initialize with means from independent fits
  [startMean, startSE, startSubs] =  ...
    FitMultipleSubjects_MLE_Independent(data, model);
  startSubs = startSubs';
  newModel.start  = [startSE*sqrt(length(data)) startMean startSubs(:)'];
  newModel.start = [newModel.start; newModel.start*0.90; newModel.start*1.10];
  
  % Create logpdf
  newModel.logpdf = @(varargin) HierarchicalPDF(model.pdf, ...
    nParams, varargin);
  
  % In theory we could do this with MLE, but in practice it is not so good
  % at searching this space. So do MCMC, with twice as many chains as
  % usual:
  posteriorSamples = MCMC_Convergence(data, newModel, 2);
  params = MCMCSummarize(posteriorSamples, 'posteriorMean');
  % MCMC_Plot(posteriorSamples, newModel.paramNames);
  
  % Convert back to separate params
  paramsSubs = reshape(params', nParams, [])';
  paramsSE = paramsSubs(1,:)./sqrt(nSubs);
  paramsMean = paramsSubs(2,:);
  paramsSubs(1:2,:)=[];
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
  
  % Fetch a certain set of parameters from varargin (e.g., fetch
  % param1_subject1 and param2_subject1)
  function params = GetParams(which)
    params = varargin{1}((2+nParams*(which-1)):(1+nParams*which));
  end
end


