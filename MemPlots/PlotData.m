%PLOTDATA plots a histogram of the data
% Can plot either continuous report data, or binned bar graph for 2AFC data
%
%  figHand = PlotData(data, [optionalParameters])
%
% Optional parameters:
%  'NumberOfBins' - the number of bins to use in display the data. Default
%  40.
%
%  'NewFigure' - whether to make a new figure or plot into the currently
%  active subplot. Default is false (e.g., plot into current plot).
%
function figHand = PlotData(data, varargin)
  % Extra arguments and parsing
  args = struct('NumberOfBins', 40, 'NewFigure', true);
  args = parseargs(varargin, args);
  if args.NewFigure, figHand = figure(); else figHand = []; end

  % Clean data up if it is just errors
  if(~isfield(data,'errors')) && (~isfield(data,'afcCorrect'))
    data = struct('errors',data);
  end

  if isfield(data, 'errors')
    % Plot data histogram for continuous report data
    set(gcf, 'Color', [1 1 1]);
    x = linspace(-180, 180, args.NumberOfBins)';
    n = hist(data.errors(:), x);
    bar(x, n./sum(n), 'EdgeColor', [1 1 1], 'FaceColor', [.8 .8 .8]);
    xlim([-180 180]); hold on;
    set(gca, 'box', 'off');
    xlabel('Error (degrees)', 'FontSize', 14);
    ylabel('Probability', 'FontSize', 14);
    topOfY = max(n./sum(n))*1.20;
    ylim([0 topOfY]);
  else

    % Plot binned data for 2AFC data
    set(gcf, 'Color', [1 1 1]);
    x = linspace(-180, 180, args.NumberOfBins)';
    for i=2:length(x)
      which = data.changeSize>=x(i-1) & data.changeSize<x(i);
      mn(i-1) = mean(data.afcCorrect(which));
      se(i-1) = std(data.afcCorrect(which))./sqrt(sum(which));
    end
    binX = (x(1:end-1) + x(2:end))/2;
    bar(binX, mn, 'EdgeColor', [1 1 1], 'FaceColor', [.8 .8 .8]);
    hold on;
    errorbar(binX, mn, se, '.', 'Color', [.5 .5 .5]);
    xlim([-180 180]);
    set(gca, 'box', 'off');
    xlabel('Distance (degrees)', 'FontSize', 14);
    ylabel('Probability Correct', 'FontSize', 14);
    ylim([0 1]);
  end

  % Allow the user to limit this figure to any subset of the data
  if ~isempty(figHand)
    CreateMenus(data, @redrawFig);
  end
  function redrawFig(whichField, whichValue)
    if strcmp(whichField, 'all')
      cla;
      PlotData(data, 'NewFigure', false, 'NumberOfBins', args.NumberOfBins);
    elseif sum(ismember(data.(whichField),whichValue)) > 0
      [datasets,conditionOrder] = SplitDataByField(data, whichField);
      newData = datasets{ismember(conditionOrder,whichValue)};
      cla;
      PlotData(newData, 'NewFigure', false, 'NumberOfBins', args.NumberOfBins);
    end
  end
end
