function model = BinomialModel()
  model.paramNames = {'g', 'nQ', 'p', 's'};
  model.lowerbound = [0 1 0 0]; % Lower bounds for the parameters
  model.upperbound = [1 Inf 1 Inf]; % Upper bounds for the parameters
  model.movestd = [0.02, 1, 0.02, 1];
  model.pdf = @binomialpdf;
  model.start = [0.0, 10, 0.2, 10;
                   0.2, 100, 0.3, 1;
                   0.4, 1, 0.1, 2;
                   0.6, 40, 0.9, 50];
end
  
function y = binomialpdf(data,g,nQ,p,s)
        
    nQ = round(nQ); % assert an integral number of quanta
    q = s*sqrt(nQ); % the precision of 1 quantum
    
    % precompute uniform component
    uni = unifpdf(data,-pi,pi);
    
    % precompute binomial component
    bino = binopdf([0:nQ], nQ, p);
        
    y = 0;
    for i = 0:nQ
       y = y + (1-g).*bino(i+1).*vonmisespdf(data,0,sd2k(q./sqrt(i))) + ...
                 (g).*uni;
    end 
end