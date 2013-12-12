% SAMPLEFROMMODEL simulates data from a model with some parameters.
%
%  samp = SampleFromModel(model, params, dims, displayInfo)
%
%  Example usage:
%
%    model = StandardMixtureModel();
%    paramsIn = {0, 1};
%    simulatedData = SampleFromModel(model, paramsIn, [1,1000]);
%    paramsOut = MCMC(simulatedData, model);
%
%  If the model you pass in requires extra information for its pdf, for
%  example SwapModel (which requires .distractors), then you must pass in
%  display information as the 4th parameter (e.g., a data struct that has
%  .distractors), and the dimensions you request back (third parameter,
%  dims) must match the number of displays you provide.
%
% e.g.,
%    model = SwapModel();
%    displays = GenerateDisplays(100, 3); % 100 trials, 3 items/trial
%    paramsIn = {0, 0.1, 1};
%    simulatedData = SampleFromModel(model, paramsIn, [100,1], displays);
%
function samp = SampleFromModel(model, params, dims, displayInfo)
  % Default to 1 sample
  if(nargin < 3)
    dims = [1 1];
  end

  % Make sure params is a cell array of parameters
  if ~iscell(params)
    params = num2cell(params);
  end

  % Check if the model needs extra information about the displays
  r = DoesModelRequireExtraInfo(model);
  if nargin < 4
    displayInfo = [];
    if r
      error(['You passed a model that requires extra information to make ' ...
        'a pdf; for example, maybe the set size (data.n) or the distractor ' ...
        'locations (data.distractors). Please pass the data struct describing ' ...
        'the displays you wish to sample data for as the fourth parameter.']);
    end
  end

  if r
    if isfield(displayInfo, 'errors')
      sz = size(displayInfo.errors);
    elseif isfield(displayInfo, 'distractors')
      sz = [1 size(displayInfo.distractors,2)];
    elseif isfield(displayInfo, 'n')
      sz = size(displayInfo.n);
    elseif isfield(displayInfo, 'afcCorrect')
      sz = size(displayInfo.afcCorrect);
    end
    if all(prod(dims) ~= prod(sz))
      error(['You passed a model that requires extra information to make ' ...
      'a pdf. When you pass such a model, dims needs to match the number of ' ...
      'displays you provide in the fourth parameter.']);
    end
  end

  % If the model has an efficient generator, use it. otherwise use rejection sampling
  if(isfield(model, 'generator'))
    samp = model.generator(params, dims, displayInfo);
    return
  end

  % Get CDF
  if ~r
    interpVals = linspace(-180, 180, 1000);

    % Just generate enough samples to fill dims
    data.errors = interpVals;
    y = model.pdf(data, params{:});
    cdfVals = cumtrapz(interpVals, y);
    u = rand(1,prod(dims));
    [newCDF, ind] = unique(cdfVals);
    samples = interp1(cdfVals(ind), interpVals(ind), u, 'pchip');
    samp = reshape(samples, dims);
  else
    % Make dims() samples for each display
    interpVals = linspace(-180, 180, 100);
    for i=1:length(interpVals)
      displayInfo.errors = repmat(interpVals(i), sz);
      y(i,:) = model.pdf(displayInfo, params{:});
    end
    cdfVals = cumtrapz(interpVals, y);
    u = rand(1,size(cdfVals,2));
    for i=1:size(cdfVals,2)
      [newCDF, ind] = unique(cdfVals(:,i));
      samples(i) = interp1(cdfVals(ind,i), interpVals(ind), u(i), 'pchip');
    end
    samp = reshape(samples, dims);
  end
end


