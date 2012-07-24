% Cumulative distribution function of the von Mises distribution.
function cdf = vonmisescdf (x, mu, k)
  % For large numbers of points, it is faster to just integrate by hand
  % and interpolate
  xvals = linspace(-180,180,5000);
  y = vonmisespdf(xvals, 0, k);
  cdfVals = cumtrapz(xvals, y);
  cdf = qinterp1(xvals, cdfVals, x-mu);
end
