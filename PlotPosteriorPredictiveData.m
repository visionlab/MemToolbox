function figHand = PlotPosteriorPredictiveData(model, stored, data)
  % Show data sampled from the model with the actual data overlayed, plus a
  % difference plot.
  
  figHand = figure();
  
  % Choose which samples to use
  numSamplesToPlot = 128;
  which = round(linspace(1, size(stored.vals,1), numSamplesToPlot));
  
  % How to bin
  x = linspace(-pi, pi, 55)';
  nData = hist(data, x)';
  nData = nData ./ sum(nData(:));
  
  % Plot samples
  subplot(2,1,1);
  hold on;
  for i=1:length(which)
    % Generate random data from this distrib. with these parameters
    asCell = num2cell(stored.vals(which(i),:));
    yrep = modelrnd(model, asCell, size(data));
   
    % Bin data and model
    n = hist(yrep, x)';
    n = n ./ sum(n(:));
    plot(x, n, '-', 'Color', [.5 .5 .5]);
    
    % Diff between this data and real data
    diffPlot(i,:) = nData - n;
  end  

  % Plot data
  plot(x,nData,'r-','LineWidth',2);
  title('Simulated data from model');
  xlim([-pi, pi]);
  
  % Plot difference
  subplot(2,1,2);
  bounds = quantile(diffPlot, [.05 .50 .95])';
  h = boundedline(x, bounds(:,2), [bounds(:,2)-bounds(:,1) bounds(:,3)-bounds(:,2)], 'cmap', [0.3 0.3 0.3]);
  set(h, 'LineWidth', 2);
  line([-pi pi], [0 0], 'LineStyle', '--', 'Color', [.5 .5 .5]);
  xlim([-pi pi]);
  title('Difference between simulated model data and real data');
  palettablehistogram();
end

