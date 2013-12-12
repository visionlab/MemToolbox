% VARIABLEPRECISIONMODEL returns a structure for an infinite scale mixture.
% In such a model, the standard deviations of observers' reports are assumed
% to be themselves drawn from a higher-order variability distribution,
% rather than always fixed.
%
% The default model assumes observers' standard deviations are distributed
% according to a Gaussian distribution.  However, the function takes an
% optional argument 'HigherOrderDist'. VariablePrecisionModel('HigherOrderDist',
% 'GammaSD') returns a model where the higher-order distribution of SD is assumed
% to be Gamma, rather than Gaussian. VariablePrecisionModel('HigherOrderDist',
% 'GammaPrecision') assumes a distribution over precisions (1/Variance) that is
% Gamma, as in van den Berg et al. (2012).
%
function model = VariablePrecisionModel(varargin)
  % Default: Don't include a bias term, and a Gaussian over SDs as
  % higher-order distribution
  args = struct('HigherOrderDist', 'GaussianSD');
  args = parseargs(varargin, args);

  if strcmp(args.HigherOrderDist, 'GaussianSD')
    model = VariablePrecisionModel_GaussianSD();
  elseif strcmp(args.HigherOrderDist, 'GammaSD')
    model = VariablePrecisionModel_GammaSD();
  elseif strcmp(args.HigherOrderDist, 'GammaPrecision')
    model = VariablePrecisionModel_GammaPrecision();
  end
end

