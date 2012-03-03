function MCMC_Example()
    % Example data
    d = load('MemData/data.mat');
    
    % Setup
    paramNames = {'g', 'K'};
    start = [.2, 10;  % g, K
             .4, 15;  % g, K
             .1, 20]; % g, K
    
    % Run
    [params, stored] = MCMC(d.data(:), ... % Data
        @MixtureModel, ... % Likelihood function
        start, ... % Start positions for each chain (#rows = #chains)
        [0 0], ... % Lower bound for the parameters
        [1 Inf], ... % Upper bounds for the parameters
        [.02, .1]); % How big a step to take when searching each parameter
    
    % Maximum likelihood parameters from MCMC
    disp('MLE from MCMC():');
    disp(params);

    % Show fit
    PlotData(params, d.data(:));
    
    % Show a figure with each parameter's correlation with each other
    MCMC_Plot(stored, paramNames);
    
    % Sanity check: Use mle() built-in function
    disp('MLE from mle():');
    params_mle = mle(d.data(:), ... % Data
        'pdf', @MixtureModel, ... % Likelihood function
        'start', start(1,:), ... % Start position
        'lowerbound', [0 0], ... % Lower bound for the parameters
        'upperbound', [1 Inf]);  % Upper bounds for the parameters
    disp(params_mle);
end

function l = MixtureModel(data, g, K)
    l = (1-g).*vonmisespdf(data,0,K) + (g).*unifpdf(data,-pi,pi);
end

function PlotData(params, data)
    % Plot data fit
    figure; 
    
    % Plot data histogram
    x = linspace(-pi, pi, 55)'; 
    n = histc(data, x);
    bar(x, n./sum(n), 'EdgeColor', [1 1 1], 'FaceColor', [.8 .8 .8]);
    xlim([-pi pi]); hold on;
    
    % Plot scaled version of the prediction
    vals = linspace(-pi, pi, 500)'; 
    p = MixtureModel(vals, params(1), params(2));
    multiplier = length(vals)/length(x);
    plot(vals, p ./ sum(p(:)) * multiplier, 'b--', 'LineWidth', 2);
    xlabel('Error (radians)');
    ylabel('Probability');
end