% MODELRND generates samples by rejection sampling. Depends on knowing the
% highest point in the distribution -- here I'm just assuming that happens
% at 0. 

function r = modelrnd(pdf, params, dims)
    
    % preallocate arrays
    n = numel(zeros(dims));
    pass = zeros(n, 1);
    samples = zeros(n, 1);

    % Assume nothing in the pdf is more than twice as high as the value at
    % exactly 0
    M = pdf(0, params{:}) * 2;
    
    % (This is a normalizing constant?)
    uniformComponent = unifpdf(0, -pi, pi);

    % Generate the samples
    while any(~pass)
        u = rand(sum(~pass), 1); % generate a random number for each failer
        gX = rand(sum(~pass), 1).*2*pi - pi; % generate proposals for failers
        samples(~pass) = gX; %
        pass(~pass) = u < (pdf(gX, params{:})./M)*uniformComponent;
    end
    r = reshape(samples, size(zeros(dims)));
end