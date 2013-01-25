% CONTINUOUSRESOURCEMODEL returns a structure for a continuous resource model,
% very much like the one from Bays & Husain (2008).
%
% Usage:
%   data = load('slot-model-simulate.mat');
%   MemFit(data, ContinuousResourceModel);
%
function model = ContinuousResourceModel()
  model.name = 'Continuous resource model';
  model.paramNames = {'lapse','k', 'bestSD'};
  model.lowerbound = [0 0 0]; % Lower bounds for the parameters
  model.upperbound = [1 10 50]; % Upper bounds for the parameters
  model.movestd = [0.02, 0.1, 1];
  model.pdf = @crpdf;
  model.start = [0.2, 0.1, 10;  % lapse, k, bestSD
                 0.4, 1, 2;
                 0.1, 10, 20];
end

function y = crpdf(data,lapse,k,bestSD)
  propResources = 1./data.n(:);
  pMax = 1./(bestSD.^2);
  precision = (propResources .^ k) .* pMax;
  sd = sqrt(1./precision);

  y = (1-lapse) .* vonmisespdf(data.errors(:),0,deg2k(sd(:))) + ...
        (lapse) .* 1/360;
end