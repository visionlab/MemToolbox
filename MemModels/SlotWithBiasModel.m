% SLOTMODEL returns a structure for a two-component mixture model with 
% capacity K and precision sd.
%
% Parameter explanation: 
%
% Capacity is the maximum number of independent representations. 
% If the set size is greater than capacity some guesses will occur.  
% For example, if participants can store 3 items but have to remember 6,
% participants will guess 50% of the time. 
%
% Precision is the uncertainty of stored representations. 
% Precision is constant across set size
% 
% SLOTMODEL uses capacity and precision to fit data across multiple set sizes. 
%
% TO DO
%   Make a version that fits at one set size and generates to a novel set size

function model = SlotWithBiasModel()
  model.name = 'Slot model with bias';
	model.paramNames = {'mu', 'capacity', 'sd'};
	model.lowerbound = [-180 0 0]; % Lower bounds for the parameters
	model.upperbound = [180 Inf Inf]; % Upper bounds for the parameters
	model.movestd = [1, 1, 0.1];
	model.pdf = @slotpdf;
	model.start = [-10, 1, 4;   % mu, capacity, sd
                   0, 4, 15;  %
                  10, 10,40]; %
  
  model.prior = @(p) (ImproperUniform(p(1)) * ... % for mu
                      ImproperUniform(p(2)) * ... % for capacity
                      JeffreysPriorForKappaOfVonMises(deg2k(p(3))));
                      
  model.priorForMC = @(p) (vonmisespdf(p(1),0,33) * ...
                           lognpdf(p(2),2,1) * ... % for capacity
                           lognpdf(deg2k(p(3)),2,0.5));
end

function y = slotpdf(data,mu,capacity,sd)
  g = (1 - max(0,min(1,capacity./data.n)));

  y = (1-g).*vonmisespdf(data.errors(:),mu,deg2k(sd)) + ...
        (g).*unifpdf(data.errors(:),-180,180);
   
end
