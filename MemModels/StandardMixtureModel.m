% STANDARDMIXTUREMODEL returns a structure for a two-component mixture model
% with guess rate g and standard deviation sd (specified in degrees). 
%
% The function takes two optional arguments, 'Bias', and 'UseKappa', each of which
% can be set to true or false. StandardMixtureModel('Bias', true) returns the 
% standard mixture model with a bias parameter that controls the central
% tendency of the error distribution. StandardMixtureModel('UseKappa', true)
% returns the standard mixture model parameterized over kappa, a dispersion
% parameter of the von Mises distribution that is sometimes used instead of
% its standard deviation.
%
function model = StandardMixtureModel(varargin)
  % Default: Don't include a bias term, and use SD, not Kappa
  args = struct('Bias', false, 'UseKappa', false); 
  args = parseargs(varargin, args);
  
  if ~args.Bias && ~args.UseKappa
    model = StandardMixtureModelNoBiasSD();
  elseif ~args.Bias && args.UseKappa
    model = StandardMixtureModelNoBiasKappa();
  elseif args.Bias && ~args.UseKappa
    model = StandardMixtureModelWithBiasSD();
  else
    model = StandardMixtureModelWithBiasKappa();
  end
end
