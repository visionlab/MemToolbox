function GridSearch_Example()
  d = load('MemData/data.mat');
  data = d.data(:);
  model = StandardMixtureModelWithBias();
 
  % First do grid search over the entire parameter space:
  [logLikeMatrix, valuesUsed] = GridSearch(data, model);
  
  % and visualize:
  h=GridSearch_Plot(logLikeMatrix, valuesUsed, model.paramNames);
  subfigure(2,2,1,h);
  
  % Not very useful, right? Here's what it is really useful for.
  % First lets do MCMC to get some idea of the shape of the likelihood
  % function:
  stored = MCMC_Convergence(data,model);
  h=MCMC_Plot(stored, model.paramNames);
  subfigure(2,2,2,h);
  
  % Now lets refine the grid search to look only at reasonable values: 
  model.upperbound = max(stored.vals);
  model.lowerbound = min(stored.vals);
  [logLikeMatrix, valuesUsed] = GridSearch(data, model);
  h=GridSearch_Plot(logLikeMatrix, valuesUsed, model.paramNames);
  subfigure(2,2,3,h);    
end




