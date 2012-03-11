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
function [params,stored] = MCMC(data, model)
  % Fastest if your number of start positions is the same as the number
  % of cores/processors you have
  try, matlabpool, end
  numChains = size(model.start,1);

  if ~isfield(model, 'prior')
    model.prior = @(params)(1);
  end
  
  parfor c=1:numChains
    chainStored(c) = ....
      MCMC_Chain(data, model.pdf, model.prior, model.start(c,:), ...
         model.lowerbound, model.upperbound, model.movestd);
  end
  
  % Combine values across chains
  stored.vals = [chainStored(1).vals];
  stored.like = [chainStored(1).like];
  for c=2:numChains
    stored.vals = [stored.vals; chainStored(c).vals];
    stored.like = [stored.like; chainStored(c).like];
  end
  
  % Find MAP estimate
  [~,b]=max(stored.like);
  params = stored.vals(b,:);
end

%---------------------------------------------------------------------
function stored = MCMC_Chain(data, pdf, prior, ...
    start, lowerbound, upperbound, movestd)
  
  % Parameters
  numMonte = 3000;
  numBurn = 1000;
  numCovarianceTuning = 500; % number of burn in trials used to estimate cov matrix
  probabilityOfBigMove = 0.1; % probability of taking a big jump
  sizeFactorOfBigMove = 5; % a big move is bigMoveSize times bigger than normal
  
  % Set acceptance counter to 0
  numAcceptances = 0;
  
  % Set initial state
  cur = start;
  asCell = num2cell(cur);
  curLike = sum(log(pdf(data, asCell{:}))) + ...
    sum(log(prior(cur)));
  
  % Initialize storage of param vals
  stored.vals = zeros(numMonte, length(cur));
  stored.like = zeros(numMonte, 1);
  
  % Do MCMC
  for m=1:numMonte
    if (mod(m,100)==0)
      % Progress bar? Using waitbar()?
      %waitbar(m/numMonte, waitHandle);
    end
    
    % Pick move
    if m > numBurn % pick moves according to multivariate normal with correlated components
      movement = mvnrnd(zeros(1, length(cur)), burnCovariance);
    else % pick move according to multivariate normal with independent components
      movement = randn(1,length(cur)).*movestd;
    end
    
    % Propose move
    if rand > probabilityOfBigMove
      new = cur + movement;
    else
      new = cur + sizeFactorOfBigMove.*movement;
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
      
      if(m > numBurn) % if we're past the burn in, count this as an acceptance
        numAcceptances = numAcceptances + 1;
      end
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
  disp(numAcceptances/(numMonte-numBurn));
  
  % Throw out first newBurn samples as burn-in period
  stored.vals = stored.vals(numBurn+1:end,:);
  stored.like = stored.like(numBurn+1:end);
end


