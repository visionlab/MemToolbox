% RESAMPLE Resamples a data set. You can optionally specify a parameter n that
% will detemine how many trials are included in the sample.
function sample = Resample(data, n)

  fields = fieldnames(data);

  % find the biggest dimension across all fields
  len = zeros(size(fields));
  for i = 1:length(fields)
    len(i) = length(data.(fields{i}));
  end
  maxLen = max(len);

  % determine how many points to include in the sample, defaulting to all
  if(nargin < 2)
    n = maxLen;
  end

  % create a random ordering for resampling
  order = randi(maxLen, 1, n);

  % resample fields that match the max length, otherwise leave them alone
  sample = data;
  for i = 1:length(fields)
    thisField = sample.(fields{i});
    if(size(thisField,1) == maxLen)
      sample.(fields{i}) = thisField(order,:);
    elseif(size(thisField,2) == maxLen)
      sample.(fields{i}) = thisField(:,order);
    else
      sample.(fields{i}) = thisField;
    end
  end
end
