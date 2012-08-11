% SLOTPLUSRESOURCESMODEL returns a structure for a two-component mixture 
% model with capacity K and precision sd.
%
% In addition to data.errors, requires data.n (the set size for each trial)
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
	model.movestd = [1, 0.1];
	model.pdf = @slotpdf;
  model.prior = @(p) (JeffreysPriorForCapacity(p(1)) .* ... % for capacity
                      JeffreysPriorForKappaOfVonMises(deg2k(p(2))));  
	model.start = [2, 10;  % g, sd
                 3, 15;  % g, sd
                 4, 20]; % g, sd
end

function y = slotpdf(data,capacity,sd)
  g = (1 - max(0,min(1,capacity./data.n(:))));
  
  % if capacity > data.n, sd is better by sqrt of the difference
  curSD = min(sd./sqrt(capacity./data.n(:)), sd);
  
  y = (1-g).*vonmisespdf(data.errors(:),0,deg2k(curSD)) + ...
        (g).*unifpdf(data.errors(:),-180,180);
end
