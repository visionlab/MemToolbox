%MCMC Markov chain Monte Carlo
%    [params,stored] = MCMC(data, pdf, start, lowerbound, upperbound, movestd)
%---------------------------------------------------------------------
function [params,stored] = MCMC(data, pdf, start, lowerbound, upperbound, movestd)
   % Fastest if your number of start positions is the same as the number
   % of cores/processors you have
   try, matlabpool, end
   numChains = size(start,1);
   parfor c=1:numChains
       [~, chainStored(c)] = ....
           MCMC_Chain(data, pdf, start(c,:), lowerbound, upperbound, movestd)
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
function [params,stored] = MCMC_Chain(data, pdf, start, lowerbound, upperbound, movestd)
    % Parameters
    numMonte = 3000;
    numBurn = 1000;
    
    % Set initial state
    cur = start;
    asCell = num2cell(cur);           
    curLike = sum(log(pdf(data, asCell{:})));
    
    % Initialize storage of param vals
    stored.vals = zeros(numMonte*length(cur), length(cur));
    stored.like = zeros(numMonte*length(cur), 1);
    
    % Do MCMC
    for m=1:numMonte
        if (mod(m,100)==0)
            % Progress bar? Using waitbar()?
        end
        for j=1:length(cur)
           % Propose move
           new = cur;
           if rand>.1 % every 10 moves or so try a much bigger jump to 
                      % ensure we don't get stuck in local minima
               new(j) = cur(j) + randn*movestd(j);
           else
               new(j) = cur(j) + randn*movestd(j)*5;
           end
           
           % Calc likelihood of new position
           if new(j)<lowerbound(j) || new(j)>upperbound(j)
               like = -Inf;
           else
               asCell = num2cell(new);
               like = sum(log(pdf(data, asCell{:})));
           end
           
           % Accept with probability proportional to likelihood ratio
           if rand < exp(like - curLike)
               cur = new;
               curLike = like;
           end
           
           % Store trace of current position
           stored.vals((m-1)*length(cur) + j, :) = cur;
           stored.like((m-1)*length(cur) + j) = curLike;
        end
    end
    
    % Throw out first newBurn samples as burn-in period
    stored.vals = stored.vals((numBurn*length(cur)):end,:);
    stored.like = stored.like((numBurn*length(cur)):end);
    
    % Use posterior mean as best parameters; can also use max like from
    % storedLike[] to index into stored[] to get mle parameters
    params = mean(stored.vals);
end