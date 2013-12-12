% x can be either log sd or log variance
function y = JeffreysPriorForGaussianLogSD(x)
  y = 1./(x^2);
end
