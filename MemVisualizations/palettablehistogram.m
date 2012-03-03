
% make the background white
set(gcf,'Color',[1 1 1]);

% make the bars grey with small white borders
h = findobj(gcf,'Type','patch');
set(h,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[1 1 1]);
