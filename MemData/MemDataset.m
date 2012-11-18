% MEMDATASET Returns data from examples included in MemToolbox
%
%  data = MemDataset(whichData)
%
% whichData should range from 1-10, corresponding to the 10 currently
% included datasets.
%
function data = MemDataset(whichData,varargin)
  if(nargin < 1)
    whichData = 1;
  end
  currentDir = fileparts(mfilename('fullpath'));
  switch whichData
    case 1
      data = load(fullfile(currentDir, 'DataFiles', ...
        '3000+trials_3items_SUBJ#1.mat'));
    case 2
      data = load(fullfile(currentDir, 'DataFiles', ...
        '3000+trials_3items_SUBJ#2.mat'));
    case 3
      data = load(fullfile(currentDir, 'DataFiles', ...
        'swap-data-simulated.mat'));
    case 4
      data = load(fullfile(currentDir, 'DataFiles', ...
        'dataset-multiple-conditions-s1.mat'));
    case 5
      data = load(fullfile(currentDir, 'DataFiles', ...
        'dataset-multiple-conditions-s2.mat'));
    case 6
      data = load(fullfile(currentDir, 'DataFiles', ...
        'dataset-multiple-conditions-s3.mat'));
    case 7
      data = load(fullfile(currentDir, 'DataFiles', ...
        'dataset-multiple-conditions-s4.mat'));  
    case 8
      f = load(fullfile(currentDir, 'DataFiles', ...
        'allFields5SetSizes.mat'));  
      data = f.data;
    case 9
      f = load(fullfile(currentDir, 'DataFiles', ...
        'allFieldsVariablePrecision.mat'));  
      data = f.data;
       
    case 'vandenbergetal2012'
      if(length(varargin) < 2)
        error('You must specify both a dimension, 1 or 2, and a participant.')
      end
      dim = varargin{1};
      s = varargin{2};
      dimensions = {'color', 'orientation'};
      participants{1} = {'cc','clc','ela','hml','jv','kw', ...
        'mbc', 'mt','rjj','ss','stp','wc','wjm'};
      participants{2} = {'AA','ACO','ELA','RGG','TCS','WJM'};
      thisParticipant = participants{dim}{s};
      dataDir = fullfile(currentDir, 'DataFiles', ...
        'vandenbergetal2012_data', dimensions{dim});
      listing = dir(fullfile(dataDir, [thisParticipant '*']));
      data = [];
      for i = 1:length(listing)
        thisFile = load(fullfile(dataDir, listing(i).name));
        for j = 1:4
          data = CombineData(data,getfield(thisFile,['recording' num2str(j)]));
        end
      end
      if(dim == 1)
        data.error = data.error*2;      
      end    
        
    otherwise
      error('Sorry, that''s not one of the available datasets.')
  end
end

