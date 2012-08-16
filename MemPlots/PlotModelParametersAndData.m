%PLOTMODELPARAMETERSANDDATA plots the parameters of the model in a parallel coordinates plot. 
% It then shows you the fit of the model at each set of parameter values, 
% which you can see plotted by clicking on the parallel coordinates plot.
%
%  figHand = PlotModelParametersAndData(model, posteriorSamples, ...
%                                          data, [optionalParameters])
%
% Optional parameters:
%  'NumSamplesToPlot' - how many posterior samples to show in the parallel
%  coordinates plot. Default is 63.
%
%  'PdfColor' - the color to plot the model fit with. Note that this color
%  is automatically 'faded' if the model fit being shown is not the max
%  posterior fit.
%
%  'NewFigure' - whether to make a new figure or plot into the currently
%  active subplot. Default is false (e.g., plot into current plot).
% 
function figHand = PlotModelParametersAndData(model, posteriorSamples, data, varargin)
  % Plot data fit
  args = struct('PdfColor', [0.54, 0.61, 0.06], 'NumSamplesToPlot', 63, 'NewFigure', true); 
  args = parseargs(varargin, args);
  if args.NewFigure, figHand = figure(); else figHand = []; end
  
  startCol = args.PdfColor;
  
  % Which to use
  which = round(linspace(1, size(posteriorSamples.vals,1), args.NumSamplesToPlot));
  [mapLikeVal,mapVal] = max(posteriorSamples.like);
  params = posteriorSamples.vals(mapVal,:);
  
  % Add MAP value to the end
  which = [which mapVal];
  
  % Setup to normalize them to same axis
  values = posteriorSamples.vals(which,:);
  [tmp,order]=sort(values(:,1));
  minVals = min(values);
  maxVals = max(values);
  
  % Parallel coordinates
  h=subplot(1,2,1);
  pos = get(h, 'Position');
  set(h, 'Position', [pos(1)-0.05 pos(2)+0.03 pos(3:end)]);
  for i=1:length(which)
    valuesNormalized(i,:) = (values(i,:) - minVals) ./ (maxVals - minVals);
    
    % Desaturate if not MAP
    colorOfLine(i,:) = fade(startCol, ...
      exp(posteriorSamples.like(which(i)) - mapLikeVal));
    
    % Special case of only one parameter
    if size(values,2) == 1
      seriesInfo(i) = plot(1:size(values,2), ...
        valuesNormalized(i,:), 'x', 'MarkerSize', 15, ...
        'Color', colorOfLine(i,:));
      xlim([0 2]);
    else
      seriesInfo(i) = plot(1:size(values,2), valuesNormalized(i,:), ...
        'Color', colorOfLine(i,:), 'LineSmoothing', 'on');
    end
    hold on;
  end
  set(gca, 'box', 'off');
  set(seriesInfo(end), 'LineWidth', 4); % Last one plotted is MAP value
  lastClicked = seriesInfo(end);
  set(gca, 'XTick', []);
  set(gca, 'XTickLabel', []);
  
  labelPos = [-0.03 1.02];
  set(gca, 'YTick', labelPos);
  set(gca, 'YTickLabel', {});
  set(gca, 'FontWeight', 'bold');
  %set(gca, 'YGrid','on')
  for i=1:length(minVals)
    line([i i], [0 1], 'LineStyle', '-', 'Color', 'k');
    for j=1:length(labelPos)
      txt = sprintf('%0.3f', minVals(i)+(maxVals(i)-minVals(i)).*labelPos(j));
      text(i-0.03, labelPos(j), txt, 'FontWeight', 'bold', 'FontSize', 10);
    end
    text(i-0.03, -0.10, model.paramNames{i}, 'FontWeight', 'bold', 'FontSize', 12);
  end
  
  set(gca,'ButtonDownFcn', @Click_Callback);
  set(get(gca,'Children'),'ButtonDownFcn', @Click_Callback);
  line([1.001 1.001], [0 1], 'Color', [0 0 0]);
  
  % Plot data histogram
  h=subplot(1,2,2);
  pos = get(h, 'Position');
  set(h, 'Position', [pos(1) pos(2)+0.03 pos(3:end)]);
  PlotModelFit(model, params, data, 'PdfColor', colorOfLine(end,:));
  line([-179.99 -179.99], [0 max(ylim)], 'Color', [0 0 0]);
  line([-180 180], [0.0001 0.0001], 'Color', [0 0 0]);
  
  % Allow the user to limit this figure to any subset of the data
  if ~isempty(figHand)
    CreateMenus(data, @redrawFig);
  end
  function redrawFig(whichField, whichValue)
    if strcmp(whichField, 'all')
      subplot(1,1,1);
      PlotModelParametersAndData(model, posteriorSamples, data, ...
        'NumSamplesToPlot', args.NumSamplesToPlot, 'NewFigure', false, ...
        'PdfColor', args.PdfColor);
    elseif sum(ismember(data.(whichField),whichValue)) > 0
      [datasets,conditionOrder] = SplitDataByField(data, whichField);
      newData = datasets{ismember(conditionOrder,whichValue)};
      subplot(1,1,1);
      PlotModelParametersAndData(model, posteriorSamples, newData, ...
        'NumSamplesToPlot', args.NumSamplesToPlot, 'NewFigure', false, ...
        'PdfColor', args.PdfColor);
    end
  end
  
  % What to do when series is clicked
  function Click_Callback(tmp,tmp2)
    % Get the point that was clicked on
    cP = get(gca,'Currentpoint');
    cx = cP(1,1); 
    cy = cP(1,2);
    
    % Show that series
    if size(posteriorSamples.vals,2)==1
      interpolatedY = valuesNormalized';
    else
      interpolatedY = interp1(1:size(posteriorSamples.vals,2), ...
        valuesNormalized', cx);
    end
    diffValues = (cy-interpolatedY).^2;
    [tmp,minValue] = min(diffValues);
    set(seriesInfo(minValue), 'LineWidth', 4);
    set(seriesInfo(minValue), 'Color', colorOfLine(minValue,:));
    uistack(seriesInfo(minValue), 'top');
    % Unhighlight old series
    if lastClicked ~= seriesInfo(minValue)
      set(lastClicked, 'LineWidth', 1);
    end
    lastClicked = seriesInfo(minValue);
    drawnow;
    
    subplot(1,2,2); hold off;
    PlotModelFit(model, values(minValue,:), data, ...
                 'PdfColor', colorOfLine(minValue,:));
    line([-179.99 -179.99], [0 max(ylim)], 'Color', [0 0 0]);
    line([-180 180], [0.0001 0.0001], 'Color', [0 0 0]);

  end
end

