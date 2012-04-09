%MCMC Markov chain Monte Carlo with tuned proposals and alternative parameterization
%    [params,stored] = MCMC(data, model)
%
% To do:
%    1. Consider using an exponentially-weighted moving average covariance matrix
%       for the proposal distribution, rather than just chopping off the early burn in.
%    2. Do we want to encourage use of the MAP estimate, or something else like
%       the posterior mean or median? One option is to return all three in a params struct,
%       like params.posteriorMode, params.posteriorMean, and params.posteriorMedian.
%    3. What do you think about returning credible intervals?
%
%---------------------------------------------------------------------
function stored = MCMC(data, model)
  % Fastest if your number of start positions is the same as the number
  % of cores/processors you have  
  if matlabpool('size') == 0
    matlabpool('open');
  end
  
  if ~isfield(model, 'prior')
    model.prior = @(params)(1);
  end

  numChains = size(model.start,1);  
  parfor c=1:numChains
    chainStored(c) = ....
      MCMC_Chain(data, model.pdf, model.prior, model.start(c,:), ...
         model.lowerbound, model.upperbound, model.movestd);
  end
  
  % Combine values across chains
  stored.vals = [chainStored(1).vals];
  stored.like = [chainStored(1).like];
  stored.chain = ones(size(chainStored(1).like));
  for c=2:numChains
    stored.vals = [stored.vals; chainStored(c).vals];
    stored.like = [stored.like; chainStored(c).like];
    stored.chain = [stored.chain; ones(size(chainStored(c).like)).*c];
  end
end

%---------------------------------------------------------------------
function stored = MCMC_Chain(data, pdf, prior, ...
    start, lowerbound, upperbound, movestd)
  
  % Parameters
  numMonte = 2000;
  numBurn = 1000;
  numCovarianceTuning = 300; % number of burn in trials used to estimate cov matrix
  probabilityOfBigMove = 0.1; % probability of taking a big jump
  sizeFactorOfBigMove = 5; % a big move is bigMoveSize times bigger than normal
    
  % Set initial state
  cur = start;
  asCell = num2cell(cur);
  curLike = sum(log(pdf(data, asCell{:}))) + ...
    sum(log(prior(cur)));
  
  % Initialize storage of param vals
  stored.vals = zeros(numMonte, length(cur));
  stored.like = zeros(numMonte, 1);
  
  % Track acceptance
  acceptance = zeros(numMonte,1);
  
  % Do MCMC
  for m=1:numMonte
    if (mod(m,100)==0)
      % Progress bar? Using waitbar()?
      %waitbar(m/numMonte, waitHandle);
    end
    
    % Pick move
    % - Proposal distribution here is implicitly a mvnormal that is
    % renormalized to be truncated by the edges of the legal parameter
    % values
    tryAgain = 1;
    while tryAgain == 1
      if m > numBurn % Pick moves according to multivariate normal with correlated components
        movement = mvnrnd(zeros(1, length(cur)), burnCovariance);
      else % Pick move according to multivariate normal with independent components
        movement = randn(1,length(cur)).*movestd;
      end
      
      % Propose move
      if rand > probabilityOfBigMove
        new = cur + movement;
      else
        new = cur + sizeFactorOfBigMove.*movement;
      end
      
      % If any parameter is out of bounds, regenerate proposal
      tryAgain = any(new<lowerbound) || any(new>upperbound);
    end
    
    % Calc likelihood of new position
    if any(new<lowerbound) || any(new>upperbound)
      like = -Inf;
    else
      asCell = num2cell(new);
      like = sum(log(pdf(data, asCell{:}))) + ...
        sum(log(prior(new)));
    end
    
    % Accept with probability proportional to likelihood ratio
    if rand < exp(like - curLike)
      cur = new;
      curLike = like;
      acceptance(m) = 1; 
    end
    
    % Store trace of current position
    stored.vals(m, :) = cur;
    stored.like(m) = curLike;
    
    % Once the burn in is through, compute the covariance of the samples
    if m == numBurn
      burnCovariance = cov(stored.vals(numCovarianceTuning:numBurn, :));
    end
  end
  
  disp('MCMC chain acceptance rate:');
  disp(mean(acceptance(numBurn+1:end)));
  
  % Throw out first newBurn samples as burn-in period
  stored.vals = stored.vals(numBurn+1:end,:);
  stored.like = stored.like(numBurn+1:end);
end


