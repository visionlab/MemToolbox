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

function model = SlotModel()
  model.name = 'Slot model';
	model.paramNames = {'capacity', 'sd'};
	model.lowerbound = [0 0]; % Lower bounds for the parameters
	model.upperbound = [Inf Inf]; % Upper bounds for the parameters
	model.movestd = [1, 0.1];
	model.pdf = @slotpdf;
	model.start = [2, 10;  % g, sd
                 3, 15;  % g, sd
                 4, 20]; % g, sd
end

function y = slotpdf(data,capacity,sd)
  g = (1 - max(0,min(1,capacity./data.n)));

  y = (1-g).*vonmisespdf(data.errors(:),0,deg2k(sd)) + ...
        (g).*unifpdf(data.errors(:),-180,180);
   
end
