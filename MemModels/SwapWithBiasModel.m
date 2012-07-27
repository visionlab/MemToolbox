% SWAPWITHBIASMODEL returns a structure for a three-component model
% with guesses and swaps and a bias term. Based on Bays, Catalao, & Husain 
% (2009) model. This is an extension of the StandardMixtureModel that allows 
% for observers' misreporting incorrect items.
%
% In addition to data.errors, the data struct should include:
%   data.distractors, Row 1: distance of distractor 1 from target
%   ...
%   data.distractors, Row N: distance of distractor N from target
%
% This model includes a custom .modelPlot function that is called by
% MemFit(). This function produces a plot of the distance of observers'
% reports from the distractors, rather than from the target, as in Bays,
% Catalao & Husain (2009), Figure 2B.
%
function model = SwapWithBiasModel()
  model.name = 'Swap model with bias';
	model.paramNames = {'mu', 'g', 'B', 'sd'};
	model.lowerbound = [-180 0 0 0]; % Lower bounds for the parameters
	model.upperbound = [180 1 1 Inf]; % Upper bounds for the parameters
	model.movestd = [1, 0.02, 0.02, 0.1];
  model.pdf = @SwapModelPDF;
  model.modelPlot = @model_plot;
  model.generator = @SwapModelGenerator;
	model.start = [10, 0.2, 0.1, 10;  % g, B, sd
    -10, 0.4, 0.1, 15;  % g, B, sd
    0, 0.1, 0.5, 20]; % g, B, sd
  model.prior = @(p) JeffreysPriorForKappaOfVonMises(deg2k(p(4))); % sd
  
  model.priorForMC = @(p) (betapdf(p(2),1.25,2.5) * ... % for g
    betapdf(p(3),1.25,2.5) * ... % for B
    lognpdf(deg2k(p(4)),2,0.5)); % for sd
  
  % Use our custom modelPlot to make a plot of errors centered on
  % distractors (ala Bays, Catalao & Husain, 2009, Figure 2B)
  function figHand = model_plot(data, params, varargin)
    d.errors = [];
    for i=1:length(data.errors)
      d.errors = [d.errors; circdist(data.errors(i), data.distractors(:,i))];
    end
    m = StandardMixtureModel();
    f = MAP(d, m);
    figHand = PlotModelFit(m, f, d, 'NewFigure', true);
    title('Error relative to distractor locations', 'FontSize', 14);
  end
end

function p = SwapModelPDF(data, mu, g, B, sd)
  % Parameter bounds check
  if g+B > 1
    p = zeros(size(data.errors));
    return;
  end
  
  % This could be vectorized entirely but would be less clear; but I assume
  % people will rarely have greater than 8 or so distractors, so the loop
  % is over a relatively small dimension
  nDistractors = size(data.distractors,1);
  p = (1-g-B).*vonmisespdf(data.errors(:),mu,deg2k(sd)) + ...
          (g).*unifpdf(data.errors(:), -180, 180);
  for i=1:nDistractors
    p = p + (B/nDistractors).*vonmisespdf(data.errors(:),mu+data.distractors(i,:)',deg2k(sd));
  end
end

% Swap model random number generator
function y = SwapModelGenerator(params,dims,displayInfo)
  n = prod(dims);

  % Assign types to trials
  r = rand(n,1);
  which = zeros(n,1); % default = remembered
  which(r<params{2}+params{3}) = randi(size(displayInfo.distractors,1), ...
    sum(r<params{2}+params{3}), 1); % swap to random distractor
  which(r<params{2}) = -1; % guess
  
  % Fill in with errors
  y = zeros(n,1);
  y(which==-1) = rand(sum(which==-1), 1)*360 - 180;
  y(which==0)  = vonmisesrnd(params{1},deg2k(params{4}), [sum(which==0) 1]);
  
  for d=1:size(displayInfo.distractors,1)
    y(which==d) = vonmisesrnd(params{1}+displayInfo.distractors(d,(which==d))', ...
      deg2k(params{4}), [sum(which==d) 1]);
  end
  
  % Reshape
  y = reshape(y,dims);
end
