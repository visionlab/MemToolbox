% PERFORMANCE2K returns an estimate of capacity K based on partial report task
%
%  k = Performance2K(p,n,m)
%
% Given a subject's proportion correct p in a partial report task with n
% objects and m alternatives, returns k, the number of remembered objects.
%
function k = Performance2K(p,n,m)
    k = n * (p - 1/m)/(1 - 1/m);
end
