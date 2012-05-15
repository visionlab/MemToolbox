% takes a data struct from MemData repository and simulates a new data set
% based on those parameters.
%
% Example usage:
% 
%   data = memdata2mtb(MemData(16);
%
function data = memdata2mtb(mData,trialsPerCondition)

  if(nargin < 2)
    trialsPerCondition = 1000;
  end
  
  if(numel(mData.n) == 1)
    mData.n = ones(1,length(mData.times))*mData.n;
  end 
  
  order = shuffle(repmat(1:length(mData.times), [1, trialsPerCondition]));
  
  data.time = mData.times(order);
  data.n = mData.n(order);
  
  if(isfield(mData,'precision'))
    data.precision = mData.precision(order);
  else % if there's no precision, sample it from the prior
    data.precision = ones(1,length(data.time))*24;
  end
  
  if(isfield(mData,'numStored'))
    data.numStored = mData.numStored(order);
  else
    ; % if there's no numStored, sample it from the prior
  end
  
  for i = 1:length(order)
    
    mu = 0;
    g = 1 - data.numStored(i)/data.n(i);
    SD = data.precision(i);
    
    data.errors(i) = modelrnd(StandardMixtureModelWithBiasSD, {mu,g,SD}); % params: mu, g, SD
  end
end


% [Y,index] = Shuffle(X)
%
% Randomly sorts X.
% If X is a vector, sorts all of X, so Y = X(index).
% If X is an m-by-n matrix, sorts each column of X, so
%	for j=1:n, Y(:,j)=X(index(:,j),j).
%
% Also see SORT, Sample, Randi, and RandSample.
function [Y,index] = shuffle(X)
  [null,index] = sort(rand(size(X)));
  [n,m] = size(X);
  Y = zeros(size(X));
  if (n == 1 | m == 1)
  	Y = X(index);
  else
  	for j = 1:m
  		Y(:,j)  = X(index(:,j),j);
  	end
  end
end