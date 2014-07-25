%MCMC MCMC with tuned proposals to get samples from posterior of model
%
%    posteriorSamples = MCMC(data, model, [optionalParameters])
%
% This function uses the Metropolis-Hastings variant of Markov Chain Monte
% Carlo (MCMC), which is applicable to a wide range of models (Metropolis et
% al., 1953; Hastings, 1970). The algorithm chooses an initial set of model
% parameters, specified in model.start, and then, over several thousands
% iterations, proposes small moves to these parameter values, accepting or
% rejecting them based on how probable the new parameter values are in both
% the prior and the likelihood function. In this way, it constructs a random
% walk that visits parameter settings with frequency proportional to their
% probability under the posterior. This allows the estimation of the full
% posterior of the model in a reasonable amount of time, and is, in the limit,
% equivalent to the more straightforward (but much slower) technique of
% evaluating the model's likelihood and prior at every possible setting of the
% parameters (implemented in the GridSearch function). For an introduction to
% MCMC, we recommend Andrieu et al. (2003).
%
% This MCMC function automatically detects convergence using the technique
% of Gelman and Rubin (1992). In short, it runs multiple chains, which are all
% started from different points and then move around the parameter space
% independently. If all the chains end up in the same place in the parameter space,
% even though they start off at very different places, this is taken as evidence
% that the MCMC function has converged and is correctly sampling from the
% posterior. Formally, this is implemented by asking whether the variance in
% the parameter values across the chains is almost the same or the same as the
% variance in the parameter values within each chain.
%
% You can make this work as a normal MCMC function without any
% convergence detection by passing it the following parameters:
%
% ... 'ConvergenceVariance', Inf, 'BurnInSamplesBeforeCheck', 5000, ...
% ... 'PostConvergenceSamples', 15000, ...
%
% This may be especially useful if the variance calculation is wrong for one of
% your models. For example, if you have data where the bias (shift) parameter
% is near 180 degrees, then if some chains settle near -180 and some near
% +180, this should be considered low-variance, but this MCMC func. will consider
% it high variance. In this case it may be useful to turn off the automatic
% convergence detection and simply run a large number of MCMC samples. The
% tutorial explains how to check for proper convergence for a fit model
% (e.g., using PlotConvergence and other functions). You should be especially
% sure to do this if you turn off the automatic convergence detection.
%
% The particular flavor of MCMC used here is adaptive during the burn-in period
% (until convergence is detected), and samples changes in all parameters jointly
% from a multivariate normal distribution. Thus, the current state of all of the
% parameters is updated in one-pass by adding a sample from the current multivariate
% normal proposal distribution to the current state. Then, this proposal is either
% accepted or rejected. Finally, after each 200 samples, the proposal distribution
% is tuned to reflect the actual covariance of the parameters across the
% samples taken so far. This process continues (independently for each chain) until
% the chains converge. This general kind of adaptive MCMC is described in
% Andrieu et al. (2003). Note that, because we expect people to make use of this
% function with only relatively simple models, we always treat the entire set of
% parameters as a single 'block' that is all sampled simultaneously.
%
% The proposal distribution is truncated at the upper and lowerbound's for each
% parameter, so that illegal moves are not proposed. This results in an asymmetric
% proposal distribution when near the bounds of a parameter. Thus, we must
% normalize the Metropolis-Hasting's algorithm to account for this break in symmetry.
%
%
function posteriorSamples = MCMC(data, model, varargin)
  % Extra arguments and parsing
  %  Verbosity = 0,  Print nothing
  %  Verbosity = 1,  Print description of chains & when convergence happens
  %  Verbosity = 2,  Print ratio of between/within chain variance for each
  %    variable on each iteration
  %  ConvergenceVariance = Ratio of between/within chain variance needed
  %    for each variable to count as convergence
  %  PostConvergenceSamples - how many samples to collect after convergence
  %  attained
  args = struct('Verbosity', 1, ...
    'ConvergenceVariance', 1.1 + log(length(model.paramNames))/10, ...
    'PostConvergenceSamples', max([6000 2000*length(model.paramNames)]), ...
    'BurnInSamplesBeforeCheck', 200);
  args = parseargs(varargin, args);

  % Ensure there is a model.prior, model.logpdf and model.pdf
  model = EnsureAllModelMethods(model);

  % Don't bother with zero-parameter models
  if(isempty(model.paramNames))
    posteriorSamples = [];
    return;
  end

  % Check if the Parallel Computing Toolbox is installed
  pass = WarnIfParallelComputingBug();
  if(pass)
    % Matlabpool open?
    try
      noParallel = 0;
      if exist('gcp') % Despite being a MATLAB command, this returns 2 for file
        if isempty(gcp('nocreate'))
          noParallel = 1;
        end
      else
        if matlabpool('size') == 0
          noParallel = 1;
        end
      end
      if noParallel
        fprintf(['\nTip: You are running MCMC without first turning on parallel\n' ...
          'processing. See Demo 6 in the tutorial for a speed boost.\n']);
      end
    end
  end

  % How many chains to run?
  numChains = size(model.start,1);
  if numChains < 2
    error('MemToolbox:MCMC_Convergence:TooFewChains', ...
      ['MCMC_Convergence requires at least 2 chains to detect convergence. ' ...
      'Please pass a model with multiple rows in model.start().']);
  end

  % Setup initial values for all chains
  for c=1:numChains
    startInfo(c).numMonte = args.BurnInSamplesBeforeCheck;
    startInfo(c).cur = model.start(c,:);
    startInfo(c).numChains = numChains;
    coMatrix = eye(length(model.movestd)); % note: this parameter is misleadingly
    coMatrix(coMatrix==1) = model.movestd; % called model.movestd when really it is
    startInfo(c).burnCovariance = coMatrix;% variance, not std
    startInfo(c).curLike = 0;
    startInfo(c).acceptance = 0;
    startInfo(c).lastOneNeededNormalization = true;
  end

  if args.Verbosity>=1
      fprintf('\n   Running %d chains...\n', numChains);
  end

  % Run chains until convergence detected
  converged = false;
  count = 0;
  while ~converged
    parfor c=1:numChains
      % Run chain
      [chainStored(c), startInfo(c)] = ....
        MCMC_Chain(data, model, startInfo(c), args.Verbosity);

      % Learn about covariance
      startInfo(c).burnCovariance = startInfo(c).burnCovariance .* 0.75 + ...
        cov(chainStored(c).vals(:, :)) .* 0.25;

      % Increase acceptance rate by making smaller moves if the current acceptance
      % rate for this chain is too low
      if startInfo(c).acceptance < 0.15
        startInfo(c).burnCovariance = startInfo(c).burnCovariance ./ 3;
      end
    end
    [converged,n] = IsConverged(chainStored, args.ConvergenceVariance, args.Verbosity);
    count = count+1;
    if ~converged && args.Verbosity > 0
      fprintf('   ... not yet converged (%d); btw/within variance: %0.2f\n', ...
        count*startInfo(1).numMonte, n);
    end
  end
  if args.Verbosity > 0
      fprintf('   ... chains converged after %d samples!\n', count*startInfo(1).numMonte);
      fprintf('   ... collecting %d samples from converged distribution\n', args.PostConvergenceSamples);
  end

  % Split the # of post-convergence samples needed between chains
  total = 0;
  for c=1:numChains-1
    total = total+ceil(args.PostConvergenceSamples / numChains);
    startInfo(c).numMonte = ceil(args.PostConvergenceSamples / numChains);
  end
  startInfo(numChains).numMonte = args.PostConvergenceSamples - total;

  % Collect args.PostConvergenceSamples samples from converged chains
  parfor c=1:numChains
    verbosity = args.Verbosity;
    if c == 1 && verbosity > 0
      verbosity = -1;
    end
    [chainStored(c), startInfo(c)] = ....
        MCMC_Chain(data, model, startInfo(c), verbosity);
  end

  % Combine values across chains
  posteriorSamples.vals = [chainStored(1).vals];
  posteriorSamples.like = [chainStored(1).like];
  posteriorSamples.chain = ones(size(chainStored(1).like));
  for c=2:numChains
    posteriorSamples.vals = [posteriorSamples.vals; chainStored(c).vals];
    posteriorSamples.like = [posteriorSamples.like; chainStored(c).like];
    posteriorSamples.chain = [posteriorSamples.chain; ones(size(chainStored(c).like)).*c];
  end
