%DEG2K A wrapper around deg2rad and sd2k that returns the concentration parameter
%  of a von Mises distribution that corresponds to the standard deviation,
%  in degress, of a wrapped normal distribution.
function k = deg2k(sd)
  k = sd2k(deg2rad(sd));
end
