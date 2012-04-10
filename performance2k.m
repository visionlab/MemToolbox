% PERFORMANCE2K(P,N,M) returns an estimate of capacity K based on 
% a subject's proportion correct P in a partial report task with 
% N objects and M alternatives.

function k = performance2k(p,n,m)
    k = (n - n*m*p) / (1 - m);
end