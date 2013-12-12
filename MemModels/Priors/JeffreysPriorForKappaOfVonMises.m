function y = JeffreysPriorForKappaOfVonMises(K)
  % Do calculation in log space to avoid overflow
  z = exp((log(besseli(1,K,1)) + K) - (log(besseli(0,K,1)) + K));
  y = z .* (K - z - K.*z.^2);
end
