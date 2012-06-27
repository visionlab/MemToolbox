function pplot(varargin)
  
  opengl('OpenGLLineSmoothingBug',1)
  
  plot(varargin{:}, 'Color', [0.54, 0.61, 0.06], 'LineWidth', 1.25);
  
  % make the background white
  set(gcf,'Color',[1 1 1]);
  
  % kill the upper and right axis
  set(gca, 'box', 'off');  
  
  % bring the axis to front
  set(gca,'layer','top');
end