% SLOTPLUSRESOURCESMODEL returns a structure for the slots+averaging model of
% Zhang & Luck (2008), though it assumes even allocation of the resource to
% the represented objects. The model has two parameters: capacity, which is
% the number of available slots, and bestSD, which is the standard deviation
% of memory for an item when all of the resource is thrown at it.
% model with capacity K and precision sd. Assumes even allocation of the
%
% In addition to data.errors, requires data.n (the set size for each
% trial). The model is not particularly well-formed unless you have tested
% multiple set sizes; with only a single set size you may be better off
% with a model that does not make predictions across set size, like
% StandardMixtureModel().
%
% Uses the capacity and bestSD to fit data across multiple sizes. 
%
function model = SlotPlusResourcesModel()
  model.name = 'Slot plus resouces model';
	model.paramNames = {'capacity', 'bestSD'};
	model.lowerbound = [0 0]; % Lower bounds for the parameters
	model.upperbound = [Inf Inf]; % Upper bounds for the parameters
	model.movestd = [0.1, 0.1];
	model.pdf = @slotpdf;
  model.prior = @(p) (JeffreysPriorForCapacity(p(1)) .* ... % for capacity
                      JeffreysPriorForKappaOfVonMises(deg2k(p(2))));  
	model.start = [2, 0.1;  % g, sd
                 3, 1;  % g, sd
                 4, 10]; % g, sd
  
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

function y = slotpdf(data,capacity,bestSD)
  
  numRepresented = min(capacity, data.n);
  g = 1 - numRepresented ./ data.n;
  sd = bestSD .* sqrt(numRepresented);
  
  y = (1-g).*vonmisespdf(data.errors(:),0,deg2k(sd)) + ...
        (g).*unifpdf(data.errors(:),-180,180);
end
