% Converts the parameters of a student's t distribution (degrees of freedom df
% and standard deviation sd) to the corresponding gamma distribution that
% produces it when used as a mixing distribution for a scale mixture of
% normals.
function [shape,scale] = t2gamma(sd,df)
  shape = df./2;
  scale = 1 ./ (df .* sd.^2 ./ 2);
end
