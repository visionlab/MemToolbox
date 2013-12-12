% ENSEMBLEINTEGRATIONMODEL integration with distractors shifts reports
% Based on the model of Brady & Alvarez (2011), this model shifts
% observers' representations towards the mean values of the distractors,
% with more shift occuring if the distractors are closer together/closer to
% the target.
%
% In addition to data.errors, the data struct should include:
%   data.distractors, Row 1: distance of distractor 1 from target
%   ...
%   data.distractors, Row N: distance of distractor N from target
%
% Note that these values are the *distance from the correct answer*, not
% the actual color values of the distractors. They should thus range from
% -180 to 180.
%
% data.distractors may contain NaNs. For example, if you have data with
% different set sizes, data.distractors should contain as many rows as you
% need for the largest set size, and for displays with smaller set sizes
% the last several rows can be filled with NaNs.
%
% This is a simplified version of the Brady & Alvarez (2011) model, in that
% it does not take into account noise in the sampling of the distractors,
% and allows only a single level of integration (with all distractors).
%
function model = EnsembleIntegrationModel()
  model.name = 'Ensemble integration model';
	model.paramNames = {'g', 'sd', 'samples'};
	model.lowerbound = [0 0 0]; % Lower bounds for the parameters
	model.upperbound = [1 Inf Inf]; % Upper bounds for the parameters
	model.movestd = [0.02, 0.1, 0.05];
  model.pdf = @IntegrationModelPDF;
	model.start = [0.2, 10, 1;  % g, B, sd
    0.4, 15, 0;  % g, B, sd
    0.1, 20, 5]; % g, B, sd

  % To specify a prior probability distribution, change and uncomment
  % the following line, where p is a vector of parameter values, arranged
  % in the same order that they appear in model.paramNames:
  % model.prior = @(p) (1);

  function p = IntegrationModelPDF(data, g, sd, samples)
    if(~isfield(data, 'distractors'))
      error('The integration model requires that you specify the distractors.')
    end

    data.distractors(end+1, :) = 0; % (target is always at zero)
    ensembleMean = nanmean(data.distractors);
    ensembleStd = nanstd(data.distractors);
    w = (1./(ensembleStd.^2)) ./ ((1./(ensembleStd.^2)) + (samples./(sd.^2)));
    shiftedMean = w.*ensembleMean + (1-w)*0;  % (target is always at zero)

    p = (1-g).*vonmisespdf(data.errors(:), shiftedMean(:), deg2k(sd)) ...
      + (g).*1/360;
  end
end

