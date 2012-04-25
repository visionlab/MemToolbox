function PlotModelFit(model, params, data, pdfColor, nBins)
  % Default parameters
  if nargin < 4
    pdfColor = 'b';
  end
  if nargin < 5
    nBins = 40;
  end
  
  % If params is a struct, assume they passed a stored() struct from MCMC
  if isstruct(params) && isfield(params, 'vals')
    params = params.vals;
  end
  
  % Plot data histogram
  set(gcf, 'Color', [1 1 1]);
  x = linspace(-pi, pi, nBins)';
  n = hist(data, x);
  bar(x, n./sum(n), 'EdgeColor', [1 1 1], 'FaceColor', [.8 .8 .8]);
  xlim([-pi pi]); hold on;
  %palettablehistogram;
  
  % Plot scaled version of the prediction
  vals = linspace(-pi, pi, 500)';
  multiplier = length(vals)/length(x);
  
  % If params has multiple rows, as if it came from a stored struct, then
  % plot a confidence interval, too
  if size(params,1) > 1
    for i=1:size(params,1)
      paramsAsCell = num2cell(params(i,:));
      p(i,:) = model.pdf(vals, paramsAsCell{:});
      p(i,:) = p(i,:) ./ sum(p(i,:));
    end
    bounds = quantile(p, [.05 .50 .95])';
    h = boundedline(vals, bounds(:,2) .* multiplier, ...
      [bounds(:,2)-bounds(:,1) bounds(:,3)-bounds(:,2)] .* multiplier, ...
      pdfColor, 'alpha');
    set(h, 'LineWidth', 2);
  else
    paramsAsCell = num2cell(params);
    p = model.pdf(vals, paramsAsCell{:});
    plot(vals, p(:) ./ sum(p(:)) .* multiplier, 'Color', pdfColor, 'LineWidth', 2);
  end
  xlabel('Error (radians)');
  ylabel('Probability');
  
  % Always set ylim to 120% of the histogram height, regardless of function
  % fit
  topOfY = max(n./sum(n))*1.20;
  ylim([0 topOfY]);
  
  % Label the plot with the parameter values
  if size(params,1) == 1
    txt = [];
    for i=1:length(params)
      txt = [txt sprintf('%s: %.3g\n', model.paramNames{i}, params(i))];
    end
    text(pi, topOfY-0.02, txt, 'HorizontalAlignment', 'right');
  end
end
