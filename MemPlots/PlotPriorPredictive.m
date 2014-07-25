%PLOTPRIORPREDICTIVE Show data sampled from the model's prior
% it requires a data struct so that it knows how many trials to sample (and
% for models that require it, what distractors to imagine, etc).
%
%   figHand = PlotPriorPredictive(model, data, [optionalParameters])
%
% Optional parameters:
%  'NumberOfBins' - the number of bins to use in display the data. Default
%  55.
%
%  'NumSamplesToPlot' - how many prior samples to show in the prior
%  predictive plot. Default is 48.
%
%  'PdfColor' - the color to plot the model fit with.
%
%  'NewFigure' - whether to make a new figure or plot into the currently
%  active subplot. Default is false (e.g., plot into current plot).
%
function figHand = PlotPriorPredictive(model, data, varargin)
  % Show data sampled from the model with the actual data overlayed, plus a
  % difference plot.
  args = struct('NumSamplesToPlot', 48, 'NumberOfBins', 55, ...
    'PdfColor', [0.54, 0.61, 0.06], 'NewFigure', true);

  % Figure options
  args = parseargs(varargin, args);
  if args.NewFigure, figHand = figure(); else figHand = []; end

  % Sample from pr ior
  priorModel = EnsureAllModelMethods(model);
  priorModel.pdf = @(data, varargin)(1);
  priorModel.logpdf = @(data, varargin)(0);
  priorSamples = MCMC([], priorModel, 'Verbosity', 0, ...
    'PostConvergenceSamples', args.NumSamplesToPlot);

  % What kind of data to sample
  x = linspace(-180, 180, args.NumberOfBins)';
  if isfield(data, 'errors')
     nSamples = numel(data.errors);
  else
     nSamples = numel(data.afcCorrect);
  end

  % Plot samples
  set(gcf, 'Color', [1 1 1]);
  curFigure = gcf;
  sampTime = tic();
  curHandle = [];
  for i=1:args.NumSamplesToPlot

    % Generate random data from this distribution with these parameters
    asCell = num2cell(priorSamples.vals(i,:));
    yrep = SampleFromModel(model, asCell, [1 nSamples], data);
    if i==1 && toc(sampTime)>(5.0/args.NumSamplesToPlot) % if it will take more than 5s...
      curHandle = awaitbar(i/args.NumSamplesToPlot, ...
        'Sampling to get prior predictive distribution...');
    elseif ~isempty(curHandle)
      if awaitbar(i/args.NumSamplesToPlot, curHandle)
        break;
      end
      set(0, 'CurrentFigure', curFigure);
    end

    % Bin data
    normalizedYRep = getNormalizedBinnedReplication(yrep, data, x);
    if any(isnan(normalizedYRep))
      hSim = plot(x, normalizedYRep, 'x-', 'Color', args.PdfColor);
      if verLessThan('matlab','8.4.0')
        set(hSim, 'LineSmoothing', 'on');
      end      
    else
      hSim = patchline(x, normalizedYRep, 'LineStyle', '-', 'EdgeColor', ...
        args.PdfColor, 'EdgeAlpha', 0.15);
      if verLessThan('matlab','8.4.0')
        set(hSim, 'LineSmoothing', 'on');
      end
    end
    hold on;
  end
  if ishandle(curHandle)
    close(curHandle);
  end
  title('Simulated data from model prior', 'FontSize', 13);
  if isfield(model, 'isOrientationModel')
    xlim([-90 90]);
  else
    xlim([-180 180]);
  end
  xlabel('Error (degrees)');

  % Allow the user to limit this figure to any subset of the data
  if ~isempty(figHand)
    CreateMenus(data, @redrawFig);
  end
  function redrawFig(whichField, whichValue)
    if strcmp(whichField, 'all')
      cla;
      PlotPriorPredictive(model, data, ...
        'NewFigure', false, 'NumSamplesToPlot', args.NumSamplesToPlot, ...
        'NumberOfBins', args.NumberOfBins, 'PdfColor', args.PdfColor, ...
        'UseModelComparisonPrior', args.UseModelComparisonPrior);
    elseif sum(ismember(data.(whichField),whichValue)) > 0
      [datasets,conditionOrder] = SplitDataByField(data, whichField);
      newData = datasets{ismember(conditionOrder,whichValue)};
      cla;
      PlotPriorPredictive(model, newData, ...
        'NewFigure', false, 'NumSamplesToPlot', args.NumSamplesToPlot, ...
        'NumberOfBins', args.NumberOfBins, 'PdfColor', args.PdfColor, ...
        'UseModelComparisonPrior', args.UseModelComparisonPrior);
    end
  end
end

function y = getNormalizedBinnedReplication(yrep, data, x)
  if isfield(data, 'errors')
    y = hist(yrep, x)';
    y = y ./ sum(y(:));
  else
    for i=1:length(x)
      distM(:,i) = (data.changeSize - x(i)).^2;
    end
    [tmp, whichBin] = min(distM,[],2);
    for i=1:length(x)
      y(i) = mean(yrep(whichBin==i));
    end
  end
end
