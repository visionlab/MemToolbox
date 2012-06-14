% A wrapper around  sd2k and deg2rad
function k = deg2k(sd)
  k = sd2k(deg2rad(sd));
end