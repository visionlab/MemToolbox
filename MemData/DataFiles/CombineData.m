% COMBINEDATA Combines two data structures
%
function data = CombineData(data1,data2); 
  if(isempty(data2))
    data = data1;
    return
  elseif(isempty(data1))
    data = data2;
    return
  end
  data = data1; 
  fields = fieldnames(data);
  for fieldIndex = 1:length(fields)
    data = setfield(data,fields{fieldIndex},...
      [getfield(data,fields{fieldIndex}), getfield(data2,fields{fieldIndex})]);
  end
end