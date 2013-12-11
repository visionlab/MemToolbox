% ORIENTATION converts a model to use a 180 degree space rather
%  than a 360 degree space (e.g., to have a "circle" that wraps at 180 deg)
%  This might be useful if you have data where observers reported the
%  orientation of a rotationally symmetric item like a line segment.
%
%  To use it, you need to pass in both a model and also which parameters
%  of that model are in units of degrees -- typically this will be bias
%  and standard deviation -- as these need to be adjusted (as well as
%  the data).
%
% e.g.,
%  model = Orientation(StandardMixtureModel(), 2)
%  or
%  model = Orientation(WithBias(StandardMixtureModel), [1 3])
%  or
%  model = Orientation(SwapModel(), 3)
%
% If you nest this with TwoAFC, Orientation() should go on the inside:
%  e.g.,  model = TwoAFC(Orientation(SwapModel(), 3));
%
% Note that having responses only at binned, regular intervals (e.g.,
% errors of 1, 2, 3 but not 1.2 or 1.1113) can result in overestimates of
% the SD of models, and this can be exacerbated by conversion to a 180
% degree space (which makes the bins twice as big). See Anderson & Awh
% (2012). The plateau in mnemonic resolution across large set sizes
% indicates discrete resource limits in visual working memory.
% Attention, Perception and Psychophysics.
%
function model = Orientation(model, whichParameters)
  % Take model and turn it into a 2AFC-model
  model.name = [model.name ' (for orientation)'];
  model.isOrientationModel = true;
  model.upperbound(whichParameters) = model.upperbound(whichParameters) ./ 2;
  model.lowerbound(whichParameters) = model.lowerbound(whichParameters) ./ 2;

  % Adjust prior
  if isfield(model, 'prior')
    model.oldPrior = model.prior;
    model.prior = @NewPrior;
  end
  function p = NewPrior(params)
    params(whichParameters) = params(whichParameters).*2;
    p = model.oldPrior(params);
  end

  % Adjust generator function
  if isfield(model, 'generator')
    model.oldGenerator = model.generator;
    model.generator = @NewGenerator;
  end
  function s = NewGenerator(params,dims,displayInfo)
    params(whichParameters) = cellfun(@(x){x.*2}, params(whichParameters));
    s = model.oldGenerator(params, dims, displayInfo);
    s = s ./ 2;
  end

  % Adjust pdf -
  % Convert orientation data to a format that is useable in all the models
  model.oldPdf = model.pdf;
  model.pdf = @NewPDF;
  function p = NewPDF(data, varargin)
    if isfield(data, 'errors')
      data.errors = data.errors .* 2;
    end
    if isfield(data, 'distractors')
      data.distractors = data.distractors .* 2;
    end
    if isfield(data, 'changeSize')
      data.changeSize = data.changeSize .* 2;
    end
    varargin(whichParameters) = cellfun(@(x){x.*2}, varargin(whichParameters));
    p = model.oldPdf(data, varargin{:});

    % To make plotting functions work right:
    if isfield(data, 'errors')
      p(data.errors<-180 | data.errors>180) = 0;
    end
    if isfield(data, 'changeSize')
      p(data.changeSize<-180 | data.changeSize>180) = 0;
    end
  end
end
