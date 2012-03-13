function PlotModelFit(model, params, data, pdfColor)
  % Default parameters
  if nargin < 4
    pdfColor = 'b';
  end
  
  % Plot data histogram
  x = linspace(-pi, pi, 55)';
  n = hist(data, x);
  bar(x, n./sum(n), 'EdgeColor', [1 1 1], 'FaceColor', [.8 .8 .8]);
  xlim([-pi pi]); hold on;
  palettablehistogram;
  
  % Plot scaled version of the prediction
  vals = linspace(-pi, pi, 500)';
  paramsAsCell = num2cell(params);
  p = model.pdf(vals, paramsAsCell{:});
  multiplier = length(vals)/length(x);
  plot(vals, p ./ sum(p(:)) * multiplier, 'Color', pdfColor, 'LineWidth', 2);
  xlabel('Error (radians)');
  ylabel('Probability');
  
  % Always set ylim to 120% of the histogram height, regardless of function
  % fit
  topOfY = max(n./sum(n))*1.20;
  ylim([0 topOfY]);
  
  % Label the plot with the parameter values
  txt = [];
  for i=1:length(params)
    txt = [txt sprintf('%s: %.3g\n', model.paramNames{i}, params(i))];
  end
  text(pi, topOfY-0.02, txt, 'HorizontalAlignment', 'right');
end
