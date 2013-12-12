% VARIABLEPRECISIONMODEL_GAMMAPRECISION returns a structure for a variable precision mixture model
% in which the precision of observers' reports are assumed to be
% distributed as a gamma distribution.
%
% I've parameterized the gamma with a mode and SD, rather than the more
% traditional shape and rate, because this results in much better behaved
% posterior distributions and more interpretable parameters.
%
function model = VariablePrecisionModel_GammaPrecision()
  model.name = 'Variable precision model (gamma over precision)';
	model.paramNames = {'g',  'modePrecision', 'sdPrecision'};
	model.lowerbound = [0 0.001 0.001]; % Lower bounds for the parameters
	model.upperbound = [1 100 100]; % Upper bounds for the parameters
	model.movestd = [0.02, 0.05, 0.05];
	model.pdf = @vp_pdf;
  model.modelPlot = @model_plot;
	model.start = [0.0, 0.001, 0.1;
                 0.2, 0.01, 0.2;
                 0.1, 0.002, 0.05;
                 0.2, 0.002, 0.1];

  % To specify a prior probability distribution, change and uncomment
  % the following line, where p is a vector of parameter values, arranged
  % in the same order that they appear in model.paramNames:
  % model.prior = @(p) (1);

  % For speed, calculate these all out here
  precisionsSumOver = logspace(-4, -0.5, 500);
  kValues = deg2k(sqrt(1./precisionsSumOver))';
  baseK = log(besseli(0, kValues, 1)) + kValues;
  lastX = [];

  function y = vp_pdf(data,g,modePrecision,sdPrecision)
    % Probability of each of these
    scale = (2*sdPrecision^2) / (modePrecision+sqrt(modePrecision^2+4*sdPrecision^2));
    shape = 1 + modePrecision*(1/scale);
    probEachPrec = gampdf(precisionsSumOver, shape, scale);
    probEachPrec = probEachPrec./sum(probEachPrec);

    if length(data.errors)~=length(lastX) || any(data.errors~=lastX)
      % Calculate pdf for each precision; only do if the data is different than
      % last time
      x = repmat(data.errors(:), [1 length(kValues)]);
      k = repmat(kValues', [length(data.errors) 1]);
      newBaseK = repmat(baseK', [length(data.errors) 1]);
      model.v = exp((k.*cos((pi/180)*x)) - (log(360) + newBaseK));
      lastX = data.errors;
    end

    % Make final model prediction and sum
    probDataUnderThisNormal = (1-g).*model.v + (g).*1/360;
    probEachPrecBig = repmat(probEachPrec, [size(probDataUnderThisNormal,1), 1]);
    y = sum(probDataUnderThisNormal.*probEachPrecBig,2);
  end

  % Use our custom modelPlot to make a higher-order distribution plot
  function figHand = model_plot(data, params, varargin)
    figHand = figure();
    if isstruct(params) && isfield(params, 'vals')
      maxParams = MCMCSummarize(params, 'maxPosterior');
      params = params.vals(randsample(size(params.vals,1), 100),:);
    else
      maxParams = params;
    end
    set(gcf, 'Color', [1 1 1]);
    x = precisionsSumOver;
    for i=1:size(params,1)
      modePrecision = params(i,2);
      sdPrecision = params(i,3);
      scale = (2*sdPrecision^2) / (modePrecision+sqrt(modePrecision^2+4*sdPrecision^2));
      shape = 1 + modePrecision*(1/scale);
      y = gampdf(precisionsSumOver, shape, scale);
      plot(x, y, 'Color', [0.54, 0.61, 0.06]); hold on;
    end
    modePrecision = maxParams(2);
    sdPrecision = maxParams(3);
    scale = (2*sdPrecision^2) / (modePrecision+sqrt(modePrecision^2+4*sdPrecision^2));
    shape = 1 + modePrecision*(1/scale);
    y = gampdf(precisionsSumOver, shape, scale);
    plot(x, y, 'k', 'LineWidth', 3);
    title('Higher-order distribution', 'FontSize', 14);
    xlabel('Precision', 'FontSize', 14);
    ylabel('Probability', 'FontSize', 14);
  end
end

