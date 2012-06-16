function figHand = PlotModelParametersAndData(model, posteriorSamples, data, varargin)
  % Plot data fit
  args = struct('NumSamplesToPlot', 63, 'NewFigure', true); 
  args = parseargs(varargin, args);
  if args.NewFigure, figHand = figure(); end
  
  % Which to use
  which = round(linspace(1, size(posteriorSamples.vals,1), args.NumSamplesToPlot));
  [~,mapVal] = max(posteriorSamples.like);
  params = posteriorSamples.vals(mapVal,:);
  
  % Add MAP value to the end
  which = [which mapVal];
  
  % Setup to normalize them to same axis
  values = posteriorSamples.vals(which,:);
  [~,order]=sort(values(:,1));
  minVals = min(values);
  maxVals = max(values);
  
  % Parallel coordinates
  subplot(1,2,1);
  map = palettablecolormap('diverging', args.NumSamplesToPlot+1);
  for i=1:length(which)
    valuesNormalized(i,:) = (values(i,:) - minVals) ./ (maxVals - minVals);
    
    % desaturate if not MAP
    if i < length(which)
        colorOfLine = desaturate(map(order==i,:));
    else
        colorOfLine = map(order==i,:);
    end
    
    seriesInfo(i) = plot(1:size(values,2), valuesNormalized(i,:), 'Color', colorOfLine);
    
    % Special case of only one parameter
    if size(values,2) == 1
      seriesInfo(i) = plot(1:size(values,2), ...
        valuesNormalized(i,:), 'x', 'MarkerSize', 15, ...
        'Color', map(order==i,:));
    end
    hold on;
  end
  set(gca, 'box', 'off');
  set(seriesInfo(end), 'LineWidth', 4); % Last one plotted is MAP value
  lastClicked = seriesInfo(end);
  set(gca, 'XTick', 1:size(posteriorSamples.vals,2));
  set(gca, 'XTickLabel', model.paramNames);
  
  labelPos = 0:0.25:1;
  set(gca, 'YTick', labelPos);
  set(gca, 'YTickLabel', {});
  set(gca, 'FontWeight', 'bold');
  %set(gca, 'YGrid','on')
  for i=1:length(minVals)
    line([i i], [0 1], 'LineStyle', '-', 'Color', 'k');
    for j=1:length(labelPos)
      txt = sprintf('%.3g', minVals(i)+(maxVals(i)-minVals(i)).*labelPos(j));
      text(i+0.02, labelPos(j), txt, 'FontWeight', 'bold', 'FontSize', 8);
    end
  end
  
  set(gca,'ButtonDownFcn', @Click_Callback);
  set(get(gca,'Children'),'ButtonDownFcn', @Click_Callback);
  
  % Plot data histogram
  subplot(1,2,2);
  PlotModelFit(model, params, data, 'PdfColor', map(order==(length(which)), :));

  % What to do when series is clicked
  function Click_Callback(~,~)
    % Get the point that was clicked on
    cP = get(gca,'Currentpoint');
    cx = round(cP(1,1)); % TODO: Doesn't work well if you click in 
                         % between two parameters (e.g., at .5 on the axis)
    cy = cP(1,2);
    
    % Show that series
    diffValues = (cy-valuesNormalized(:,cx)).^2;
    [~,minValue] = min(diffValues);
    set(seriesInfo(minValue), 'LineWidth', 4);
    set(seriesInfo(minValue), 'Color', map(order==minValue,:))
    uistack(seriesInfo(minValue), 'top');
    subplot(1,2,2); hold off;
    PlotModelFit(model, values(minValue,:), data, ...
                 'PdfColor', map(order==minValue,:));
    
    % Unhighlight old series
    set(lastClicked, 'LineWidth', 1);
    lastClicked = seriesInfo(minValue);
  end
end

function c = desaturate(color)
    colorHSV = rgb2hsv(color);
    colorHSV(2) = colorHSV(2)/3;
    c = hsv2rgb(colorHSV);
end
