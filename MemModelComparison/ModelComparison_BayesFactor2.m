%---------------------------------------------------------------------
function [MD,maxPosterior,posteriorSamples] = ModelComparison_BayesFactor(data, models)
  % Assumes models have the same number of start positions specified.
  % Should error if they don't, or maybe use the lower number but report
  % it
  numChains = size(models{1}.start,1);
  for c=1:numChains
    [chainMD(c,:), chainStored{c}] = ....
      MCMC_Chain(data, models, c);
  end
  
  for md = 1:length(models)
    % Combine values across chains
    posteriorSamples{md}.vals = [chainStored{1}{md}.vals];
    posteriorSamples{md}.like = [chainStored{1}{md}.like];
    for c=2:numChains
      posteriorSamples{md}.vals = [posteriorSamples{md}.vals; chainStored{c}{md}.vals];
      posteriorSamples{md}.like = [posteriorSamples{md}.like; chainStored{c}{md}.like];
    end
    
    % Find MAP estimate
    [~,loc]=max(posteriorSamples{md}.like);
    maxPosterior{md} = posteriorSamples{md}.vals(loc,:);
  end
  
  MD = mean(chainMD,1);
end

%---------------------------------------------------------------------
function [chainMD, posteriorSamples] = MCMC_Chain(data, models, c)
  
  % Parameters
  numMonte = 1200;
  numBurn = 500;
  
  % Set initial state
  curMD = 1; % Current model
  
  % Initialize storage of param vals for each model
  for md=1:length(models)
    models{md} = EnsureAllModelMethods(models{md});
    
    cur{md} = models{md}.start(c,:);
    
    posteriorSamples{md}.vals = zeros(numMonte*length(cur{md}), length(cur{md}));
    posteriorSamples{md}.like = zeros(numMonte*length(cur{md}), 1);
    
    asCell = num2cell(cur{md});
    curLike{md} = models{md}.logpdf(data, asCell{:});
  end
  
  MD = zeros(numMonte, 1);
  
  % Do MCMC
  for m=1:numMonte    
    % For each model
    for md=1:length(models)
      % For each parameter
      for j=1:length(cur{md})
        
        % Propose move
        new = cur{md};
        if rand>.1 % every 10 moves or so try a much bigger jump to
          % ensure we don't get stuck in local minima
          new(j) = cur{md}(j) + randn*models{md}.movestd(j);
        else
          new(j) = cur{md}(j) + randn*models{md}.movestd(j)*5;
        end
        
        % Calc likelihood of new position
        if new(j)<models{md}.lowerbound(j) || new(j)>models{md}.upperbound(j)
          like = -Inf;
        else
          asCell = num2cell(new);
          like = models{md}.logpdf(data, asCell{:});
        end
        
        % Accept with probability proportional to likelihood ratio
        if rand < exp(like - curLike{md})
          cur{md} = new;
          curLike{md} = like;
        end
        
        % Store trace of current position
        posteriorSamples{md}.vals((m-1)*length(cur{md}) + j, :) = cur{md};
        posteriorSamples{md}.like((m-1)*length(cur{md}) + j) = curLike{md};
      end
    end
    
    % Now, having resampled all model parameters, sample MD
    proposedMD = (rand>0.5) + 1;
    if rand < exp(curLike{proposedMD} - curLike{curMD})
      curMD = proposedMD;
    end
    MD(m) = curMD;
  end
  
  for md=1:length(models)
    % Throw out first newBurn samples as burn-in period
    posteriorSamples{md}.vals = posteriorSamples{md}.vals((numBurn*length(cur{md})):end,:);
    posteriorSamples{md}.like = posteriorSamples{md}.like((numBurn*length(cur{md})):end);
    chainMD(md) = mean(MD == md);
  end
end

