% STANDARDMIXTUREMODEL returns a structure for a two-component mixture model
% with guess rate g and standard deviation sd (specified in degrees).
%
% The function takes an optional argument, 'UseKappa', which can be set to
% true or false. The default is 'false' (use SD, not Kappa).
% StandardMixtureModel('UseKappa', true) returns the standard mixture model
% parameterized over kappa, a dispersion parameter of the von Mises
% distribution that is sometimes used instead of its standard deviation.
%
function model = StandardMixtureModel(varargin)
  % Default: use SD, not Kappa
  args = struct('UseKappa', false);
  args = parseargs(varargin, args);

  if args.UseKappa
    model = StandardMixtureModel_Kappa();
  else
    model = StandardMixtureModel_SD();
  end
end
