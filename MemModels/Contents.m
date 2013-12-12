% MEMMODELS
%
% One component models:
%   AllGuessingModel        - only guessing
%   NoGuessingModel         - just precision, no guessing
%
% Mixture models for a single set size:
%   StandardMixtureModel    - guess rate and precision
%   SwapModel               - guess rate, precision and swaps to other items.
%   VariablePrecisionModel  - guess rate and variable precision
%   EnsembleIntegrationModel - integration with distractors shifts reports
%
% Models parameterized based on set size:
%   SlotModel               - capacity and precision (no benefit when cap.>setsize)
%   SlotsPlusResourcesModel - capacity and precision (more juice when cap.>setsize)
%   SlotsPlusAveragingModel - capacity and precision (more slots/item when cap.>setsize)
%   ContinuousResourceModel - capacity juice split among all items equally
%
% Models that depend on delay duration:
%   ExponentialDecayModel   - capacity K and sd, plus objects drop out over time
%
% Model wrappers:
%   WithBias                - adds a bias terms (mu) to any model
%   FixParameterValue       - fix any parameter in a model to a specific value
%   Orientation             - converts a model to use a 180 degree space
%   TwoAFC                  - converts a model so that can be fit to 2afc data
%   WithLapses              - adds inattentional parameter to any model
