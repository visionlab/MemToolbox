% MEMDATASET Returns data from examples included in MemToolbox
%
%  data = MemDataset(whichData)
%
% whichData should range from 1-3, corresponding to the 3 currently
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
    otherwise
      error('Sorry, that''s not one of the available datasets.')
  end
end

