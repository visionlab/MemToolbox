% SLOTPLUSRESOURCESMODEL returns a structure for a two-component mixture 
% model with capacity K and precision sd.
%
% In addition to data.errors, requires data.n (the set size for each
% trial). The model is not particularly well-formed unless you have tested
% multiple set sizes; with only a single set size you may be better off
% with a model that does not make predictions across set size, like
% StandardMixtureModel().
%
% Parameter explanation: 
%
% Capacity is the maximum number of independent representations. 
% If the set size is greater than capacity some guesses will occur. 
% For example, if participants can store 3 items but have to remember 6, 
% participants will guess 50% of the time. 
%
% Precision is the maximum uncertainty. When set size is less than the
% upper limit on storage, precision can be improved by averaging (Shaw, 1980) 
% e.g., by pooling resources to an item. 
%
% Uses the capacity and precision to fit data across multiple sizes. 
%
function model = SlotPlusResourcesModel()
  model.name = 'Slot plus resouces model';
	model.paramNames = {'capacity', 'sd'};
	model.lowerbound = [0 0]; % Lower bounds for the parameters
	model.upperbound = [Inf Inf]; % Upper bounds for the parameters
	model.movestd = [0.1, 0.1];
	model.pdf = @slotpdf;
  model.prior = @(p) (JeffreysPriorForCapacity(p(1)) .* ... % for capacity
                      JeffreysPriorForKappaOfVonMises(deg2k(p(2))));  
	model.start = [2, 10;  % g, sd
                 3, 15;  % g, sd
                 4, 20]; % g, sd
  
  % Use our custom modelPlot to make a plot of errors separately for each
  % set size
  model.modelPlot = @model_plot;
  function figHand = model_plot(data, params, varargin)
    figHand = figure();
    if isstruct(params) && isfield(params, 'vals')
      params = MCMCSummarize(params, 'maxPosterior');
    end
    [datasets, setSizes] = SplitDataByField(data,'n');
    m = StandardMixtureModel();
    for i=1:length(setSizes)
      subplot(1, length(setSizes), i);
      g = (1 - max(0,min(1,params(1)/setSizes(i))));
      curSD = min(params(2)./sqrt(params(1)./setSizes(i)), params(2));
      PlotModelFit(m, [g curSD], datasets{i}, 'NewFigure', false, ...
        'ShowNumbers', true, 'ShowAxisLabels', false);
      if i==1
        ylabel('Probability', 'FontSize', 14);
      end
      title(sprintf('Set size %d', setSizes(i)), 'FontSize', 14);
    end
  end              
end

function y = slotpdf(data,capacity,sd)
  g = (1 - max(0,min(1,capacity./data.n(:))));
  
  % if capacity > data.n, sd is better by sqrt of the difference
  curSD = min(sd./sqrt(capacity./data.n(:)), sd);
  
  y = (1-g).*vonmisespdf(data.errors(:),0,deg2k(curSD)) + ...
        (g).*unifpdf(data.errors(:),-180,180);
end
