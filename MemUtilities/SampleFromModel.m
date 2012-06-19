% SampleFromModel Simulates data from a model with some parameters. This is a slightly
% refactored copy of rejectionrnd.m, taking in a model struct as one of its parameters.
% In the future, it will probably be useful to check whether the requested model
% is one of the standard models, and use an efficient generator for those. For example,
% even the optimized rejection sampler is still 10x slower than vonmisesrnd.m for generating
% vonmises random variates. 
% 
%  Jordan, if we're going to have a general purpose sampler, maybe it
%  should use MCMC so it doesn't depend on the point at 0 being the
%  highest? Or maybe we should use some heuristics to decide if that
%  condition is likely to hold and only use rejection sampling if so? I put
%  a more general (but 4x slower) sampler using MCMC at the bottom of the
%  file.
%
%  Tim, isn't it a problem that the MCMC sampler gives correlated samples?
%  Also, is there an accepted method for finding the right envelope function? I guess
%  this reduces to finding the mode of the pdf. Would it be crazy to use one of the
%  builtin optimization functions to acheive this?
%
%    Example usage:
%
%    model = StandardMixtureModel();
%    paramsIn = {0, 1};
%    simulatedData = SampleFromModel(model, paramsIn, [1,1000]);
%    paramsOut = MCMC(simulatedData, model);

function r = SampleFromModel(model, params, dims)
  
    if(nargin < 3)
      dims = [1 1];
    end
  
    
    % if the model has an efficient generator, use it. otherwise use rejection sampling
    if(isfield(model, 'generator'))
        r = model.generator(params, dims);
        return;
    end
    
    % If there's no model.pdf, create one using model.logpdf
		%  Jordan: Not sure this will work as-is for some of them;
		%  some of the models I wrote use logpdf but only return a single
		%  value, not one for each datapoint. We'll probably have to change
		%  that to make this work for sampling...
    if ~isfield(model, 'pdf')
      model.pdf = @(varargin)(exp(model.logpdf(varargin{:})));
    end
    
    b = 10; % each round, generate b times as many samples as total n
    
    % preallocate arrays
    n = prod(dims);
    pass = false(1,n*b);
    samples = [];
    
    num = 0;
    M = model.pdf(struct('errors',0), params{:}) * 2 * 360;
    while num < n
      u = rand(n*b,1);
      curSamples = rand(n*b,1).*360 - 180;
      pass = u < (model.pdf(curSamples, params{:})./M);
      sPass = sum(pass);
      samples(num+1:num+sPass) = curSamples(pass);
      num = num + sPass;
    end

    r = reshape(samples(1:n), dims);
end

function r = mcmcParallel(pdf, params, dims)
  burn = 10;
  thin = 2;
  proposals = rand(prod(dims)*thin+burn, 1).*360 - 180;
  pdfVals = pdf(proposals, params{:});
  curLike = pdfVals(1);
  cur = proposals(1);
  for m=1:length(proposals)
      newLike = pdf(proposals(m), params{:});
      if rand < newLike/curLike
          cur = proposals(m);
          curLike = newLike;
      else
          proposals(m) = cur;
      end
  end
  r = reshape(proposals(burn+1:thin:end), dims);
end
