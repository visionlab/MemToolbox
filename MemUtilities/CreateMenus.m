% Create menu on Matlab figure for MemToolbox
function CreateMenus(data, callbackFun)
  % Add menu 
  hMem = uimenu('Label', '<html><strong>&MemToolbox</strong></html>', 'Callback', []);
  uimenu(hMem, 'Label', 'Show all data', 'Callback', ...
    @(hObject, eventdata, h)(callbackFun('all', 1)));
  hLimit = uimenu(hMem, 'Label', 'Limit to:', 'Callback', []);
  
  % Which fields to use?
  if isfield(data, 'errors')
    nSamples = numel(data.errors);
  else
    nSamples = numel(data.changeSize);
  end
  cFields = fieldnames(data);
  for i=1:length(cFields)
    if length(data.(cFields{i})) == nSamples && ...
        ~strcmp(cFields{i}, 'errors') && ~strcmp(cFields{i}, 'afcCorrect') ...
        && ~strcmp(cFields{i}, 'changeSize')
      uniqueVals = unique(data.(cFields{i}));
      for j=1:min([10, length(uniqueVals)])
        uimenu(hLimit, 'Label', ['<html> <font face="Courier">' cFields{i} ...
          '</font>==' num2str(uniqueVals(j)) '</html>'], 'Callback', ...
          @(hObject, eventdata, h)(callbackFun(cFields{i}, uniqueVals(j))));
      end
    end
  end
end
