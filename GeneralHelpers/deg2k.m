%  deg2k (deg)
%  A wrapper around deg2rad and sd2k. 
%  Returns the concentration parameter of a von Mises distribution corresponding
%  to the standard deviation (in degrees) of a wrapped normal distribution

function k = deg2k(sd)
  k = sd2k(deg2rad(sd));
end