% MEMDATASET Returns data from examples included in MemToolbox
%
%  data = MemDataset(whichData)
%
% whichData should range from 1-7, corresponding to the 7 currently
% included datasets.
%
function data = MemDataset(whichData)
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
    otherwise
      error('Sorry, that''s not one of the available datasets.')
  end
end

