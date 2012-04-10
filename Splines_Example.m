%-------------------------------------------------------------------------
function Splines_Example()
  close all;
  addpath('MemModels');
  addpath('Helpers');
  addpath('MemVisualizations');
    
  % Example data
  %d = load('MemData/3000+trials_3items_SUBJ#1.mat');
  d = load('MemData/data.mat');
  
  % Model
  model = SplinesModel();
  
  % Run MCMC
  stored = MCMC_Convergence(d.data(:), model);
  params = getfield(MCMC_Summarize(stored), 'maxPosterior');
  
  % Print knots
  disp('Knot values:');
  disp(params);
    
  % Figure 1: Plot lines of best fit higher-order functions
  PlotSamplesOfHigherOrder(model.stdX, model.knotX, stored, d.data(:));
  
  % Figure 2: Plot credible intervals of higher-order function
  PlotConfidenceHigherOrder(model.stdX, model.knotX, stored);
  
  % Figure 3: Plot data fit
  precisionDist = interp1(model.knotX, mean(stored.vals), model.stdX, 'pchip');
  precisionDist = precisionDist ./ sum(precisionDist(:));
  PlotData(model.stdX, precisionDist, d.data(:));
  
  keyboard
end

% I think all of these functions could be converted to use the standard
% ones from MCMC_Example, with some way of overcoming how many labels etc
% it puts

%-------------------------------------------------------------------------
function PlotSamplesOfHigherOrder(X, KnotX, stored, data)
  % Figure 1: Plot lines of best fit higher-order functions
  figure(); hold off;
  
  % Sample 100 example sets of knots and plot them
  rowsVals = round(linspace(1, size(stored.vals,1), 100));
  for i=1:100
    row = rowsVals(i);
    tempSplineVals = stored.vals(row,:);
    tempDist = interp1(KnotX, tempSplineVals, X, 'pchip');
    series(i,:) = tempDist ./ sum(tempDist(:));
    seriesInfo(i) = plot(X, series(i,:), 'Color', [.8 .8 .8]); hold on;
  end
  
  % Plot the posterior mean estimate
  plot(X, mean(series), 'r', 'LineWidth', 3);
  
  % Clean up plot
  xlim([0 max(KnotX)]);
  xlabel('Precision (radians)');
  ylabel('Frequency');
  
  % Add callback so that clicking a line changes the data graph and
  % highlights the line
  set(gca,'ButtonDownFcn', @Click_Callback);
  set(get(gca,'Children'),'ButtonDownFcn', @Click_Callback);
  
  % What to do when item is clicked
  function Click_Callback(~,~)
    persistent lastClicked;
    
    % Get the point that was clicked on
    cP = get(gca,'Currentpoint');
    x = ceil(cP(1,1));
    y = cP(1,2);
    
    % Show that series
    diffValues = (y-series(:,x)).^2;
    [~,minValue] = min(diffValues);
    set(seriesInfo(minValue), 'Color', 'g', 'LineWidth', 4);
    uistack(seriesInfo(minValue), 'top');
    PlotData(X, series(minValue,:), data);
    
    % Unhighlight old series
    if ~isempty(lastClicked) && ishandle(lastClicked)
      set(lastClicked,  'Color', [.8 .8 .8], 'LineWidth', 1);
    end
    lastClicked = seriesInfo(minValue);
  end
end

%-------------------------------------------------------------------------
function PlotConfidenceHigherOrder(X, KnotX, stored)
  % Figure 2: Plot credible intervals of higher-order function
  figure();
  hold off; cla;
  
  % Use up to 3000 values to create 95% credible intervals
  rowsVals = round(linspace(1, size(stored.vals,1), ...
    min([3000 size(stored.vals,1)])));
  
  % Calculate full pdf's for each selected sample
  seriesForConf = zeros(length(rowsVals), length(X));
  for i=1:length(rowsVals)
    row = rowsVals(i);
    tempSplineVals = stored.vals(row,:);
    tempDist = interp1(KnotX, tempSplineVals, X, 'pchip');
    seriesForConf(i,:) = tempDist ./ sum(tempDist(:));
  end
  
  % Plot line with 95% confidence shading
  bounds = quantile(seriesForConf, [.05 .50 .95])';
  h = boundedline(X, bounds(:,2), [bounds(:,2)-bounds(:,1) bounds(:,3)-bounds(:,2)]);
  set(h, 'LineWidth', 3);
  xlim([0 max(KnotX)]);
end

%-------------------------------------------------------------------------
function PlotData(X, precisionDist, data)
  % Figure 3: Plot data fit
  figure(); hold off;
  vals = linspace(-pi, pi, 55);
  
  % Generate data prediction of the precisionDist
  p = zeros(size(vals));
  precisionDist = precisionDist ./ sum(precisionDist(:));
  for i=1:length(precisionDist)
    p = p + precisionDist(i) * WrappedNormal(vals, 0, X(i));
  end
  
  % Plot data histogram
  n=hist(data, vals);
  x=vals';
  bar(x, n./sum(n), 'EdgeColor', [1 1 1], 'FaceColor', [.8 .8 .8]);
  xlim([-pi pi]); hold on;
  
  % Plot scaled version of the prediction
  multiplier = length(vals)/length(x);
  plot(vals, p ./ sum(p(:)) * multiplier, 'b--', 'LineWidth', 2);
  xlabel('Error (radians)');
  ylabel('Probability');
end

function p = WrappedNormal(x, m, s)
  % Wraps at 360
  n = 1./sqrt(2*pi.*s.*s);
  sm = 0;
  for j=-20:20 % sum from infinity to -infinity; larger sum = better approx.
    sm = sm + exp((-(x-m-(2*pi*j)).^2)./(2.*s.*s));
  end
  p = n*sm;
end


