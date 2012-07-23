% SampleFromModel Simulates data from a model with some parameters. 
%
% NOTE: This requires the model pdf to peak approximately near 0, or else it
% violates the assumption of the rejection sampler.
%
%    Example usage:
%
%    model = StandardMixtureModel();
%    paramsIn = {0, 1};
%    simulatedData = SampleFromModel(model, paramsIn, [1,1000]);
%    paramsOut = MCMC(simulatedData, model);
%
function samp = SampleFromModel(model, params, dims, displayInfo)
  if(nargin < 3)
    dims = [1 1];
  end
  
  % if the model has an efficient generator, use it. otherwise use rejection sampling
  if(isfield(model, 'generator'))
    samp = model.generator(params, dims);
    return;
  end
  
  % Check if the model needs extra information about the displays
  r = DoesModelRequireExtraInfo(model);
  if nargin < 4 && r
    error(['You passed a model that requires extra information to make ' ... 
      'a pdf; for example, maybe the set size (data.n) or the distractor ' ... 
      'locations (data.distractors). Please pass the data struct describing ' ...
      'the displays to sample data for as the fourth parameter.']);
  end
  model = GetModelPdfForPlot(model);
  
  % Rejection sampling
  b = 10; % Each round, generate b times as many samples as total n
  
  % Preallocate arrays
  n = prod(dims);
  pass = false(1,n*b);
  samples = [];
  
  num = 0;
  M = model.pdfForPlot(0, displayInfo, params{:}) * 2 * 360;
  while num < n
    u = rand(n*b,1);
    curSamples = rand(n*b,1).*360 - 180;
    pass = u < (model.pdfForPlot(curSamples, displayInfo, params{:})./M);
    sPass = sum(pass);
    samples(num+1:num+sPass) = curSamples(pass);
    num = num + sPass;
  % If the model has an efficient generator, use it. otherwise use rejection sampling
  if(isfield(model, 'generator'))
    if r
      samp = model.generator(params, dims, displayInfo);
    else 
      samp = model.generator(params, dims);
      return;
    end
  end
  
  samp = reshape(samples(1:n), dims);
end

