% Converts the parameters of a gamma distribution to the corresponding
% student's t distribution that arises from using that gamma as the mixing
% distribution in a scale mixture of normals.
function [sd,df] = gamma2t(shape,scale)
  df = shape * 2;
  sd = sqrt(2*(1./scale)./df);
end
