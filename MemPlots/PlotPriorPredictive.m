%PLOTPRIORPREDICTIVE Show data sampled from the model's prior
% it requires a data struct so that it knows how many trials to sample (and
% for models that require it, what distractors to imagine, etc).
%
%   figHand = PlotPriorPredictive(model, data, [optionalParameters])
% 
% Optional parameters:
%  'NumberOfBins' - the number of bins to use in display the data. Default
%  55.
% 
%  'NumSamplesToPlot' - how many prior samples to show in the prior
%  predictive plot. Default is 48.
%
%  'PdfColor' - the color to plot the model fit with. 
%
%  'NewFigure' - whether to make a new figure or plot into the currently
%  active subplot. Default is false (e.g., plot into current plot).
% 
%  'UseModelComparisonPrior' - whether to use the normal diffuse prior for
%  the model, model.prior (default), or whether to use the prior used for 
%  computing Bayes Factors, model.priorForMC (if set to true).
%
function figHand = PlotPriorPredictive(model, data, varargin)
  % Show data sampled from the model with the actual data overlayed, plus a
  % difference plot.
  args = struct('NumSamplesToPlot', 48, 'NumberOfBins', 55, ...
    'PdfColor', [0.54, 0.61, 0.06], 'NewFigure', true, ...
    'UseModelComparisonPrior', false); 
  args = parseargs(varargin, args);
  
  % Check for right functions
  if args.UseModelComparisonPrior && ~isfield(model, 'priorForMC')
   fprintf(['WARNING: You said to use the model comparison prior (priorForMC),\n'...
     'but the model you specified does not include such a prior. We will \n'...
     'instead show samples from the normal prior.']);
  end
  
  % Figure options
  args = parseargs(varargin, args);
  if args.NewFigure, figHand = figure(); end
  
  % Sample from prior
  priorModel = EnsureAllModelMethods(model);
  if args.UseModelComparisonPrior
    priorModel.prior = priorModel.priorForMC;
    priorModel.logprior = @(p) sum(log(priorModel.priorForMC(p)));
  end
  priorModel.pdf = @(data, varargin)(1);
  priorModel.logpdf = @(data, varargin)(0);
  priorSamples = MCMC([], priorModel, 'Verbosity', 0, ...
    'PostConvergenceSamples', args.NumSamplesToPlot);  
    
  % What kind of data to sample
  x = linspace(-180, 180, args.NumberOfBins)';
  if isfield(data, 'errors')
     nSamples = numel(data.errors);
  else
     nSamples = numel(data.afcCorrect);
  end
    
  % Plot samples
  sampTime = tic();
  h = [];
  for i=1:args.NumSamplesToPlot
    
    % Generate random data from this distribution with these parameters
    asCell = num2cell(priorSamples.vals(i,:));
    yrep = SampleFromModel(model, asCell, [1 nSamples], data);
    if i==1 && toc(sampTime)>(2.0/args.NumSamplesToPlot) % if it will take more than 5s...
      h = waitbar(i/args.NumSamplesToPlot, 'Sampling to get prior predictive distribution...');
    elseif ~isempty(h)
      if ~ishandle(h) % they closed the waitbar; stop sampling here
        break;
      end
      waitbar(i/args.NumSamplesToPlot, h);
    end
    
    % Bin data
    normalizedYRep = getNormalizedBinnedReplication(yrep, data, x);
    if any(isnan(normalizedYRep))
      hSim = plot(x, normalizedYRep, 'x-', 'Color', args.PdfColor, 'LineSmoothing', 'on');
    else
      hSim = plot(x, normalizedYRep, '-', 'Color', args.PdfColor, 'LineSmoothing', 'on');
    end
    hold on;
  end  
  if ishandle(h), close(h); end
  xlim([-180, 180]);
  makepalettable();
end

function y = getNormalizedBinnedReplication(yrep, data, x)
  if isfield(data, 'errors')
    y = hist(yrep, x)';
    y = y ./ sum(y(:));
  else
    for i=1:length(x)
      distM(:,i) = (data.changeSize - x(i)).^2;
    end
    [tmp, whichBin] = min(distM,[],2);
    for i=1:length(x)
      y(i) = mean(yrep(whichBin==i));
    end
  end
end
