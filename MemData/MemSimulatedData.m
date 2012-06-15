% MemSimulatedData - Return simulated data from a published experimental
% setup
%
% Parameters:
%   MemSimulatedData(experimentNumber, trialsPerCondition)
%    
%   experimentNumber - detailed below
%   trialsPerCondition - how many trials to simulate in each condition
%
% experimentNumber:
% (1) sperling (1960) partial report data.
% (2) adelson & jonides (1980) patial report figure 2 panel a
% this panel is special because its stimuli were displayed at a
% luminance low enough that it affected visibility.
% (3) adelson & jonides (1980) patial report figure 2 panel b
% ...
%

function data = MemSimulatedData(whichData, trialsPerCondition)
  if(nargin < 1)
    whichData = 1;
  end
    
  if(nargin < 2)
    trialsPerCondition = 1000;
  end
  
  switch whichData
    case 1
      % sperling (1960) partial report data.
      data.times = [0 150 300 1000];
      data.n = 12;
      data.numStored = [9.3, 7.3, 6.2, 4.5];
      data.goodFitMoran = [16, 12.3, -1.28, 0.71];
      
    case 2
      % adelson & jonides (1980) patial report figure 2 panel a
      % this panel is special because its stimuli were displayed at a
      % luminance low enough that it affected visibility.
      data.times = [0, 50, 100, 200, 300, 1000]; % moved -100 precue to 0
      data.n = 8;
      data.numStored = [6.4, 5.9, 5.7, 4.8, 4.6, 3.7];
      
    case 3
      % adelson & jonides (1980) patial report figure 2 panel b
      data.times = [0, 50, 100, 200, 300, 1000]; % moved -100 precue to 0
      data.n = 8;
      data.numStored = [7.7, 7.0, 6.3, 5.2, 4.7, 3.9];
      
    case 4
      % adelson & jonides (1980) patial report figure 2 panel c
      data.times = [0, 50, 100, 200, 300, 1000]; % moved -100 precue to 0
      data.n = 8;
      data.numStored = [7.9, 6.9, 6.3, 5.8, 5.0, 4.5];
      
    case 5
      % adelson & jonides (1980) patial report figure 2 panel c
      data.times = [0, 50, 100, 200, 300, 1000]; % moved -100 precue to 0
      data.n = 8;
      data.numStored = [7.9, 7.0, 6.9, 5.7, 5.1, 4.1];
      
    case 6
      % zhang & luck (2008) working memory figure 2
      data.times = [900];
      data.n = [1, 2, 3, 6];
      data.numStored = [0.99, 1.9, 2.49, 2.28];
      data.precision = [13.9, 19.4, 21.9, 22.3];
      
    case 7
      % bays & husain (2008) figure 2b, location
      data.times = [500];
      data.n = [1, 2, 4, 6];
      data.precision = [0.96, 1.6, 2.9, 6.3];
      
    case 8
      % bays & husain (2008) figure 2b, orientation
      data.times = [500];
      data.n = [1, 2, 4, 6];
      data.precision = [18.9, 28.6, 52.6, 55.6];
      
    case 9
      % hahn (2010), figure 2, healthy controls
      % excludes -200 ms precue
      data.times = [0, 33, 67, 100, 150, 200, 250, 350, 500, 750, 1000];
      data.n = 6;
      data.proportionCorrect = [.871, .845, .827, .819, .778, .759, .716, .662, .568, .572, .499];
      data.m = 15; % number of alternatives (15 possible letters)
      data.numStored = [5.17, 5.00, 4.89, 4.84, 4.57, 4.45, 4.17, 3.83, 3.22, 3.25, 2.78];
      
    case 10
      % hahn (2010), figure 2, people with schizophrenia
      % excludes -200 ms precue
      data.times = [0, 33, 67, 100, 150, 200, 250, 350, 500, 750, 1000];
      data.n = 6;
      data.proportionCorrect = [0.791, 0.737, 0.716, 0.701, 0.678, 0.641, 0.611, 0.563, 0.485, 0.487, 0.434];
      data.m = 15;
      data.numStored = [4.66, 4.31, 4.17, 4.08, 3.93, 3.69, 3.51, 3.19, 2.69, 2.70, 2.36];
      data.goodFitMoran = [9,3.25,-4.02,3]; % nQ, tC, tau, s
      
    case 11
      % yang (1999), fig. 3.11, subject LX
      data.times = [67, 341, 536, 744, 1140, 1936, 2932];
      data.n = 8;
      data.proportionCorrect = [0.938, 0.735, 0.652, 0.587, 0.507, 0.416, 0.351];
      data.m = 4;
      data.numStored = [7.34, 5.17, 4.29, 3.59, 2.74, 1.77, 1.08];
      
    case 12
      % yang (1999), fig. 3.11, subject YS
      data.times = [62, 163, 261, 366, 564, 960, 1462];
      data.n = 8;
      data.proportionCorrect = [0.792, 0.695, 0.607, 0.536, 0.472, 0.415, 0.410];
      data.m = 4;
      data.numStored = [5.78, 4.75, 3.81, 3.05, 2.37, 1.76, 1.71];
      data.goodFitMoran = [9, 20, 0, 15.5510];
      
    case 13
      % yang (1999), fig. 3.11, subject WY
      data.times = [62, 163, 261, 366, 564, 960, 1462];
      data.n = 8;
      data.proportionCorrect = [0.860, 0.759, 0.682, 0.643, 0.580, 0.505, 0.468];
      data.m = 4;
      data.numStored = [6.51, 5.43, 4.61, 4.19, 3.52, 2.72, 2.33];
      data.goodFitMoran = [10, 22, -0.75, 15.5510];
      
    case 14
      % yang (1999), fig. 3.11, subject KB
      data.times = [62, 163, 261, 366, 564, 960, 1462];
      data.n = 8;
      data.proportionCorrect = [0.906, 0.810, 0.728, 0.697, 0.584, 0.526, 0.496];
      data.m = 4;
      data.numStored = [7.00, 5.97, 5.10, 4.77, 3.56, 2.94, 2.62];
      data.goodFitMoran = [11, 32.5478, 0.3903, 23.0860];
      
    case 15
      % in house zhang & luck (2009) replication
      % moves -100 ms precue to 0 ms
      data.times = [0, 150, 300, 1000, 4000, 10000];
      data.n = 3;
      data.numStored = [2.8263, 2.6732, 2.4895, 2.5741, 2.1076, 1.8662];
      
    case 16
      % zhang & luck (2009) sudden death, color
      data.times = [1000, 4000, 10000];
      data.n = 3;
      data.numStored = [2.22, 2.22, 1.83];
      data.precision = [22.9, 24.4, 24.4];
      
    case 17
      % zhang & luck (2009) sudden death, shape
      data.times = [1000, 4000, 10000];
      data.n = 3;
      data.numStored = [1.80, 1.74, 1.38];
      data.precision = [29.0, 34.0, 37.0];
      
    case 18
      % simulated from standard model
      data.n = 12;
      data.times =  [0.10, 0.167, 0.2783, 0.4642, 0.7743, 1.2915, 2.1544, 3.5938, 5.9948, 10];
      data.numStored = [11, 10.7, 9.9, 8.6, 7, 5.4, 3.9, 3.0, 2.6, 2.3];
      
    otherwise
      error('Sorry, that''s not one of the available datasets.')
  end
  
  data = MemData2MTB(data, trialsPerCondition);
end

% Takes a data struct from MemData repository and simulates a new data set
% based on those parameters.
% Example usage:
%   data = memdata2mtb(MemData(16));
function data = MemData2MTB(mData,trialsPerCondition)
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
    
    data.errors(i) = SampleFromModel(StandardMixtureModelWithBiasSD, {mu,g,SD});
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
