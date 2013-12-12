%K2CSD Returns the circular standard deviation of a von Mises distribution with
% concentration parameter k. This differs from K2SD by a factor of 1/sqrt(2).
function sd = k2csd(k)
  sd = sqrt(1 - (besseli(1,k)./besseli(0,k)));
end
