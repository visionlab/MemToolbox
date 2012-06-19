% TwoAFCMixtureModel returns a structure for a two-component mixture model
% that can be fit to 2afc data
% Requires two fields in data:
%   data.afcCorrect - a sequence of zeros and ones, saying whether observers
%        got a 2afc correct or incorrect
%   data.changeSize - size in degrees of the difference between correct and
%        foil item in 2AFC

function model = TwoAFCMixtureModel(minGuessRate)
  % Set minimum guess rate if we know that subjects will always be
  % guessing more than a certain proportion of the time
  if nargin < 1
    minGuessRate = 0;
  end
  
  % Take standard mixture model
  model = StandardMixtureModelNoBiasKappa();
  model.upperbound = [1 100];
  model.lowerbound = [minGuessRate 0];
  
  % ... and change pdf
  model.pdf = @Mixture2AFCpdf;
end

function p = Mixture2AFCpdf(data, g, k) 
  thetas = vonmisescdf(deg2rad(data.changeSize./2), 0, k).*(1-g) + g/2;
  p = binopdf(data.afcCorrect, 1, thetas);
end
