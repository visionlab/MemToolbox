% SPLITDATABYFIELD Splits a data set into subsets, one per condition
% as specified by the given field.
%
%  [datasets, conditionOrder] = SplitDataByField(data, field)
%
% e.g.,
%    data.errors =    [10 30 -30 20 -12 80];
%    data.condition = [1  1   1  2   2  2];
%    datasets = SplitDataByField(data, 'condition')
%
% or
%    data.errors =    [10   30   -30  20   -12  80];
%    data.condition = {'a', 'a', 'a', 'b', 'b', 'b'};
%    datasets = SplitDataByField(data, field)
%
function [datasets, conditionOrder] = SplitDataByField(data, field)

  % If the given field doesn't exist, return the data struct untouched
  if(~isfield(data, field))
    warning('The specified field does not exist.')
    datasets = {data};
    conditionOrder = 1;
    return;
  end

  % Otherwise figure out how many conditions there are
  [conditionOrder, tmp, condNumbers] = unique(data.(field));
  nConds = max(condNumbers);
  datasets = cell(1,nConds);

  % For each field, split it by condition and store it
  fields = fieldnames(data);
  for condIndex = 1:nConds
    for fieldIndex = 1:length(fields)
      wholeField = data.(fields{fieldIndex});

      % Preserve all rows of fields like .distractors that are M x trials
      % and allow them to also be trials X M
      if size(wholeField, 1) == length(condNumbers)
        datasets{condIndex}.(fields{fieldIndex}) = ...
          wholeField(condNumbers == condIndex, :);
      elseif size(wholeField, 2) == length(condNumbers)
        datasets{condIndex}.(fields{fieldIndex}) = ...
          wholeField(:, condNumbers == condIndex);
      else
        fprintf('Warning: Could not split field "%s"!\n', fields{fieldIndex});
        datasets{condIndex}.(fields{fieldIndex}) = wholeField;
      end
    end
  end
end

