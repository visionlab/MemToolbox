%K2J Converts the concentration parameter k of a von Mises distribution to
% Fisher information j.
function j = k2j(k)
  j = k .* (besseli(1,k)./besseli(0,k));
end
