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
	  displays = unifrnd(-180, 180, trials, itemsPerTrial);
	else
	  warning('No such mode, defaulting to iid vm.')
	  displays = GenerateDisplays(trials,itemsPerTrial,1);
  end

end