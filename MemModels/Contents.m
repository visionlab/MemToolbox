% MEMMODELS
%
% One component models:
%   AllGuessingModel       - only guessing
%   NoGuessingModel        - just precision, no guessing
%
% Mixture models:
%   StandardMixtureModel   - guess rate, precision
%   SwapModel              - guess rate, precision and swaps to other items.
%   VariablePrecisionModel - guess rate and variabile precision
%
% Models parameterized based on set size:
%   SlotModel              - capacity K, precision sd (no benefit when K>setsize)
%   SlotPlusResourcesModel - capacity K and precision sd (more juice when K>setsize)
%
% Models that depend on delay duration:
%   ExponentialDecayModel  - capacity K and sd, plus objects drop out over time
%
% Model wrappers:
%   WithBias               - adds a bias terms (mu) to any model
%   FixParameterValue      - fix any parameter in a model to a specific value
%   Orientation            - converts a model to use a 180 degree space 
%   TwoAFC                 - converts a model so that can be fit to 2afc data
%
