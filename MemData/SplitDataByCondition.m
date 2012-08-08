% SPLITDATABYCONDITION Splits a data set into subsets, one per condition, as
% specified by a field data.condition.
%
% data = MemDataset(4);
%
function [datasets, conditionOrder] = SplitDataByCondition(data)
  
  % if there is no condition field, return the data struct untouched
  if(~isfield(data, 'condition'))
    warning('The data does not specify conditions.')
    datasets = {data};
    conditionOrder = 1;
    return;
  end

  % otherwise figure out how many conditions there are
  conditions = unique(data.condition);
  datasets = cell(1,length(conditions));

  % for each field, split it by condition and store it
  fields = fieldnames(data);
  for condIndex = 1:length(conditions)
    cond = conditions(condIndex);
    for fieldIndex = 1:length(fields)
      wholeField = getfield(data,fields{fieldIndex});
      datasets{condIndex} = setfield(datasets{cond}, fields{fieldIndex}, ...
        wholeField(find(data.condition == cond)));
    end 
  end
end

