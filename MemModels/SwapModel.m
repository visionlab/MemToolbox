% SWAPMODEL returns a structure for a three-component model
% with guesses and swaps. Based on Bays, Catalao, & Husain (2009) model.
% This is an extension of the StandardMixtureModel that allows for
% observers' misreporting incorrect items.
%
% In addition to data.errors, the data struct should include:
%   data.distractors, Row 1: distance of distractor 1 from target
%   ...
%   data.distractors, Row N: distance of distractor N from target
%
% This model includes a custom .modelPlot function that is called by
% MemFit(). This function produces a plot of the distance of observers'
% reports from the distractors, rather than from the target, as in Bays,
% Catalao & Husain (2009), Figure 2B.
%
function model = SwapModel(varargin)
  % Default: Don't include a bias term
  args = struct('Bias', false); 
  args = parseargs(varargin, args);
  
  if args.Bias
    model = SwapWithBiasModel();
  elseif ~args.Bias
    model = SwapNoBiasModel();
  end
end
