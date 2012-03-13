% INFINITESCALEMIXTUREMODEL(BASE,MIXING) returns a structure for an infinite 
% scale mixture model for a particular BASE and MIXING distribution.
%
% Todo:
%    1. Support arbitrary combinations of {wrapped normal, von Mises} bases and
%       {gamma, truncated normal, log normal, dirac delta} mixing, and maybe even
%       allow the mixing distribution to be over kappa, sd, or precision.

function model = InfiniteScaleMixtureModel(baseDistribution, mixingDistribution)

    % is base = wrapped normal and mixing = gamma, use student's t
    if(strcmp(baseDistribution, 'wrappednormal') && strcmp(mixingDistribution, 'gamma'))
        model = StudentsTModel();
        return;
    else
        error('The requested combination of base and mixing distributions is not supported.')
    end
end