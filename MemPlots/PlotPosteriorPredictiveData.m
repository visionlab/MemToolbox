%PLOTPOSTERIORPREDICTIVEDATA Show data sampled from the model with the actual 
% data overlayed, plus a plot of where the two differ. This can be thought
% of as the 'residual' of the data, given the model fit, and is helpful for
% diagnosing bad fits in the model.
%
%   figHand = PlotPosteriorPredictiveData(model, posteriorSamples,...
%                                             data, [optionalParameters])
% 
%
% Optional parameters:
%  'NumberOfBins' - the number of bins to use in display the data. Default
%  55.
% 
%  'NumSamplesToPlot' - how many posterior samples to show in the posterior
%  predictive plot. Default is 48.
%
%  'PdfColor' - the color to plot the model fit with. 
%
%  'NewFigure' - whether to make a new figure or plot into the currently
%  active subplot. Default is false (e.g., plot into current plot).
% 
function figHand = PlotPosteriorPredictiveData(model, posteriorSamples, data, varargin)
  % Show data sampled from the model with the actual data overlayed, plus a
  % difference plot.
  args = struct('NumSamplesToPlot', 48, 'NumberOfBins', 55, ...
    'PdfColor', [0.54, 0.61, 0.06], 'NewFigure', true); 
  args = parseargs(varargin, args);
  if args.NewFigure, figHand = figure(); else figHand = []; end
  
  % Choose which samples to use
  if(isempty(model.paramNames))
    which = 1:args.NumSamplesToPlot;
  else
    which = round(linspace(1, size(posteriorSamples.vals,1), args.NumSamplesToPlot));
  end
  
  % How to bin
  x = linspace(-180, 180, args.NumberOfBins)';
  [normalizedData, nSamples] = getNormalizedBinnedData(data, x);
  
  % Plot samples
  subplot(2,1,1);
  set(gcf, 'Color', [1 1 1]);
  curFigure = gcf;
  hold on;
  sampTime = tic();
  curHandle = [];
  for i=1:length(which)
    % Generate random data from this distribution with these parameters
    if(isempty(model.paramNames))
      asCell = {};
    else
      asCell = num2cell(posteriorSamples.vals(which(i),:));
    end
    yrep = SampleFromModel(model, asCell, [1 nSamples], data);
    if i==1 && toc(sampTime)>(5.0/length(which)) % if it will take more than 5s...
      curHandle = awaitbar(i/length(which), ...
        'Sampling to get posterior predictive distribution...');
    elseif ~isempty(curHandle)
      if awaitbar(i/length(which), curHandle)
        break;
      end
      set(0, 'CurrentFigure', curFigure);
    end
    
    % Bin data and model
    normalizedYRep = getNormalizedBinnedReplication(yrep, data, x);
    if any(isnan(normalizedYRep))
      hSim = plot(x, normalizedYRep, 'x-', 'Color', args.PdfColor, 'LineSmoothing', 'on');
    else
      hSim = patchline(x, normalizedYRep, 'LineStyle', '-', 'EdgeColor', ...
        args.PdfColor, 'EdgeAlpha', 0.15, 'LineSmoothing', 'on');
    end
    
    % Difference between this data and real data
    diffPlot(i,:) = normalizedData - normalizedYRep;
  end  
  if ishandle(curHandle)
    close(curHandle); 
  end
  
  % Plot data
  hSim = plot(-191:-190, [1 1], '-', 'Color', args.PdfColor);
  h=plot3(x,normalizedData,ones(size(x)),'ok-','LineWidth', 1.5, 'MarkerEdgeColor',[0 0 0], ...
       'MarkerFaceColor', [0 0 0], 'MarkerSize', 4);
  title('Simulated data from model', 'FontSize', 13);
  legend([h, hSim], {'Actual data', 'Simulated data'});
  legend boxoff;
  if isfield(model, 'isOrientationModel')
    xlim([-90 90]);
  else
    xlim([-180 180]);
  end
  
  % Plot difference
  subplot(2,1,2);
  bounds = quantile(diffPlot, [.05 .50 .95])';
  if any(isnan(bounds))
    hB = errorbar(x, bounds(:,2), bounds(:,2)-bounds(:,1), bounds(:,3)-bounds(:,2), ...
      'x', 'Color', [.3 .3 .3], 'LineWidth', 2, 'MarkerSize', 10);
  else
    hB = boundedline(x, bounds(:,2), [bounds(:,2)-bounds(:,1) bounds(:,3)-bounds(:,2)], ...
      'cmap', [0.3 0.3 0.3]);
    set(hB, 'LineWidth', 2, 'LineSmoothing', 'on');
  end
  line([-180 180], [0 0], 'LineStyle', '--', 'Color', [.5 .5 .5]);
  if isfield(model, 'isOrientationModel')
    xlim([-90 90]);
  else
    xlim([-180 180]);
  end
  title('Difference between actual and simulated data', 'FontSize', 13);
  xlabel('(Note: deviations from zero indicate bad fit)');
      
  % Allow the user to limit this figure to any subset of the data
  if ~isempty(figHand)
    CreateMenus(data, @redrawFig);
  end
  function redrawFig(whichField, whichValue)
    if strcmp(whichField, 'all')
      subplot(1,1,1);
      PlotPosteriorPredictiveData(model, posteriorSamples, data, ...
        'NewFigure', false, 'NumSamplesToPlot', args.NumSamplesToPlot, ...
        'NumberOfBins', args.NumberOfBins, 'PdfColor', args.PdfColor);
    elseif sum(ismember(data.(whichField),whichValue)) > 0
      [datasets,conditionOrder] = SplitDataByField(data, whichField);
      newData = datasets{ismember(conditionOrder,whichValue)};
      subplot(1,1,1);
      PlotPosteriorPredictiveData(model, posteriorSamples, newData, ...
        'NewFigure', false, 'NumSamplesToPlot', args.NumSamplesToPlot, ...
        'NumberOfBins', args.NumberOfBins, 'PdfColor', args.PdfColor);
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

function [nData, nSamples] = getNormalizedBinnedData(data, x)
  if isfield(data, 'errors')
    nData = hist(data.errors, x)';
    nData = nData ./ sum(nData(:));
    nSamples = numel(data.errors);
  else
    for i=1:length(x)
      distM(:,i) = (data.changeSize - x(i)).^2;
    end
    [tmp, whichBin] = min(distM,[],2);
    for i=1:length(x)
      nData(i) = mean(data.afcCorrect(whichBin==i));
    end
    nSamples = numel(data.changeSize);
  end
end