function figHand = MCMC_Plot(stored, paramNames)
  % Show 2x2 correlation for each variable with each other to look for
  % structure; Visualize both as a scatter and as a 2D histogram
  figHand = figure;
  N = length(paramNames);
  for p=1:N
    for p2=1:(p-1)
      subplot(N,N,sub2ind([N N],p,p2));
      [V,C] = hist3(stored.vals(:,[p p2]), [20 20]);
      imagesc(C{1}, C{2}, V');
      set(gca,'YDir','normal');
      axis tight;
      
      subplot(N,N,sub2ind([N N],p2,p));
      imagesc(C{2}, C{1}, V);
      set(gca,'YDir','normal');
      axis tight;
    end
    subplot(N,N,sub2ind([N N],p,p));
    hist(stored.vals(:,p));
    axis tight;
    set(gca, 'YTick', []);
    subplot(N,N,sub2ind([N N],p,1));
    title(paramNames{p}, 'FontSize', 15);
    subplot(N,N,sub2ind([N N],1,p));
    ylabel(paramNames{p}, 'FontSize', 15);
  end
  
  % comestics
  colormap(palettablecolormap('sequential'));
  palettablehistogram;
end