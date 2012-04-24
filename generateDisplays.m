function displays = generateDisplays(trials, itemsPerTrial, mode)
    
  % default mode is 0 (iid from circular)	
	if nargin < 3
	  mode = 1; 
  end
	
	% iid from ciruclar uniform
	if mode == 1
	  displays = unifrnd(-pi, pi, trials, itemsPerTrial);
	else
	  warning('No such mode, defaulting to iid vm.')
	  displays = generateDisplays(trials,itemsPerTrial,0);
  end

end