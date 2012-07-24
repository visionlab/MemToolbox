% PlotAsciiHist makes a cute little ascii histogram of error data, like this:
%
%     -pi ___.-'-.___ pi
%
function PlotAsciiHist(data,n)
    % Check input
    if nargin < 2
        n = 21;
    end
   
    % Bin the data
    bins = linspace(-180+(180/(2*n)), 180-(180/(2*n)), n);
    m = hist(data, bins);
    
    % Figure out highest bin
    maxBin = max(m);
    
    % Build the histogram
    symbols = {'_', '.', '-', ''''};
    h = '-180 ';
    for i = 1:n
        symbolToAdd = symbols{1+floor((m(i)/maxBin)*(length(symbols)-1))};
        h = [h, symbolToAdd];
    end
    h = [h, ' +180'];
    
    % Display the histogram
    disp(h);
end

