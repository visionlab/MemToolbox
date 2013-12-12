% GETDATABYFIELD Gets all elements of data struct where field==value
%
%    data = GetDataByField(data, field, value)
%
% e.g., if
%   data =
%      errors: [1x500 double]
%           n: [1x500 double]
%        cond: {1x500 cell}
%
%  with .n = [3 3 3 3 ... 4 4 4 4 ...] and .cond = {'a', 'b', 'a', 'b'...}
%  then:
%
%    data = GetDataByField(data, 'n', 3)
%
%    data =
%      errors: [1x250 double]
%           n: [1x250 double]
%        cond: {1x250 cell}
%
%  and:
%
%    data = GetDataByField(data, 'cond', 'a')
%
%    data =
%      errors: [1x250 double]
%           n: [1x250 double]
%        cond: {1x250 cell}
%
function data = GetDataByField(data, field, value)

  % If the given field doesn't exist, return the data struct untouched
  if(~isfield(data, field))
    warning('The specified field does not exist.')
    return;
  end

  curField = data.(field);
  if iscell(curField)
    getWhich = cellfun(@(x)(isequal(x, value)), curField);
  else
    getWhich = (curField == value);
  end
  if sum(getWhich) == 0
    warning('No elements of that field have that value.')
    return;
  end

  % For each field, split it by condition and store it
  fields = fieldnames(data);
  for fieldIndex = 1:length(fields)
    wholeField = data.(fields{fieldIndex});

    % Preserve all rows of fields like .distractors that are M x trials
    % and allow them to also be trials X M
    if size(wholeField, 1) == length(getWhich)
      data.(fields{fieldIndex}) = wholeField(getWhich, :);
    elseif size(wholeField, 2) == length(getWhich)
      data.(fields{fieldIndex}) = wholeField(:, getWhich);
    else
      fprintf('Warning: Could not remove relevant parts from field "%s"!\n', fields{fieldIndex});
    end
  end
end


