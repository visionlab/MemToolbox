% Returns a matrix of palettable colors from the most loved at colourlovers.com.
function colors = palettablecolors(n)
    if nargin < 1
        n = 1;
    end

    allColors = [233,127,2;   % party confetti
                 189,21,80;   % sugar hearts you
                  73,10,61;   % sugar cocktail
                 11,72,107;   % adrift in dreams
								138,155,15;   % happy balloon
									 3,54,73;]; % acqua profonda

	colors = allColors(1 + mod(0:n-1, length(allColors)),:)./255;
end
