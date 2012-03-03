% returns a palatable colormap, courtesy of colourlovers.com.
function map = palettablecolormap(startcolor, endcolor, n)
	
	if nargin < 1
		switch fix(5*rand)
			case 0,  
				startcolor = [255 255 255]; 
				endcolor = [11,72,107];  % adrift in dreams
			case 1,    
				startcolor = [255 255 255]; 
				endcolor = [46,64,81];   % bloo
			case 2,    
				startcolor = [255 255 255]; 
				endcolor = [128,15,37];  % love like a man
			case 3,  
				startcolor = [255 255 255];   
				endcolor = [107,155,7];  % elle etait belle
			otherwise, 
				startcolor = [255 255 255];
				endcolor = [66,9,67];    % black tulip
		end
	end	
	
	if nargin < 2
		n = 100;
	end
	
	map = [linspace(startcolor(1)/255, endcolor(1)/255, n);
				 linspace(startcolor(2)/255, endcolor(2)/255, n);
				 linspace(startcolor(3)/255, endcolor(3)/255, n)]';