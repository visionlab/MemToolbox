function y = JeffreysPriorForProportion(p)
  y = p.^-0.5 .* (1-p).^-0.5;
end
