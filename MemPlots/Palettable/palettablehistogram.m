function palettablehistogram()
  
  % make the background white
  set(gcf,'Color',[1 1 1]);
  
  % kill the upper and right axis
  set(gca, 'box', 'off');
  
  % make the bars grey with small white borders
  h = findobj(gcf,'Type','patch');
  set(h,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[1 1 1]);
  
  % bring the axis to front
  set(gca,'layer','top');
end