end

%---------------------------------------------------------------------
function [posteriorSamples, startInfo] = MCMC_Chain(data, model, startInfo, verbosity)

  % Parameters
  probabilityOfBigMove = 0.1; % probability of taking a big jump
  sizeFactorOfBigMove = 5; % a big move is bigMoveSize times bigger than normal

  % Set initial state
  asCell = num2cell(startInfo.cur);
  startInfo.curLike = model.logpdf(data, asCell{:}) + ...
    model.logprior(startInfo.cur);

  % Initialize storage of param vals
  posteriorSamples.vals = zeros(startInfo.numMonte, length(startInfo.cur));
  posteriorSamples.like = zeros(startInfo.numMonte, 1);

  % Track acceptance
  acceptance = zeros(startInfo.numMonte,1);
  normalizeConstant = nan(startInfo.numMonte, 2);
  wasBigMove = zeros(startInfo.numMonte, 1);
  options = statset('TolFun', 0.01);

  % Do MCMC
  for m=1:startInfo.numMonte
    % Pick move
    %  Proposal distribution here is implicitly a mvnormal that is
    % renormalized to be truncated by the edges of the legal parameter
    % values. But we don't have to sample from it directly; just resample
    % illegal values.
    curCov = startInfo.burnCovariance;
    if rand < probabilityOfBigMove
      curCov = curCov .* sizeFactorOfBigMove;
      wasBigMove(m) = 1;
    end
    tryAgain = true;
    while tryAgain
      % Propose move
      movement = mvnrnd(zeros(1, length(startInfo.cur)), curCov);
      new = startInfo.cur + movement;

      % If any parameter is out of bounds, regenerate proposal
      tryAgain = any(new<model.lowerbound) || any(new>model.upperbound);
    end

    % Calc likelihood of data at new parameters
    if any(new<model.lowerbound) || any(new>model.upperbound)
      like = -Inf;
    else
      asCell = num2cell(new);
      like = model.logpdf(data, asCell{:}) + ...
        model.logprior(new);
    end

    % Did we get close enough to the bounds of any parameters that we
    % should worry about the fact that we are sampling from a truncated
    % rather than a non-truncated normal distribution?
    probSampCur = 1;
    probSampNew = 1;
    normalize = startInfo.lastOneNeededNormalization;
    startInfo.lastOneNeededNormalization = 0;
    if any((new + sqrt(diag(curCov))'*2) > model.upperbound ...
        | (new - sqrt(diag(curCov))'*2) < model.lowerbound)
      normalize = 1;
      startInfo.lastOneNeededNormalization = 1;
    end

    % If we did, normalize Metropolis-Hastings to take this into account.
    % Don't do this if unnecessary, because mvncdf is pretty slow.
    normalConstantAtNew = NaN;
    normalConstantAtCur = NaN;
    if normalize
      normalConstantAtNew =  mvncdf(model.lowerbound, model.upperbound, ...
        new, curCov, options);
      if m>1 && ~isnan(normalizeConstant(m-1, wasBigMove(m)+1))
        normalConstantAtCur = isnan(normalizeConstant(m-1, wasBigMove(m)+1));
      else
        normalConstantAtCur =  mvncdf(model.lowerbound, model.upperbound, ...
          startInfo.cur, curCov, options);
      end
      symmetricPart = mvnpdf(startInfo.cur, new, curCov);
      probSampCur = symmetricPart ./ normalConstantAtNew;
      probSampNew = symmetricPart ./ normalConstantAtCur;
    end

    % Accept with probability proportional to likelihood ratio1
    if rand < (exp(like-startInfo.curLike)*(probSampCur./probSampNew))
      startInfo.cur = new;
      startInfo.curLike = like;
      acceptance(m) = 1;
      normalizeConstant(m, wasBigMove(m)+1) = normalConstantAtNew;
    else
      normalizeConstant(m, wasBigMove(m)+1) = normalConstantAtCur;
    end

    % Store trace of startInfo.current position
    posteriorSamples.vals(m, :) = startInfo.cur;
    posteriorSamples.like(m) = startInfo.curLike;
  end

  startInfo.acceptance = mean(acceptance);
  if verbosity >= 2
    fprintf('    MCMC chain acceptance rate: %0.2f\n', mean(acceptance));
    fprintf('    Values: ');
    fprintf('%0.2f\t', posteriorSamples.vals(end,:));
    fprintf('\n');
  end
end


%---------------------------------------------------------------------
function [b,n] = IsConverged(posteriorSamples, convergenceVariance, verbosity)
  nChains = length(posteriorSamples);
  numPerChain = size(posteriorSamples(1).vals,1);
  nParams = size(posteriorSamples(1).vals,2);

  globalMeans = zeros(1,nParams);
  for c=1:nChains
    globalMeans = globalMeans + mean(posteriorSamples(c).vals);
  end
  globalMeans = globalMeans ./ nChains;

  for v = 1:nParams
    for c=1:nChains
      vals = posteriorSamples(c).vals(:, v);
      w(c) = var(vals);
      b(c) = (mean(vals)-globalMeans(v)).^2;
    end
    W = mean(w);
    B = (numPerChain/(nChains-1)) * sum(b);
    Sp = (numPerChain-1)/(numPerChain) * W + (1/numPerChain) * B;
    r(v) = sqrt(Sp/W);
  end
  if verbosity >= 2
    fprintf('\tB/W per variable: ');
    fprintf('%0.1f ', r);
    fprintf('\n');
  end
  n = nanmean(r);
  b = all(r<convergenceVariance | isnan(r));
end


