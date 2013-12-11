%K2DEG  Returns the standard deviation (in degrees) of a wrapped normal distribution
%  corresponding to a von Mises concentration parameter of K.
function sd = k2deg(k)
  sd = rad2deg(k2sd(k));
end
