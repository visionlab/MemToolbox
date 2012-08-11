% VARIABLEPRECISIONMODEL returns a structure for an infinite scale mixture.
% In such a model, the standard deviations of observers' reports are assumed
% to be themselves drawn from a higher-order variability distribution, 
% rather than always fixed.
%
% The default model assumes observers' standard deviations are distributed
% according to a Gaussian distribution.  However, the function takes an
% optional argument 'HigherOrderDist'. StandardMixtureModel('HigherOrderDist',
% 'Gamma') returns a model where the higher-order distribution is assumed 
% to be Gamma, rather than Gaussian.
%
function model = VariablePrecisionModel(varargin)
  % Default: Don't include a bias term, and a Gaussian over SDs as
  % higher-order distribution
  args = struct('HigherOrderDist', 'Gaussian'); 
  args = parseargs(varargin, args);
  
  if strcmp(args.HigherOrderDist, 'Gaussian')
    model = VariablePrecisionModel_Gaussian();
  elseif strcmp(args.HigherOrderDist, 'Gamma')
    model = VariablePrecisionModel_Gamma();
  end
end
