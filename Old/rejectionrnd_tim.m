% hi tim. i stole your modelrnd_tim and created a new modelrnd.m that uses rejection
% sampling only when a more efficient generator has not been specified in the
% model structure. i added an efficient generator to StandardMixtureModel.

function Test()
  pdf = @(x, mu, sigma, g) (1-g)*normpdf(x,mu,sigma) + g*unifpdf(x,-pi,pi);
  
  % Jordan method
  tic
  for i=1:100
    vals = modelrnd(pdf, {0, .5, .5}, [3000, 1]);
  end
  toc
  figure(1);
  hist(vals,40);
  
  % My method
  tic
  for i=1:100
    vals = modelrnd_tim(pdf, {0, .5, .5}, [3000, 1]);
  end
  toc 
  figure(2);
  hist(vals,40);
  
  % Dont need to know peak
  tic
  for i=1:100
    vals = mcmcParallel(pdf, {0, .5, .5}, [3000, 1]);
  end
  size(vals)
  toc 
  figure(3);
  hist(vals,40);
  
end

function r = mcmcParallel(pdf, params, dims)
  burn = 10;
  thin = 2;
  proposals = rand(prod(dims)*thin+burn, 1).*2.*pi - pi;
  pdfVals = pdf(proposals, params{:});
  curLike = pdfVals(1);
  cur = proposals(1);
  for m=1:length(proposals)
      newLike = pdf(proposals(m), params{:});
      if rand < newLike/curLike
          cur = proposals(m);
          curLike = newLike;
      else
          proposals(m) = cur;
      end
  end
  r = reshape(proposals(burn+1:thin:end), dims);
end

function samples = mcmcSamp(pdf, params, dims)
  % preallocate arrays
  n = prod(dims);
  burn = 100;
  samples = zeros(dims);
  
  cur = rand*2*pi - pi;
  for m = 1:(burn+n)
      new = rand*2*pi - pi;
      if rand < pdf(new, params{:})/pdf(cur, params{:})
          cur = new;
      end
      if m>burn
          samples(m-burn) = cur;
      end
  end
end



function r = modelrnd_tim(pdf, params, dims)
  % preallocate arrays
  n = prod(dims);
  samples = [];
  
  num = 1;
  M = pdf(0, params{:}) * 2 * 2*pi;
  while num < n
    u = rand(n*10,1);
    curSamples = rand(n*10,1).*2*pi - pi;
    pass = u < (pdf(curSamples, params{:})./M);
    sPass = sum(pass);
    samples(num:num+sPass-1) = curSamples(pass);
    num = num + sPass;
  end
  
  r = reshape(samples(1:n), dims);
end


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


