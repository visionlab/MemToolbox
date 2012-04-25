% MixtureModel2AFC returns a structure for a two-component mixture model
% that can be fit to 2afc data

% Data format should be:
%   Row 1: binary data -- 1 for correct, 0 for incorrect
%   Row 2: the size, in radians, of the change that observers were shown
% (the difference between color 1 and color 2)

function model = MixtureModel2AFC(minGuessRate)
  % Allow minimum guess rate if we know that subjects will always be
  % guessing more than a certain proportion of the time
  if nargin < 1
    minGuessRate = 0;
  end
  
  % Take standard mixture model
  model = StandardMixtureModel();
  model.upperbound = [1 100];
  model.lowerbound = [minGuessRate 0];
  
  % ... and change pdf
  model.pdf = @Mixture2AFCpdf;
end

function p = Mixture2AFCpdf(data, g, k) 
  thetas = vonmisescdf(data(2,:)./2, 0, k).*(1-g) + g/2;
  p = binopdf(data(1,:), 1, thetas);
end
