function figHand = PlotPosteriorPredictiveData(model, posteriorSamples, data, varargin)
  % Show data sampled from the model with the actual data overlayed, plus a
  % difference plot.
  args = struct('NumSamplesToPlot', 48, 'NumberOfBins', 55, ...
    'PdfColor','b', 'NewFigure', true); 
  args = parseargs(varargin, args);
  if args.NewFigure, figHand = figure(); end
    
  if(isfield(model,'pdfForPlot'))
   model.pdf = model.pdfForPlot;
  end
  
  % Choose which samples to use
  which = round(linspace(1, size(posteriorSamples.vals,1), args.NumSamplesToPlot));
  
  % How to bin
  x = linspace(-180, 180, args.NumberOfBins)';
  nData = hist(data.errors, x)';
  nData = nData ./ sum(nData(:));
  
  % Plot samples
  subplot(2,1,1);
  hold on;
  for i=1:length(which)
    
    % Generate random data from this distrib. with these parameters
    asCell = num2cell(posteriorSamples.vals(which(i),:));
    yrep = SampleFromModel(model, asCell, size(data.errors));
       
    % Bin data and model
    n = hist(yrep, x)';
    n = n ./ sum(n(:));
    plot(x, n, '-', 'Color', args.PdfColor);
    
    % Diff between this data and real data
    diffPlot(i,:) = nData - n;
  end  

  % Plot data
  h=plot(x,nData,'ok-','LineWidth',2, ...
    'MarkerEdgeColor',[.1 .1 .1],'MarkerFaceColor', [.5 .5 .5], ...
    'MarkerSize', 5);
  title('Simulated data from model');
  legend(h, 'Actual data');
  xlim([-180, 180]);
  
  % Plot difference
  subplot(2,1,2);
  bounds = quantile(diffPlot, [.05 .50 .95])';
  h = boundedline(x, bounds(:,2), [bounds(:,2)-bounds(:,1) bounds(:,3)-bounds(:,2)], 'cmap', [0.3 0.3 0.3]);
  set(h, 'LineWidth', 2);
  line([-180 180], [0 0], 'LineStyle', '--', 'Color', [.5 .5 .5]);
  xlim([-180 180]);
  title('Difference between real data and simulated data');
  xlabel('(deviations from zero indicate bad fit)');
  palettablehistogram();
end

