% GENERATEDISPLAYS can be called to generate colors to present in a working memory task.
%
%  displays = GenerateDisplays(numTrials, itemsPerTrial, mode)
%
% numTrials must be an integer. itemsPerTrial can be either an integer or
% a vector the 1 x numTrials in size, specifying the number of items on
% each trial separately.
%
% 'mode' chooses the method by which the colors are selected.
% Currently the only supported mode is drawing randomly from a circular
% uniform.
%    mode = 1: returns information needed to do continuous report
%    mode = 2: returns information needed to do 2AFC
%
function displays = GenerateDisplays(trials, itemsPerTrial, mode)

  % Default mode is 1 (iid from circular)
	if nargin < 3
	  mode = 1;
  end

	% iid from ciruclar uniform
	if mode == 1 || mode == 2
    % Generate random items
	  displays.items = unifrnd(0, 360, max(itemsPerTrial), trials);
    for i=1:max(itemsPerTrial)
      displays.items(i,i>itemsPerTrial) = NaN;
    end
    displays.whichIsTestItem = ceil(rand(1, trials).*itemsPerTrial);

    % Extract useful information for models
    displays = AddUsefulInfo(displays);

    % If 2AFC, choose a change size for each tested item also
    if mode==2
      displays.changeSize = unifrnd(-180, 180, 1, trials);
    end
  else
	  warning('No such mode, defaulting to iid vm.')
	  displays = GenerateDisplays(trials,itemsPerTrial,1);
  end
end

function displays = AddUsefulInfo(displays)
  % Add in the distance of the distractors to the target for each trial
  allItems = 1:size(displays.items,1);
  for i=1:size(displays.items,2)
    whichTest = displays.whichIsTestItem(i);
    displays.distractors(:,i) = circdist(displays.items(whichTest,i), ...
      displays.items(allItems~=whichTest, i));
  end

  % Add set size for each trial
  displays.n = sum(~isnan(displays.items));
end
