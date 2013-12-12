%PLOTPOSTERIORCOMPARISON Show multiple posteriors at once (e.g., for two conditions)
%
%    figHand = PlotPosteriorComparison(posteriors, paramNames)
%
%  Example usage:
%   posteriorSamples1 = MCMC(MemDataset(1), model);
%   posteriorSamples2 = MCMC(MemDataset(2), model);
%   PlotPosteriorComparison({posteriorSamples1, ...
%                            posteriorSamples2}, ...
%                             model.paramNames);
%
% Posteriors can be either fullPosteriors or posteriorSamples or a mixture
% of the two.
%
function figHand = PlotPosteriorComparison(posteriors, paramNames)
  % Show 2x2 correlation for each variable with each other to look for
  % structure; Visualize both as a scatter and as a 2D histogram
  figHand = figure;
  set(gcf, 'Color', [1 1 1]);
  for i=1:length(posteriors)
    if isfield(posteriors{i}, 'vals')
      % posteriorSamples:
      cl(i)=PlotPosterior_MCMC(posteriors{i}, paramNames, i);
    elseif isfield(posteriors{i}, 'propToLikeMatrix')
      % fullPosterior:
      cl(i) = PlotPosterior_GridSearch(posteriors{i}, paramNames, i);
    end
  end
  N = length(paramNames);
  subplot(N,N,sub2ind([N N],N,1));
  l = legend(cl, num2str((1:length(posteriors))'), 'Location', 'NorthEast');
  pos = get(l, 'Position');
  set(l, 'Position', [pos(1)+0.05, pos(2)+0.04, pos(3), pos(4)]);
end

function cl=PlotPosterior_MCMC(posteriorSamples, paramNames, w)
  % Plot correlation
  N = length(paramNames);
  cols = palettablecolors(w);
  for p=1:N
    for p2=1:(p-1)
      subplot(N,N,sub2ind([N N],p,p2)); hold on;
      [V,C] = hist3(posteriorSamples.vals(:,[p p2]), [15 15]);
      V = V ./ max(V(:));
      ch=imagesc(C{1}, C{2}, V');
      set(ch, 'AlphaData', V');
      h = 1/9*ones(3);
      VS = filter2(h,V);
      [cont,cl]=contour(C{1}, C{2}, VS', 1, 'Color', cols(w,:), 'LineWidth', 3);
      set(gca,'YDir','normal');
      set(gca, 'box', 'off');
      axis tight;
      ylim([min(ylim)-(max(ylim)-min(ylim))/3 max(ylim)+(max(ylim)-min(ylim))/3]);
      xlim([min(xlim)-(max(xlim)-min(xlim))/3 max(xlim)+(max(xlim)-min(xlim))/3]);

      subplot(N,N,sub2ind([N N],p2,p)); hold on;
      ch=imagesc(C{2}, C{1}, V);
      set(ch, 'AlphaData', V);
      contour(C{2}, C{1}, VS, 1, 'Color', cols(w,:), 'LineWidth', 3);
      set(gca,'YDir','normal');
      set(gca, 'box', 'off');
      axis tight;
      ylim([min(ylim)-(max(ylim)-min(ylim))/3 max(ylim)+(max(ylim)-min(ylim))/3]);
      xlim([min(xlim)-(max(xlim)-min(xlim))/3 max(xlim)+(max(xlim)-min(xlim))/3]);
    end
    subplot(N,N,sub2ind([N N],p,p)); hold on;
    [n,x] = hist(posteriorSamples.vals(:,p));
    n = n./max(n(:));
    h1=bar(x,n, 'FaceColor',cols(w,:),'EdgeColor',cols(w,:));
    hPatch = findobj(h1,'Type','patch');
    set(hPatch,'FaceAlpha',0.4);
    axis tight;
    xlim([min(xlim)-(max(xlim)-min(xlim))/3 max(xlim)+(max(xlim)-min(xlim))/3]);
    set(gca, 'YTick', []);
    set(gca, 'box', 'off');
    subplot(N,N,sub2ind([N N],p,1));
    title(paramNames{p}, 'FontSize', 15);
    subplot(N,N,sub2ind([N N],1,p));
    ylabel(paramNames{p}, 'FontSize', 15);
  end

  % Comestics
  map = gray;
  colormap(map(end:-1:1,:));
end

function cl=PlotPosterior_GridSearch(fullPosterior, paramNames, w)
  % Shorten names
  likeMatrix = fullPosterior.propToLikeMatrix;
  valuesUsed = fullPosterior.valuesUsed;

  % Show 2x2 correlation for each variable with each other to look for
  % structure; Visualize both as a scatter and as a 2D histogram
  N = length(paramNames);
  cols = palettablecolors(w);
  for p=1:N
    for p2=1:(p-1)
      subplot(N,N,sub2ind([N N],p,p2)); hold on;
      V = ndsum(likeMatrix,  find(1:N ~= p & 1:N ~= p2));
      V = V ./ max(V(:));
      ch=imagesc(valuesUsed{p}, valuesUsed{p2}, V);
      set(ch, 'AlphaData', V);
      [cont,cl]=contour(valuesUsed{p}, valuesUsed{p2}, V, 1, 'Color', cols(w,:), 'LineWidth', 3);
      set(gca,'YDir','normal');
      set(gca, 'box', 'off');
      axis tight;
      ylim([min(ylim)-(max(ylim)-min(ylim))/3 max(ylim)+(max(ylim)-min(ylim))/3]);
      xlim([min(xlim)-(max(xlim)-min(xlim))/3 max(xlim)+(max(xlim)-min(xlim))/3]);

      subplot(N,N,sub2ind([N N],p2,p)); hold on;
      ch=imagesc(valuesUsed{p2}, valuesUsed{p}, V');
      set(ch, 'AlphaData', V');
      contour(valuesUsed{p2}, valuesUsed{p}, V', 1, 'Color', cols(w,:), 'LineWidth', 3);
      set(gca,'YDir','normal');
      set(gca, 'box', 'off');
      axis tight;
      ylim([min(ylim)-(max(ylim)-min(ylim))/3 max(ylim)+(max(ylim)-min(ylim))/3]);
      xlim([min(xlim)-(max(xlim)-min(xlim))/3 max(xlim)+(max(xlim)-min(xlim))/3]);
    end

    subplot(N,N,sub2ind([N N],p,p)); hold on;
    marginal = ndsum(likeMatrix, find(1:N ~= p));
    marginal = marginal ./ max(marginal(:));
    h1=bar(valuesUsed{p}, marginal, 'FaceColor',cols(w,:),'EdgeColor',cols(w,:));
    hPatch = findobj(h1,'Type','patch');
    set(hPatch,'FaceAlpha',0.4);
    axis tight;
    xlim([min(xlim)-(max(xlim)-min(xlim))/3 max(xlim)+(max(xlim)-min(xlim))/3]);
    set(gca, 'YTick', []);
    set(gca, 'box', 'off');
    subplot(N,N,sub2ind([N N],p,1));
    title(paramNames{p}, 'FontSize', 15);
    subplot(N,N,sub2ind([N N],1,p));
    ylabel(paramNames{p}, 'FontSize', 15);
  end

  % Comestics
  map = gray;
  colormap(map(end:-1:1,:));
end
