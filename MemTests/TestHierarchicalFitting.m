% TESTHIERARCHICALFITTING compare hierarchical fitting of multiple subjects to independent fitting
% and ensure both work
%
%    TestHierarchicalFitting();
%
function TestHierarchicalFitting()
  % Which datasets to use
  datasets = {MemDataset(1), MemDataset(2), MemDataset(3), ...
    MemDataset(1), MemDataset(2), MemDataset(3),...
    MemDataset(1), MemDataset(2), MemDataset(3)};

  % How many trials to use per dataset. Fewer trials should lead to more
  % "shrinkage" of each subject's estimate toward the average subject
  numTrialsPer = 100;

  % Which model to use
  model = StandardMixtureModel();

  % -------

  % Setup dataset and fit
  for i=1:length(datasets)
    datasets{i}.errors = datasets{i}.errors(1:numTrialsPer);
  end
  hModel = Hierarchical(datasets, model);
  fitH = MAP(datasets, hModel);
  fitMLE = FitMultipleSubjects_MLE(datasets, model);

  % Show plots with and without hiearchical fit
  for i=1:length(datasets)
    subplot(length(datasets), 2, (i*2)-1);
    PlotModelFit(model, fitH.paramsSubs(i,:), datasets{i});

    subplot(length(datasets), 2, i*2);
    PlotModelFit(model, fitMLE.paramsSubs(i,:), datasets{i});
  end

  % Plot shrinkage
  figure;
  for i=1:length(model.paramNames)
    subplot(1, length(model.paramNames), i);
    scatter(fitMLE.paramsSubs(:,i), fitH.paramsSubs(:,i));
    axis square; ylim(xlim());
    line([0 max(xlim)], [0 max(xlim)]);
    title(model.paramNames{i});
    xlabel('Independent fit');
    ylabel('Hierarchical fit');
  end
end
