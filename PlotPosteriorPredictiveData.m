function figHand = PlotPosteriorPredictiveData(model, stored, data, modelColor)
  % Show data sampled from the model with the actual data overlayed, plus a
  % difference plot.
  if nargin < 4
    modelColor = 'b';
  end
  
  figHand = figure();
  
  % Choose which samples to use
  numSamplesToPlot = 48;
  which = round(linspace(1, size(stored.vals,1), numSamplesToPlot));
  
  % How to bin
  x = linspace(-pi, pi, 55)';
  nData = hist(data.errors, x)';
  nData = nData ./ sum(nData(:));
  
  % Plot samples
  subplot(2,1,1);
  hold on;
  for i=1:length(which)
    % Generate random data from this distrib. with these parameters
    asCell = num2cell(stored.vals(which(i),:));
    yrep = modelrnd(model, asCell, size(data.errors));
   
    % Bin data and model
    n = hist(yrep, x)';
    n = n ./ sum(n(:));
    plot(x, n, '-', 'Color', modelColor);
    
    % Diff between this data and real data
    diffPlot(i,:) = nData - n;
  end  

  % Plot data
  h=plot(x,nData,'ok-','LineWidth',2, ...
    'MarkerEdgeColor',[.1 .1 .1],'MarkerFaceColor', [.5 .5 .5], ...
    'MarkerSize', 5);
  title('Simulated data from model');
  legend(h, 'Actual data');
  xlim([-pi, pi]);
  
  % Plot difference
  subplot(2,1,2);
  bounds = quantile(diffPlot, [.05 .50 .95])';
  h = boundedline(x, bounds(:,2), [bounds(:,2)-bounds(:,1) bounds(:,3)-bounds(:,2)], 'cmap', [0.3 0.3 0.3]);
  set(h, 'LineWidth', 2);
  line([-pi pi], [0 0], 'LineStyle', '--', 'Color', [.5 .5 .5]);
  xlim([-pi pi]);
  title('Difference between real data and simulated data');
  xlabel('(deviations from zero indicate bad fit)');
  palettablehistogram();
end

