function MCMC_Example()
  close all;
  addpath('MemModels');
  addpath('MemVisualizations');
    
  % Example data
  d = load('MemData/3000+trials_3items_SUBJ#1.mat');
  
  % Choose a model
  %model = StandardMixtureModel();
  model = InfiniteScaleMixtureModel();
  
  % Run MCMC
  load InfiniteScale.mat
  %[params, stored] = MCMC(d.data(:), model);
  
  % Maximum posterior parameters from MCMC
  disp('MAP from MCMC():');
  disp(params);
  
  % Make sure MCMC converged:
  % Trace plots and histograms should have similar means and variance
  % (e.g., should overlap). This shows that the chains that started in
  % different places all settled into the same ending distribution.
  h = MCMC_Convergence_Plot(stored, model.paramNames);
  subfigure(2,2,1, h);
  
  % Show a figure with each parameter's correlation with each other
  h = MCMC_Plot(stored, model.paramNames);
  subfigure(2,2,2, h);
  
  % Show fit
  %h = PlotData(model, params, d.data(:));
  h = PlotDataNew(model, stored, d.data(:));
  subfigure(2,2,3:4, h);
  
  % Get MLE parameters using search
  disp('MLE from mle():');
  %params_mle = MLE(d.data(:), model);
  disp(params_mle);
  
  %save InfiniteScale.mat params stored params_mle
end

function figHand = PlotDataNew(model, stored, data)
  % Plot data fit
  figHand = figure;
  
  % Which to use
  which = round(linspace(1, size(stored.vals,1), 63));
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
  map = palettablecolormap([0 255 0], [255 0 0], 64);
  for i=1:length(which)
    valuesNormalized(i,:) = (values(i,:) - minVals) ./ (maxVals - minVals);
    seriesInfo(i) = plot(1:size(values,2), valuesNormalized(i,:), 'Color', map(order==i,:));
    hold on;
  end
  set(seriesInfo(end), 'LineWidth', 4); % Last one plotted is MAP value
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
      txt = sprintf('%.2g', minVals(i)+(maxVals(i)-minVals(i)).*labelPos(j));
      text(i+0.02, labelPos(j), txt, 'FontWeight', 'bold', 'FontSize', 8);
    end
  end
  
  set(gca,'ButtonDownFcn', @Click_Callback);
  set(get(gca,'Children'),'ButtonDownFcn', @Click_Callback);
  
  % Plot data histogram
  subplot(1,2,2);
  PlotData(model, params, data);

  % What to do when series is clicked
  function Click_Callback(~,~)
    persistent lastClicked;
    
    % Get the point that was clicked on
    cP = get(gca,'Currentpoint');
    cx = round(cP(1,1));
    cy = cP(1,2);
    
    % Show that series
    diffValues = (cy-valuesNormalized(:,cx)).^2;
    [~,minValue] = min(diffValues);
    set(seriesInfo(minValue), 'LineWidth', 4);
    uistack(seriesInfo(minValue), 'top');
    subplot(1,2,2); hold off;
    PlotData(model, values(minValue,:), data);
    
    % Unhighlight old series
    if ~isempty(lastClicked)
      set(lastClicked,  'LineWidth', 1);
    else
      set(seriesInfo(end),  'LineWidth', 1);
    end
    lastClicked = seriesInfo(minValue);
  end
end

function PlotData(model, params, data)
  % Plot data histogram
  x = linspace(-pi, pi, 55)';
  n = histc(data, x);
  bar(x, n./sum(n), 'EdgeColor', [1 1 1], 'FaceColor', [.8 .8 .8]);
  xlim([-pi pi]); hold on;
  palettablehistogram;
  
  % Plot scaled version of the prediction
  vals = linspace(-pi, pi, 500)';
  paramsAsCell = num2cell(params);
  p = model.pdf(vals, paramsAsCell{:});
  multiplier = length(vals)/length(x);
  plot(vals, p ./ sum(p(:)) * multiplier, 'b--', 'LineWidth', 2);
  xlabel('Error (radians)');
  ylabel('Probability');
end

