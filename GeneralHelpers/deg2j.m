%DEG2J Converts from the standard deviation of a wrapped normal distribution
% to Fisher information j of von Mises distribution.
function j = deg2j(deg)
  j = k2j(deg2k(deg));
end
