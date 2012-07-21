% SampleFromModel - Simulates data from a model with some parameters. 
%
%    Example usage:
%
%    model = StandardMixtureModel();
%    paramsIn = {0, 1};
%    simulatedData = SampleFromModel(model, paramsIn, [1,1000]);
%    paramsOut = MCMC(simulatedData, model);
%
function samp = SampleFromModelNew(model, params, dims, displayInfo)
  % Default to 1 sample
  if(nargin < 3)
    dims = [1 1];
  end
  
  % If the model has an efficient generator, use it. otherwise use rejection sampling
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
      'the displays you wish to sample data for as the fourth parameter.']);
  end

  % Get CDF
  interpVals = linspace(-180, 180, 1000);
  if ~r
      data.errors = interpVals;
      y = model.pdf(data, params{:});
      cdfVals = cumtrapz(interpVals, y);
  else
    sz = size(displayInfo.errors);
    for i=1:length(interpVals)
      displayInfo.errors = repmat(interpVals(i), sz);
      y(i,:) = model.pdf(displayInfo, params{:});
    end
    cdfVals = cumtrapz(interpVals, y);
    cdfVals = mean(cdfVals,2)';
  end
  
  % Interpolate the inverse of the cdf to get samples (Inverse Transform
  % Sampling)
  u = rand(1,prod(dims));
  samples = interp1(cdfVals, interpVals, u);
  samp = reshape(samples, dims);
end
