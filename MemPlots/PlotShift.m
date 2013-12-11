% DOTSHIFTPLOT Plots shift in parameter values between two conditions, for
% each subject and for the group average.
%
%   Sample usage:
%
%   cond1 = rand(10,3); % rows are parameters, columns are subjects
%   cond2 = rand(10,3)
%   PlotShift(cond1,cond2)
%   PlotShift(cond1,cond2,{'p1','p2','p3'},{@mean,@mean,@circ_mean})
%
function f = PlotShift(cond1,cond2,paramNames,averagingFunctions)

  if nargin < 3
    for i = 1:size(cond1,2)
      paramNames{i} = ['Parameter ' num2str(i)];
    end
  end

  if nargin < 4
    for i = 1:size(cond1,2)
      averagingFunctions{i} = @mean;
    end
  end

  f = figure();
  numParameters = size(cond1,2);
  combos = combnk([1:numParameters],2);
  numCombos = size(combos,1);

  for i = 1:numCombos
    p1 = combos(i,1);
    p2 = combos(i,2);

    mean1 = averagingFunctions{p1};
    mean2 = averagingFunctions{p2};

    subplot(1,numCombos,i)
    hold on;

    %plot subject changes
    for j = 1:size(cond1,1)
      line([cond1(j,p1) cond2(j,p1)], [cond1(j,p2) cond2(j,p2)], ...
        'LineStyle', '-', 'Color', [0.85,0.85,0.85])
    end
    plot(cond1(:,p1), cond1(:,p2), 'LineStyle', 'none', 'MarkerSize', 18, 'Marker', '.', ...
      'Color', [0.75 0.75 0.75]);
    plot(cond2(:,p1), cond2(:,p2), 'LineStyle', 'none', 'MarkerSize', 18, 'Marker', '.', ...
      'Color', [0.3 0.3 0.3]);

    % plot mean changes
    line([mean1(cond1(:,p1)) mean1(cond2(:,p1))], [mean2(cond1(:,p2)) mean2(cond2(:,p2))], ...
      'Color', [0.0432, 0.4098, 0.5098], 'LineWidth', 1.5)
    plot(mean1(cond1(:,p1)),mean2(cond1(:,p2)), 'Marker', '.', 'MarkerSize', 32, ...
      'Color', [0.0863, 0.5765, 0.6471])
    plot(mean1(cond2(:,p1)),mean2(cond2(:,p2)), 'Marker', '.', 'MarkerSize', 32, ...
      'Color', [0, 0.2431, 0.3725])

    xlabel(paramNames{p1}, 'FontSize', 13);
    ylabel(paramNames{p2}, 'FontSize', 13);

    makepalettable(f);
  end
end
