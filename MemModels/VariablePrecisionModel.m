% VARIABLEPRECISIONMODEL returns a structure for an infinite scale mixture.
% In such a model, the standard deviations of observers' reports are assumed
% to be themselves drawn from a higher-order variability distribution, 
% rather than always fixed.
%
% The default model assumes observers' standard deviations are distributed
% according to a Gaussian distribution, and there is no bias in observers'
% responses.  However, the function takes two optional arguments, 'Bias', 
% and 'HigherOrderDist'. VariablePrecisionModel('Bias', true) returns the 
% Gaussian variable precision model with a bias parameter that controls the 
% central tendency of the error distribution. 
% StandardMixtureModel('HigherOrderDist', 'Gamma') returns a model where
% the higher-order distribution is assumed to be Gamma, rather than Gaussian.
%
function model = VariablePrecisionModel(varargin)
  % Default: Don't include a bias term, and a Gaussian over SDs as
  % higher-order distribution
  args = struct('Bias', false, 'HigherOrderDist', 'Gaussian'); 
  args = parseargs(varargin, args);
  
  if ~args.Bias
    if strcmp(args.HigherOrderDist, 'Gaussian')
      model = VariablePrecisionModel_Gaussian();
    elseif strcmp(args.HigherOrderDist, 'Gamma')
      model = VariablePrecisionModel_Gamma();
    end
  else
    if strcmp(args.HigherOrderDist, 'Gaussian')
      model = VariablePrecisionModel_Gaussian_WithBias();
    elseif strcmp(args.HigherOrderDist, 'Gamma')
      model = VariablePrecisionModel_Gamma_WithBias();
    end    
  end
end
