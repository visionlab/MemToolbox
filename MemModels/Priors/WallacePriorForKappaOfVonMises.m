% Wallace prior for the concentration parameter of a von Mises distritbution.
%
% References:
%
%  Wallace, C. S., and Dowe, D. L. (1993). MML estimation of the von Mises
%  concentration parameter. Technical report 93/193, Department of Computer
%  Science, Monash University, Melbourne.
%
function y = WallacePriorForKappaOfVonMises(K)
  y = K ./ (1+(K.^2)).^(3/2);
end
