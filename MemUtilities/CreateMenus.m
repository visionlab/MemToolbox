% Create menu on Matlab figure for MemToolbox
function CreateMenus(data, callbackFun)
  % Don't add menus if they already exist
  if strcmp(get(gcf, 'UserData'), 'HasMenus')
    return;
  end

  % Add menus
  hMem = uimenu('Label', '<html><strong>&MemToolbox</strong></html>', 'Callback', []);
  uimenu(hMem, 'Label', 'Show all data', 'Callback', ...
    @(hObject, eventdata, h)(callbackFun('all', 1)));
  hLimit = uimenu(hMem, 'Label', 'Limit to:', 'Callback', []);

  % Mark that this figure has them
  set(gcf, 'UserData', 'HasMenus');

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
        && ~strcmp(cFields{i}, 'changeSize') && ~strcmp(cFields{i}, 'distractors') ...
        && ~strcmp(cFields{i}, 'items')
      uniqueVals = unique(data.(cFields{i}));
      if length(uniqueVals) < 10
        for j=1:length(uniqueVals)
          val = uniqueVals(j);
          if iscell(val)
            val = sprintf('%s', val{1});
          elseif isnumeric(val)
            val = num2str(val);
          end
          uimenu(hLimit, 'Label', ['<html> <font face="Courier">' cFields{i} ...
            '</font>==' val '</html>'], 'Callback', ...
            @(hObject, eventdata, h)(callbackFun(cFields{i}, uniqueVals(j))));
        end
      end
    end
  end
end
