% Describe in words the various model comparsion metrics
function DescribeModelComparisonResults(name,stats)
  fprintf('* ')
  switch name
     case 'Bayes factor'
     case 'AIC'
     case 'AICc'
     case 'BIC'
     case 'DIC'
     case 'Log posterior odds'
     case 'Log likelihood'
     otherwise
        fprintf('There is no description available for this comparison.')
  end
  fprintf('\n')
end