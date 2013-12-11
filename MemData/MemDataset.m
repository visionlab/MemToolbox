% MEMDATASET Returns data from examples included in MemToolbox
%
%  data = MemDataset(whichData)
%
% whichData should take a value from 1-9 or the string 'vandenbergetal2012',
% each of which corresponds to one of the datasets available in the toolbox.
%
% Datasets 1 and 2 are from an experiment reported in the supplement of
% Fougnie et al. (2012). Each dataset is a participant performing 3000+ trials
% of a continuous report color working memory task.
%
% Dataset 3 is simulated from SwapModel.
%
% Datasets 4, 5, 6, and 7 are each simulated from StandardMixtureModel.
%
% Dataset 8 is simulated from SwapModel and contains not only the errors made
% on the task but also the colors of the target and distractors.
%
% Dataset 9 is simulared from VariablePrecisionModel.
%
% Dataset 10 is simulated from SlotsPlusAveragingModel
%
% Dataset 'vandenbergetal2012' is data from van den Berg et al. (2012). When
% chosen, requires two additional parameters. The first is a string, either
% 'color' or 'orientation', and determines the task: remembering a color or
% an orientation. The second is a participant. For color, the available
% participants are 'cc','clc','ela','hml','jv','kw', 'mbc', 'mt','rjj','ss',
% 'stp','wc', and 'wjm'. For orientation, the available participants are
% 'AA','ACO','ELA','RGG','TCS', and 'WJM'.
%
% References
%
% Fougnie, D. F., Suchow, J. W., & Alvarez, G. A. (2012). Variability in the
% precision of visual working memory. Nature Communications, 1129.
%
% van den Berg, R., Shin, H., Chou, W-C., George, R., & Ma, W. J. (2012).
% Variability in encoding precision accounts for visual short-term memory
% limitations. Proceedings of the National Academy of Sciences,
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
    case 10
      f = load(fullfile(currentDir, 'DataFiles', ...
        'multipleSetSizesSlotAverage.mat'));
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
          data = CombineData(data, thisFile.(['recording' num2str(j)]));
        end
      end
      if(dim == 1)
        data.error = data.error*2;
      end

    otherwise
      error('Sorry, that''s not one of the available datasets.')
  end
end

