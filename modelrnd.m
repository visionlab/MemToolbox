% MODELRND Simulates data from a model with some parameters. This is a slightly
% refactored copy of rejectionrnd.m, taking in a model struct as one of its parameters.
% In the future, it will probably be useful to check whether the requested model
% is one of the standard models, and use an efficient generator for those. For example,
% even the optimized rejection sampler is still 10x slower than vonmisesrnd.m for generating
% vonmises random variates. 
%
% Another possibility, one that I think is pretty nice, is that  model structs could 
% optionally include a .efficientGenerator procedure. This method would then check 
% whether the model has an efficient generator, use it, and otherwise use rejection
% sampling from the pdf.
% 
%    Example usage:
%
%    model = StandardMixtureModel();
%    paramsIn = {0, 1};
%    paramsOut = MCMC(modelrnd(model, paramsIn, [1,1000]), model)

function r = modelrnd(model, params, dims)
    
    % if the model has an efficient generator, use it. otherwise use rejection sampling
    if(isfield(model, 'generator'))
        r = model.generator(params, dims);
        return;
    end
    
    b = 10; % each round, generate b times as many samples as total n
    
    % preallocate arrays
    n = prod(dims);
    pass = false(1,n*b);
    samples = [];
    
    num = 1;
    M = model.pdf(0, params{:}) * 2 * 2*pi;
    while num < n
      u = rand(n*b,1);
      curSamples = rand(n*b,1).*2*pi - pi;
      pass = u < (model.pdf(curSamples, params{:})./M);
      sPass = sum(pass);
      samples(num:num+sPass-1) = curSamples(pass);
      num = num + sPass;
    end

    r = reshape(samples(1:n), dims);
end