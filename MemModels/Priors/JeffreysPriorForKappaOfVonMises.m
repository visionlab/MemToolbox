function y = JeffreysPriorForKappaOfVonMises(K)
  z = besseli(1,K) / besseli(0,K);
  y = z * (K - z - K*z^2);
end