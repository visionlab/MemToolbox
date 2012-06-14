function figHand = PlotPosteriorPredictiveStatistic(model, posteriorSamples, data, varargin)
  % Should break up into two functions: one to compute, and one to plot
  % (so we can easily memoize the compute function, for example)
  %
  % Generate posterior predictive distribution on residuals:
  %  1) Take numSamplesToPlot random samples from the posterior on
  %  parameters
  %  2) Generate fake data from the model w/ those parameters
  %  3) Find best fit parameters for those fake data
  %  4) Bin the data and the model fit, and calculate a discrepency
  %  ... (rinse and repeat)
  %  5) Compare to the discrepency from the true data (plotted as a line)
  args = struct('NumSamplesToPlot', 48, 'NumberOfBins', 55, ...
    'PdfColor','b', 'NewFigure', true); 
  args = parseargs(varargin, args);
  if args.NewFigure, figHand = figure(); end
  
  % Choose which samples to use
  which = round(linspace(1, size(posteriorSamples.vals,1), args.NumSamplesToPlot));
  
  % How to bin
  x = linspace(-180, 180, args.NumberOfBins)';
  
  % Plot samples from posterior
  subplot(2,1,1);
  hold on;
  
  for i=1:length(which)
    % Generate random data from this distrib. with these parameters
    asCell = num2cell(posteriorSamples.vals(which(i),:));
    yrep = modelrnd(model, asCell, size(data));
    
    % Get best fit to this data
    model.start = posteriorSamples.vals(which(i),:);
    bestParams = MLE(yrep, model);
    
    % Bin data and model
    bestParamsAsCell = num2cell(bestParams);
    pdfVals = model.pdf(x, bestParamsAsCell{:});
    n = hist(yrep, x)';
    n = n ./ sum(n(:));
    pdfVals = pdfVals ./ sum(pdfVals(:));
    plot(x, n, '-', 'Color', [.5 .5 .5]);
 
    % Calculate discrepency
    yrep_t(i) = sum((n - pdfVals) .^ 2);
  end

  % Plot data
  nData = hist(data, x)';
  nData = nData ./ sum(nData(:));
  plot(x,nData,'r-','LineWidth',2);
  xlim([-180, 180]);
  
  % Plot histogram
  subplot(2,1,2);
  [nR,xR]=hist(yrep_t);
  bar(xR,nR./sum(nR));
  topAxis = max(nR./sum(nR));
  palettablehistogram();
  
  % Now, find the MAP value from the real data...
  [~,mapVal] = max(posteriorSamples.like);
  params = posteriorSamples.vals(mapVal,:);
  asCell = num2cell(params);
  
  % Bin and compare...
  pdfVals = model.pdf(x, asCell{:});
  pdfVals = pdfVals ./ sum(pdfVals(:));
  y_t = sum((nData - pdfVals) .^ 2);
  
  % And plot
  line([y_t y_t], [0 topAxis], 'LineStyle', '--', 'Color', 'r');
  
  % Also show the p value. <0.05 means we can reject this model.
  lims = axis();
  pVal = sum(yrep_t > y_t)/args.NumSamplesToPlot;
  text(lims(2), lims(4), sprintf('Can reject\nbased on SSE?\n p=%0.03f', pVal), ...
    'HorizontalAlignment', 'right');
end

