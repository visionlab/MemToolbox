function model = BinomialModel()
  model.paramNames = {'g', 'nQ', 'p', 's'};
  model.lowerbound = [0 1 0 0]; % Lower bounds for the parameters
  model.upperbound = [1 100 1 Inf]; % Upper bounds for the parameters
  model.movestd = [0.1, 2, 0.05, 2];
  model.pdf = @binomialpdf;
  model.start = [0.0, 10, 0.2, 11];
end
  
function y = binomialpdf(data,g,nQ,p,s)
        
    nQ = round(nQ); % assert an integral number of quanta
    q = s*sqrt(nQ); % the precision of 1 quantum
    
    % precompute uniform component
    yUniform = unifpdf(data,-pi,pi);
    
    % precompute binomial probabilities
    bino = binopdf([0:nQ], nQ, p);
    
    % compute binomial component
    yBinomial = 0;
    for i = 0:nQ
       yBinomial = yBinomial + bino(i+1).*vonmisespdf(data,0,sd2k(q./sqrt(i)));
    end 
    y = (1-g).*yBinomial + (g).*yUniform;
end
