% Computes ciruclar distance in degrees
function r =  distance(x,y)
  x = deg2rad(x);
  y = deg2rad(y);
  r = angle(exp(1i*x)./exp(1i*y));
  r = rad2deg(r);
end