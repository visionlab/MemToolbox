% MixtureModelWithSwaps returns a structure for a three-component model
% with guesses and swaps. Based on Bays et al. 2009 model.

% Data format should be:
%   Row 1: errors (radians), e.g., distance of response from target
%   Row 2: distance of distractor 1 from target
%   ...
%   Row N: distance of distractor N from target

function model = MixtureModelWithSwaps()
  model.name = 'Swap model';
	model.paramNames = {'g', 'B', 'K'};
	model.lowerbound = [0 0 0]; % Lower bounds for the parameters
	model.upperbound = [1 1 Inf]; % Upper bounds for the parameters
	model.movestd = [0.02, 0.02, 0.1];
	model.logpdf = @SwapModelPDF;
	model.start = [0.2, 0.1, 10;  % g, B, K
    0.4, 0.1, 15;  % g, B, K
    0.1, 0.5, 20]; % g, B, K
end

function logLike = SwapModelPDF(data, g, B, K)
  % This could be vectorized entirely but would be less clear; but I assume
  % people will rarely have greater than 8 or so distractors, so the loop
  % is over a relatively small dimension
  if g+B > 1
    logLike = -Inf;
    return;
  end
  errors = data(1,:);
  distractorLocs = data(2:end, :);
  nDistractors = size(distractorLocs,1);
  l = (1-g-B).*vonmisespdf(errors,0,K) + (g).*unifpdf(errors, -pi, pi);
  for i=1:nDistractors
    l = l + (B/nDistractors).*vonmisespdf(errors,distractorLocs(i,:),K);
  end
  logLike = sum(log(l)); 
end