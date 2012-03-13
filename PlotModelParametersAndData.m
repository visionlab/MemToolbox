function figHand = PlotModelParametersAndData(model, stored, data)
  % Plot data fit
  figHand = figure;
  
  % Which to use
  numSamplesToPlot = 63; % Number of samples to plot
  which = round(linspace(1, size(stored.vals,1), numSamplesToPlot));
  [~,mapVal] = max(stored.like);
  params = stored.vals(mapVal,:);
  
  % Add MAP value to the end
  which = [which mapVal];
  
  % Setup to normalize them to same axis
  values = stored.vals(which,:);
  [~,order]=sort(values(:,1));
  minVals = min(values);
  maxVals = max(values);
  
  % Parallel coordinates
  subplot(1,2,1);
  map = palettablecolormap('diverging', numSamplesToPlot+1);
  for i=1:length(which)
    valuesNormalized(i,:) = (values(i,:) - minVals) ./ (maxVals - minVals);
    seriesInfo(i) = plot(1:size(values,2), valuesNormalized(i,:), 'Color', map(order==i,:));
    
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
  set(gca, 'XTick', 1:size(stored.vals,2));
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
  PlotModelFit(model, params, data, map(order==(length(which)), :));

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
    uistack(seriesInfo(minValue), 'top');
    subplot(1,2,2); hold off;
    PlotModelFit(model, values(minValue,:), data, map(order==minValue,:));
    
    % Unhighlight old series
    set(lastClicked, 'LineWidth', 1);
    lastClicked = seriesInfo(minValue);
  end
end
