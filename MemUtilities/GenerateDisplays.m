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