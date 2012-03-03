function RandomSample_Example()
    
    % Start with a normal pdf (but can be anything)
    % -------------------------------------------------
    pdf = @(x, mu, sigma) normpdf(x,mu,sigma);
    
    % Generate samples from it using a few methods...
    figure(1);
    subplot(3,1,1);
    
    % Sample a [1500,1] matrix from pdf(x, 0, 1)
    vals = Sample_InverseTransform(pdf, {0, 1}, [1500, 1]);
    hist(vals(:),30);
    xlim([-pi pi]);
    
    subplot(3,1,2);
    % Sample a [1500,1] matrix from pdf(x, 0, 1)
    vals = Sample_Rejection(pdf, {0, 1}, [1500, 1]);
    hist(vals(:),30);    
    xlim([-pi pi]);
    
    subplot(3,1,3);
    % Compare to true normal distribution
    vals = randn(1500,1);
    hist(vals(:),30); 
    xlim([-pi pi]);
    
   
    % Try a more interesting distribution (mixture)
    % -------------------------------------------------
    figure(2);
    pdf = @(x, mu, sigma, g) (1-g)*normpdf(x,mu,sigma) + g*unifpdf(x,-pi,pi);

    subplot(2,1,1);
    % Sample from pdf(x, 0, 1, 0.5)
    vals = Sample_InverseTransform(pdf, {0, 1, .5}, [1500, 1]);
    hist(vals(:),30);
    xlim([-pi pi]);
    
    subplot(2,1,2);
    % Sample from pdf(x, 0, 1, 0.5)
    vals = Sample_Rejection(pdf, {0, 1, .5}, [1500, 1]);
    hist(vals(:),30);    
    xlim([-pi pi]);
        
end

% Generates samples by Inverse Transform Sampling. Can only generate
% samples from the discrete values xVals, but since we know the area we
% care about is only -pi to pi, thats probably OK
function samples = Sample_InverseTransform(pdf, params, size)
    xVals = linspace(-pi,pi,5000);
    y = cumsum(pdf(xVals, params{:}));
    y = y ./ max(y);
    
    samples = rand(size);
    for i=1:numel(samples)
        [~,b] = min(abs(y - samples(i)));
        samples(i) = xVals(b);
    end
end

% Generates samples by Rejection Sampling. Depends on knowing the highest
% point in the distribution -- here I'm just assuming that happens at 0
function samples = Sample_Rejection(pdf, params, size)
    samples = [];
    
    % Assume nothing in the pdf is more than twice as high as the value at
    % exactly 0
    M = pdf(0, params{:}) * 2;
    
    % Generate samples
    while length(samples) < prod(size)
        u = rand;
        gX = rand*2*pi - pi;
        if u < pdf(gX, params{:})/M*unifpdf(gX, -pi, pi)
            samples(end+1) = gX;
        end
    end
end



