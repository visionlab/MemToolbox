function model = BinomialModel()
  model.name = 'Binomial pure death model';
  model.paramNames = {'g', 'nQ', 'p', 's', 'mu'};
  model.lowerbound = [0 1 0 0 -pi]; % Lower bounds for the parameters
  model.upperbound = [1 100 1 Inf pi]; % Upper bounds for the parameters
  model.movestd = [0.1, 2, 0.05, 2, 0.01];
  model.pdf = @binomialpdf;
  model.start = [0.0, 10, 0.2, 11, 0];
  %model.generator = @
end
  
function y = binomialpdf(data,g,nQ,p,s,mu)
        
    nQ = round(nQ); % assert an integral number of quanta
    q = s*sqrt(nQ); % the precision of 1 quantum
    
    % precompute uniform component
    yUniform = unifpdf(data,-pi,pi);
    
    % precompute binomial probabilities
    bino = binopdf([0:nQ], nQ, p);
    
    % compute binomial component
    yBinomial = 0;
    for i = 0:nQ
       yBinomial = yBinomial + bino(i+1).*vonmisespdf(data,mu,sd2k(q./sqrt(i)));
    end
    
    % combine
    y = (1-g).*yBinomial + (g).*yUniform;
end
