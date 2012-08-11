% MEMMODELS
%
% One component models:
%   AllGuessingModel       - only guessing
%   NoGuessingModel        - just fit precision, no guessing
%
% Mixture models:
%   StandardMixtureModel   - guess rate, precision and (optional) bias.
%   SwapModel              - guess rate, precision and swaps to other items.
%   VariablePrecisionModel - a StandardMixtureModel with higher-order variability (in the precision)
%
% Models parameterized based on set size:
%   SlotModel              - capacity K, precision sd (no benefit when K>setsize)
%   SlotPlusResourcesModel - capacity K and precision sd (more juice when K>setsize)
%
% Models that depend on delay duration:
%   ExponentialDecayModel  - a model where objects drop out over time
%
% Model wrappers:
%   WithBias               - adds a bias terms (mu) to a model
%   Orientation            - converts a model to use a 180 degree space 
%   TwoAFC                 - converts a model so that can be fit to 2afc data
%
