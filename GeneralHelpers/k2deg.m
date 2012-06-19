%   k2deg (k)
%   A wrapper around  k2sd and rad2deg. 
%   Returns the standard deviation (in degrees) of a wrapped normal distribution
%   corresponding to a Von Mises concentration parameter of K.

function sd = k2deg(k)
  sd = rad2deg(k2sd(k));
end