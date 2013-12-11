% COUNTINRANGES Counts the elements of x that fall within the specified ranges,
% inclusive of the boundaries. It allows you to specify multiple ranges, each
% as a two-item vector:
function y = countInRanges(x,varargin)
  numBounds = length(varargin);
  y = 0;
  for i = 1:numBounds
    lower = varargin{i}(1);
    upper = varargin{i}(2);
    y = y + sum(isInRange(x,lower,upper));
  end
end
