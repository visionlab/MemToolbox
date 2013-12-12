% SPLITDATABYCONDITION Splits a data set into subsets, one per condition
% as specified by a field data.condition. data.condition can be a cell
% array of strings or a vector.
%
%  [datasets, conditionOrder] = SplitDataByCondition(data)
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
  [datasets, conditionOrder] = SplitDataByField(data,'condition');
