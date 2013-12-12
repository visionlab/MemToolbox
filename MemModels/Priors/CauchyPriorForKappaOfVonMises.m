% Cauchy prior for the concentration parameter of a von Mises distritbution.
%
% References:
%
%  Wallace, C. S., and Dowe, D. L. (1993). MML estimation of the von Mises
%  concentration parameter. Technical report 93/193, Department of Computer
%  Science, Monash University, Melbourne.
%
function y = CauchyPriorForKappaOfVonMises(K)
  y = 2 ./ (pi + K.^2);
end
