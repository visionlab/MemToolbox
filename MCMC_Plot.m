function MCMC_Plot(stored, paramNames)
    % Show 2x2 correlation for each variable with each other to look for
    % structure; Visualize both as a scatter and as a 2D histogram
    figure;
    N = length(paramNames);
    for p=1:N
        for p2=1:(p-1)
            subplot(N,N,sub2ind([N N],p,p2));
            hist3(stored.vals(:,[p p2]), [20 20]);
            set(get(gca,'child'), 'FaceColor', 'interp', 'CDataMode', ...
                'auto', 'LineWidth', 0.001, 'EdgeColor', 'none');
            view(2); axis tight;
            
            subplot(N,N,sub2ind([N N],p2,p));
            hist3(stored.vals(:,[p p2]), [20 20]);
            set(get(gca,'child'), 'FaceColor', 'interp', 'CDataMode', ...
                'auto', 'LineWidth', 0.001, 'EdgeColor', 'none');
            view(2); axis tight;
        end
        subplot(N,N,sub2ind([N N],p,p));
        hist(stored.vals(:,p));
        subplot(N,N,sub2ind([N N],p,1));
        title(paramNames{p}, 'FontSize', 15);
        subplot(N,N,sub2ind([N N],1,p));
        ylabel(paramNames{p}, 'FontSize', 15);
    end

	% comestics
	colormap(palettablecolormap);
	palettablehistogram;
end