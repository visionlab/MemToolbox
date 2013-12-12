%PLOTPOSTERIOR Show 2x2 correlation for each variable with each other
% This allows you to visualize the entire posterior (what you should
% believe about the parameters, given the data you've seen).
%
%   figHand = PlotPosterior(posterior, paramNames)
%
% posterior can be either a posteriorSamples, from MCMC, or a
% fullPosterior, from GridSearch.
%
function figHand = PlotPosterior(posterior, paramNames)
  % Show 2x2 correlation for each variable with each other to look for
  % structure; Visualize both as a scatter and as a 2D histogram
  if isfield(posterior, 'vals')
    % posteriorSamples:
    figHand = PlotPosterior_MCMC(posterior, paramNames);
  elseif isfield(posterior, 'propToLikeMatrix')
    % fullPosterior:
    figHand = PlotPosterior_GridSearch(posterior, paramNames);
  end
end

function figHand = PlotPosterior_MCMC(posteriorSamples, paramNames)
  % Plot correlation
  figHand = figure;
  N = length(paramNames);
  for p=1:N
    for p2=1:(p-1)
      subplot(N,N,sub2ind([N N],p,p2));
      [V,C] = hist3(posteriorSamples.vals(:,[p p2]), [15 15]);
      imagesc(C{1}, C{2}, V');
      set(gca,'YDir','normal');
      set(gca, 'box', 'off');
      axis tight;

      subplot(N,N,sub2ind([N N],p2,p));
      imagesc(C{2}, C{1}, V);
      set(gca,'YDir','normal');
      set(gca, 'box', 'off');
      axis tight;
    end
    subplot(N,N,sub2ind([N N],p,p));
    hist(posteriorSamples.vals(:,p));
    ylabel('frequency', ...
        'FontSize', 14, 'Interpreter', 'latex');
    axis tight;
    set(gca, 'YTick', []);
    set(gca, 'box', 'off');
    subplot(N,N,sub2ind([N N],p,1));
    title(['{\makebox[1in][c]{\bf{' paramNames{p} '}}}'], ...
      'FontSize', 14, ...
      'Interpreter','latex')
    subplot(N,N,sub2ind([N N],1,p));
    if p==1
      ylabel({['{\makebox[1in][c]{\bf{' paramNames{p} '}}}'], ...
        '{\makebox[1in][c]{frequency}}'}, ...
        'FontSize', 14, ...
        'Interpreter','latex')
    else
      ylabel(['$\bf{' paramNames{p} '}$'], ...
        'FontSize', 14, 'Interpreter', 'latex');
    end

  end

  % Comestics
  colormap(palettablecolormap('sequential'));
  makepalettable(figHand);
end

function figHand = PlotPosterior_GridSearch(fullPosterior, paramNames)
  % Shorten names
  likeMatrix = fullPosterior.propToLikeMatrix;
  valuesUsed = fullPosterior.valuesUsed;

  % Show 2x2 correlation for each variable with each other to look for
  % structure; Visualize both as a scatter and as a 2D histogram
  figHand = figure;
  N = length(paramNames);
  for p=1:N
    for p2=1:(p-1)
      subplot(N,N,sub2ind([N N],p,p2));
      V = ndsum(likeMatrix,  find(1:N ~= p & 1:N ~= p2));
      imagesc(valuesUsed{p}, valuesUsed{p2}, V);
      set(gca,'YDir','normal');
      set(gca, 'box', 'off');
      axis tight;

      subplot(N,N,sub2ind([N N],p2,p));
      imagesc(valuesUsed{p2}, valuesUsed{p}, V');
      set(gca,'YDir','normal');
      set(gca, 'box', 'off');
      axis tight;
    end

    subplot(N,N,sub2ind([N N],p,p));
    marginal = ndsum(likeMatrix, find(1:N ~= p));
    h = bar(valuesUsed{p}(:), marginal(:));
    set(h, 'LineStyle','none');
    axis tight;
    set(gca, 'YTick', []);
    set(gca, 'box', 'off');
    ylabel('frequency', ...
      'FontSize', 14, 'Interpreter', 'latex');
    subplot(N,N,sub2ind([N N],p,1));
    title(['{\makebox[1in][c]{\bf{' paramNames{p} '}}}'], ...
      'FontSize', 14, ...
      'Interpreter','latex')
    subplot(N,N,sub2ind([N N],1,p));
    if p==1
      ylabel({['{\makebox[1in][c]{\bf{' paramNames{p} '}}}'], ...
        '{\makebox[1in][c]{frequency}}'}, ...
        'FontSize', 14, ...
        'Interpreter','latex')
    else
      ylabel(['$\bf{' paramNames{p} '}$'], ...
        'FontSize', 14, 'Interpreter', 'latex');
    end
  end

  % Comestics
  colormap(palettablecolormap('sequential'));
  makepalettable(figHand);
end
