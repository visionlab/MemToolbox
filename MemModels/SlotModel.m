% SLOTMODEL returns a structure for a two-component mixture model
% with capacity K and precision sd.

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
