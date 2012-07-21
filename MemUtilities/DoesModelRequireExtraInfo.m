% Does the model.pdf function for this model require more than just a
% .errors?
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