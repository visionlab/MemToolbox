% DOESMODELREQUIREEXTRAINFO checks if a model pdf requires more than data.errors
%
% r = DoesModelRequireExtraInfo(model)
%
% This function is a helper function used by functions that attempt to
% evaluate a model's pdf at specific values independent of the specified
% data. It check if a model.pdf function requires more than just specifying
% the data.errors to evaluate at (for example, the SwapModel also requires
% you to include data.distractors, and thus will return true).
%
function r = DoesModelRequireExtraInfo(model)
  r = false;
  try
    data.errors = [-180 0 180];
    params = num2cell(model.start(1,:));
    model.pdf(data, params{:});
  catch
    r = true;
  end
end
