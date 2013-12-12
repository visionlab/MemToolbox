function y = HaldanePriorForProportion(p)
  y = p.^-1 * (1-p).^-1;
end
