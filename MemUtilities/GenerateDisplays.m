% GENERATE DISPLAYS can be called to generate the color items presented in
% a working memory task.  
%
% Mode is called to select the mode in which the colors are selected.
% Currently the only supported mode is drawing randomly from a circular uniform 

function displays = GenerateDisplays(trials, itemsPerTrial, mode)
    
  % default mode is 0 (iid from circular)	
	if nargin < 3
	  mode = 1; 
  end
	
	% iid from ciruclar uniform
	if mode == 1
    % Generate random items
	  displays.items = unifrnd(0, 360, itemsPerTrial, trials);
    displays.whichIsTestItem = ceil(rand(1,trials)*itemsPerTrial);
    
    % Extract useful information for models
    displays = AddUsefulInfo(displays);
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
    displays.distractors(:,i) = distance(displays.items(whichTest,i), ...
      displays.items(allItems~=whichTest, i));
  end
  
  % Add set size for each trial
  displays.n = repmat(size(displays.items,1), [1 size(displays.items,2)]);
end