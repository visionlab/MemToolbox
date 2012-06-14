function K = sd2k (S)
% SD2K (S)
%   Returns the Von Mises concentration parameter corresponding to 
%   standard deviation S of a wrapped normal distribution.
%
%   Ref: Topics in Circular Statistics, S. R. Jammalamadaka & A. Sengupta
%
%   --> www.paulbays.com

R = exp(-S.^2/2);

K = 1./(R.^3 - 4 * R.^2 + 3 * R);

K(R < 0.85) = -0.4 + 1.39 * R(R < 0.85) + 0.43./(1 - R(R < 0.85));

K(R < 0.53) = 2 * R(R < 0.53) + R(R < 0.53).^3 + (5 * R(R < 0.53).^5)/6;
