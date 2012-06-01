% a wrapper around  k2sd and rad2deg
function sd = k2deg(k)
	sd = rad2deg(k2sd(k));
end