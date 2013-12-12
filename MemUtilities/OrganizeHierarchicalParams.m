% ORGANIZEHIERARCHICALPARAMS convert parameters from Hierarchical() model
% to a struct that separates out the means, standard deviations and
% individual subject fits.
%
%    fit = OrganizeHierarchicalParams(model, params)
%
function fit = OrganizeHierarchicalParams(model, params)
  fit.paramsSubs = reshape(params', model.originalNParams, [])';
  fit.paramsStd = fit.paramsSubs(1,:);
  fit.paramsMean = fit.paramsSubs(2,:);
  fit.paramsSubs(1:2,:)=[];
end
