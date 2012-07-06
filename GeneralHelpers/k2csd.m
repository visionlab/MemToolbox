% returns the circular standard deviation of a von Mises distribution with
% concentration parameter k

function sd = k2csd(k)
  sd = sqrt(1 - (besseli(1,k)./besseli(0,k)));
end