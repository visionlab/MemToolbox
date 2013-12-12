% MAKEPALETTABLE Overrides some of MATLAB's defaults to make a figure that
% is at least palettable.
function makepalettable(f)

  if nargin < 1
    f = gcf();
  end

  % make the background white
  set(f,'Color',[1 1 1]);

  % kill the upper and right axis
  set(get(f,'CurrentAxes'), 'box', 'off');

  % make the bars grey with small white borders
  h = findobj(f,'Type','patch');
  set(h,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[1 1 1]);

  % bring the axis to front
  set(get(f,'CurrentAxes'),'layer','top');

end
