function MCMC_Convergence_Plot(stored, paramNames)
  % Show traces for each variable for each MCMC chain. Very simple way to
  % diagnose convergence: They should look the same as each other.
  figure;
  N = length(paramNames);
  colors = {'r', 'g', 'b', 'y', 'm', 'c'};
  for p=1:N
    h = subplot(N,3,sub2ind([3 N],1:2,[p p]));
    for c=1:max(stored.chain)
      vals(:,c) = stored.vals(stored.chain==c, p);
    end
    plot(vals);
    lims = axis(gca);
    set(gca, 'XTick', []);
    title(paramNames{p}, 'FontSize', 15);
    
    h2 = subplot(N,3,sub2ind([3 N],3,p));
    yBins = linspace(lims(3), lims(4), 30)';
    for c=1:max(stored.chain)
      cnt = histc(vals(:,c), yBins);
      B = barh(yBins, cnt, 'hist');
      set(B, 'EdgeColor', 'none', 'FaceColor', ...
        colors{mod(c-1, length(colors))+1}); %'FaceAlpha', .2 
      hold on;
    end    
    ylim([lims(3), lims(4)]);
    set(gca, 'YTick', []);
    set(gca, 'XTick', []);
    
    pos = get(h, 'Position');
    pos(3) = pos(3) + 0.05;
    pos(2) = pos(2) + 0.04*(p-1);
    set(h, 'Position', pos);
    pos = get(h2, 'Position');
    pos(2) = pos(2) + 0.04*(p-1);
    set(h2, 'Position', pos);    
    
    txt = axes('Position',[0.1 0 0.8 1],'Visible','off');
    str(1) = {'All of the colored traces and histograms should overlap.'};
    str(2) = {'This shows all of the chains converged to the same place.'};
    text(0.04,.07, str, 'FontSize',10);
  end
end