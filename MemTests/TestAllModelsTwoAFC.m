% TESTALLMODELSTWOAFC runs tests to be sure we are correctly sampling from and recovering the data
% for all the default models when they are converted to 2AFC format
%
%    TestAllModelsTwoAFC(numTrials, numItemsPerTrial);
%
function TestAllModelsTwoAFC(numTrials, numItemsPerTrial)

  % Default parameters
  if nargin < 1
    numTrials = 1000;
  end
  if nargin < 2
    numItemsPerTrial = 3;
  end

  % Which models to check:
  models = {...
    TwoAFC(NoGuessingModel()), ...
    TwoAFC(StandardMixtureModel()), ...
    TwoAFC(StandardMixtureModel('Bias', true)), ...
    TwoAFC(StandardMixtureModel('UseKappa', true)), ...
    TwoAFC(SwapModel()), ...
    TwoAFC(VariablePrecisionModel()) ...
  };

  % Try recovering parameters for each model
  for md=1:length(models)
    fprintf('\nModel: %s\n', models{md}.name);
    for s=1:size(models{md}.start,1)
      fprintf(' -- trying to recover params (%d of %d): ', s, size(models{md}.start,1));

      % Try sampling and fitting this model at each value of its start
      % parameters:
      paramsIn = models{md}.start(s,:);
      asCell = num2cell(models{md}.start(s,:));
      [paramsOut, lowerCI, upperCI] = ...
        TestSamplingAndFitting(models{md}, asCell, numTrials, ...
        numItemsPerTrial, 'Verbosity', 0);

      % Check that the credible intervals contain the correct parameter
      if all(paramsIn > lowerCI) && all(paramsIn < upperCI)
        fprintf('PASS\n');
      else
        which = find((paramsIn > lowerCI & paramsIn < upperCI) == 0, 1);
        fprintf('FAIL: %0.2f not in <%0.2f, %0.2f>\n', paramsIn(which), ...
          lowerCI(which), upperCI(which));
      end
    end
  end
end

