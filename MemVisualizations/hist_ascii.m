% HIST_ASCII makes a cute little ascii histogram of error data, like this:
%
%     -pi ___.-'-.___ pi
%
function hist_ascii(data,n)

    % check input
    if nargin < 2
        n = 21;
    end
   
    % bin the data
    bins = linspace(-180+(180/(2*n)), 180-(180/(2*n)), n);
    m = hist(data, bins);
    
    % figure out highest bin
    maxBin = max(m);
    
    % build the histogram
    symbols = {'_', '.', '-', ''''};
    h = '-180 ';
    for i = 1:n
        symbolToAdd = symbols{1+floor((m(i)/maxBin)*(length(symbols)-1))};
        h = [h, symbolToAdd];
    end
    h = [h, ' +180'];
    
    % display the histogram
    disp(h);
end

