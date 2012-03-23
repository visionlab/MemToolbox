function displays = generateDisplays(trials, itemsPerTrial, mode)
    
    % default mode is 0 (iid from circular)	
	if nargin < 3
	   mode = 0; 
    end
	
	% iid from ciruclar uniform
	if mode == 0
	    displays = unifrnd(-pi, pi, trials, itemsPerTrial);
	end

end