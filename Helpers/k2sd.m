function S = k2sd (K)
% K2SD (K)
%   Returns the standard deviation of a wrapped normal distribution
%   corresponding to a Von Mises concentration parameter of K.
%
%   Ref: Topics in Circular Statistics, S. R. Jammalamadaka & A. Sengupta
%
%   --> www.paulbays.com

if K==0
    S = Inf;
elseif isinf(K)
    S = 0;
else
    S = sqrt(-2*log(besseli(1,K)./besseli(0,K)));
end
