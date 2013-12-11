% FIXPARAMETERVALUE fix any parameter in a model to a specific value
%
%    model = FixParameterValue(model, parameter, value)
%
% The first parameter is the model to modify, the second is either the name
% of the parameter (e.g., 'g') or the number of the parameter (e.g., 1) to
% fix. The third is what value to assign that parameter.
%
% Thus, to take the StandardMixtureModel, which has a guess rate (g) and
% standard deviation (sd) parameter, and make a new model with guess rate
% fixed at 0.5 but a variable standard deviation, use:
%
%   model = FixParameterValue(StandardMixtureModel, 'g', 0.5)
%
function model = FixParameterValue(model, parameter, value)
  % turn parameter into an integer index if it is a string
  if ischar(parameter)
    parameter = find(strcmp(model.paramNames, parameter));
    if isempty(parameter)
      error('Couldn''t find that parameter!');
    end
  end

  % Adjust model functions
  model.originalNumParams = length(model.paramNames);
  model.allButFixed = (1:model.originalNumParams) ~= parameter;
  model.name = sprintf('%s with %s=%g', model.name, ...
    model.paramNames{parameter}, value);
  model.paramNames(parameter) = [];
  model.lowerbound(parameter) = [];
  model.upperbound(parameter) = [];
  model.movestd(parameter) = [];
  model.start(:, parameter) = [];

  % Adjust pdf
  model.oldPdf = model.pdf;
  model.pdf = @NewPDF;
  function p = NewPDF(data, varargin)
    newP(model.allButFixed) = varargin;
    newP{parameter} = value;
    p = model.oldPdf(data, newP{:});
  end

  % Adjust prior
  if isfield(model, 'prior')
    model.oldPrior = model.prior;
    model.prior = @NewPrior;
  end
  function r = NewPrior(p)
    newP(model.allButFixed) = p;
    newP(parameter) = value;
    r = model.oldPrior(newP);
  end

  % Adjust modelPlot
  if isfield(model, 'modelPlot')
    model.oldModelPlot = model.modelPlot;
    model.modelPlot = @NewModelPlot;
  end
  function r = NewModelPlot(data, params, varargin)
    if isstruct(params) && isfield(params, 'vals')
      newP = params;
      cnt = 1;
      for i=1:model.originalNumParams
        if i~=parameter
          newP.vals(:,i) = params.vals(:,cnt);
          cnt=cnt+1;
        else
          newP.vals(:,i) = value;
        end
      end
    else
      newP(model.allButFixed) = params;
      newP(parameter) = value;
    end
    r = model.oldModelPlot(data, newP, varargin);
  end

  % Remove any generator function - model must be sampled the hard way
  if isfield(model, 'generator')
    model = rmfield(model, 'generator');
  end
end
