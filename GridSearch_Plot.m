function figHand = GridSearch_Plot(logLikeMatrix, valuesUsed, paramNames)
  % Convert log likelihood matrix into likelihood, avoiding underflow
  likeMatrix = exp(logLikeMatrix-max(logLikeMatrix(:)));
  likeMatrix(isnan(likeMatrix)) = 0;
 
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
      axis tight;
      
      subplot(N,N,sub2ind([N N],p2,p));
      imagesc(valuesUsed{p2}, valuesUsed{p}, V);
      set(gca,'YDir','normal');
      axis tight;
    end
    
    subplot(N,N,sub2ind([N N],p,p));
    marginal = ndsum(likeMatrix, find(1:N ~= p)); 
    bar(valuesUsed{p}, marginal);
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

function x = ndsum(x,dim)
  sz = size(x);
  for i=1:length(dim)
    x = sum(x, dim(i));
  end
  sz(dim) = [];
  x = reshape(x,[sz 1 1]);
end
