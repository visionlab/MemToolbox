% PLOTDATA plots a histogram of the data. 

function figHand = PlotData(data, varargin)
  % Extra arguments and parsing
  args = struct('NumberOfBins', 40, 'NewFigure', false); 
  args = parseargs(varargin, args);
  if args.NewFigure, figHand = figure(); end
  
  % Clean data up if it is just errors
  if(~isfield(data,'errors'))
    data = struct('errors',data);
  end  
  
  % Plot data histogram
  set(gcf, 'Color', [1 1 1]);
  x = linspace(-180, 180, args.NumberOfBins)';
  n = hist(data.errors(:), x);
  bar(x, n./sum(n), 'EdgeColor', [1 1 1], 'FaceColor', [.8 .8 .8]);
  xlim([-180 180]); hold on;
  set(gca, 'box', 'off');
  xlabel('Error (degrees)', 'FontSize', 14);
  ylabel('Probability', 'FontSize', 14);
  
  % Always set ylim to 120% of the histogram height, regardless of function
  % fit
  topOfY = max(n./sum(n))*1.20;
  ylim([0 topOfY]);
end
