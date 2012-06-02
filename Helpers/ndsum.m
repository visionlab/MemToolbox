function x = ndsum(x,dim)
  sz = size(x);
  for i=1:length(dim)
    x = sum(x, dim(i));
  end
  sz(dim) = [];
  x = reshape(x,[sz 1 1]);
end
