% pth quantile of the values in x
function y = quantile(x,p,dim)
  if nargin < 3
      y = prctile(x,100.*p);
  else
      y = prctile(x,100.*p,dim);
  end
end
