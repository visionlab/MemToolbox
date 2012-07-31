% PERFORMANCE2K returns an estimate of capacity K based on partial report task
% 
%  k = Performance2K(p,n,m) 
%
% gives a subject's proportion correct P in a partial  report task with N 
% objects and M alternatives.
%
function k = Performance2K(p,n,m)
    k = (n - n*m*p) / (1 - m);
end