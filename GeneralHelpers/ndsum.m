% Multidimensional summation
function x = ndsum(x, dim)
  newSize = size(x);
  newSize(dim) = [];

  for i=1:length(dim)
    x = sum(x, dim(i));
  end
  x = reshape(x,[newSize 1 1]);
end
