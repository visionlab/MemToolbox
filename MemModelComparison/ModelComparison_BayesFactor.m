%---------------------------------------------------------------------
function [MD,params,stored] = ModelComparison_BayesFactor(data, models)
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
    stored{md}.vals = [chainStored{1}{md}.vals];
    stored{md}.like = [chainStored{1}{md}.like];
    for c=2:numChains
      stored{md}.vals = [stored{md}.vals; chainStored{c}{md}.vals];
      stored{md}.like = [stored{md}.like; chainStored{c}{md}.like];
    end
    
    % Find MAP estimate
    [~,loc]=max(stored{md}.like);
    params{md} = stored{md}.vals(loc,:);
  end
  
  MD = mean(chainMD,1);
end

%---------------------------------------------------------------------
function [chainMD, stored] = MCMC_Chain(data, models, c)
  
  % Parameters
  numMonte = 1200;
  numBurn = 500;
  
  % Set initial state
  curMD = 1; % Current model
  
  % Initialize storage of param vals for each model
  for md=1:length(models)
    cur{md} = models{md}.start(c,:);
    
    stored{md}.vals = zeros(numMonte*length(cur{md}), length(cur{md}));
    stored{md}.like = zeros(numMonte*length(cur{md}), 1);
    
    asCell = num2cell(cur{md});
    curLike{md} = sum(log(models{md}.pdf(data, asCell{:})));
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
          like = sum(log(models{md}.pdf(data, asCell{:})));
        end
        
        % Accept with probability proportional to likelihood ratio
        if rand < exp(like - curLike{md})
          cur{md} = new;
          curLike{md} = like;
        end
        
        % Store trace of current position
        stored{md}.vals((m-1)*length(cur{md}) + j, :) = cur{md};
        stored{md}.like((m-1)*length(cur{md}) + j) = curLike{md};
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
    stored{md}.vals = stored{md}.vals((numBurn*length(cur{md})):end,:);
    stored{md}.like = stored{md}.like((numBurn*length(cur{md})):end);
    chainMD(md) = mean(MD == md);
  end
end

