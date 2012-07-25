% Doesn't work with 2AFC data currently

function figHand = PlotPosteriorPredictiveData(model, posteriorSamples, data, varargin)
  % Show data sampled from the model with the actual data overlayed, plus a
  % difference plot.
  args = struct('NumSamplesToPlot', 48, 'NumberOfBins', 55, ...
    'PdfColor', [0.54, 0.61, 0.06], 'NewFigure', true); 
  args = parseargs(varargin, args);
  if args.NewFigure, figHand = figure(); end
  
  % Choose which samples to use
  which = round(linspace(1, size(posteriorSamples.vals,1), args.NumSamplesToPlot));
  
  % How to bin
  x = linspace(-180, 180, args.NumberOfBins)';
  nData = hist(data.errors, x)';
  nData = nData ./ sum(nData(:));
  
  % Plot samples
  subplot(2,1,1);
  hold on;
  sampTime = tic();
  h = [];
  for i=1:length(which)
    
    % Generate random data from this distribution with these parameters
    asCell = num2cell(posteriorSamples.vals(which(i),:));
    yrep = SampleFromModel(model, asCell, size(data.errors), data);
    if i==1 && toc(sampTime)>(5.0/length(which)) % if it will take more than 5s...
      h = waitbar(i/length(which), 'Sampling to get posterior predictive distribution...');
    elseif ~isempty(h)
      if ~ishandle(h) % they closed the waitbar; stop sampling here
        break;
      end
      waitbar(i/length(which), h);
    end
    % Bin data and model
    n = hist(yrep, x)';
    n = n ./ sum(n(:));
    hSim = plot(x, n, '-', 'Color', args.PdfColor, 'LineSmoothing', 'on');
    
    % Difference between this data and real data
    diffPlot(i,:) = nData - n;
  end  
  if ishandle(h), close(h); end

  % Plot data
  h=plot(x,nData,'ok-','LineWidth',2, 'MarkerEdgeColor',[0 0 0], ...
       'MarkerFaceColor', [0 0 0], 'MarkerSize', 5, 'LineSmoothing', 'on');
  title('Simulated data from model');
  legend([h, hSim], {'Actual data', 'Simulated data'});
  legend boxoff;
  xlim([-180, 180]);
  
  % Plot difference
  subplot(2,1,2);
  bounds = quantile(diffPlot, [.05 .50 .95])';
  h = boundedline(x, bounds(:,2), [bounds(:,2)-bounds(:,1) bounds(:,3)-bounds(:,2)], 'cmap', [0.3 0.3 0.3]);
  set(h, 'LineWidth', 2, 'LineSmoothing', 'on');
  line([-180 180], [0 0], 'LineStyle', '--', 'Color', [.5 .5 .5]);
  xlim([-180 180]);
  title('Difference between real data and simulated data');
  xlabel('(Note: deviations from zero indicate bad fit)');
  palettablehistogram();
end

