% SPLITDATABYCONDITION Splits a data set into subsets, one per condition
% as specified by a field data.condition. data.condition can be a cell 
% array of strings or a vector. 
%
% e.g.,
%    data.errors =    [10 30 -30 20 -12 80];
%    data.condition = [1  1   1  2   2  2];
%    datasets = SplitDataByCondition(data)
%
% or
%    data.errors =    [10   30   -30  20   -12  80];
%    data.condition = {'a', 'a', 'a', 'b', 'b', 'b'};
%    datasets = SplitDataByCondition(data)
%
function [datasets, conditionOrder] = SplitDataByCondition(data)
  
  % If there is no condition field, return the data struct untouched
  if(~isfield(data, 'condition'))
    warning('The data does not specify conditions.')
    datasets = {data};
    conditionOrder = 1;
    return;
  end

  % Otherwise figure out how many conditions there are
  conditions = unique(data.condition);
  [conditionOrder, tmp, condNumbers] = unique(data.condition);
  nConds = max(condNumbers);
  datasets = cell(1,nConds);

  % For each field, split it by condition and store it
  fields = fieldnames(data);
  for condIndex = 1:nConds
    for fieldIndex = 1:length(fields)
      wholeField = getfield(data,fields{fieldIndex});
      
      % Preserve all rows of fields like .distractors that are M x trials
      % and allow them to also be trials X M
      if size(wholeField, 1) == length(condNumbers)
        datasets{condIndex} = setfield(datasets{condIndex}, fields{fieldIndex}, ...
          wholeField(condNumbers == condIndex, :));
      elseif size(wholeField, 2) == length(condNumbers)
        datasets{condIndex} = setfield(datasets{condIndex}, fields{fieldIndex}, ...
          wholeField(:, condNumbers == condIndex));
      else
        fprintf('Warning: Could not split field "%s"!\n', fields{fieldIndex});
        datasets{condIndex} = setfield(datasets{condIndex}, fields{fieldIndex}, ...
          wholeField);
      end
    end 
  end
end

