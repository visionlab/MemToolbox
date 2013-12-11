function y = JeffreysPriorForDegreesOfFreedom(df)

  term1 = df./(df+3);

  term2a = trigamma(df./2);
  term2b = trigamma((df+1)./2);
  term2c = (2.*(df+3))./(df.*((df+1).^2));

  y = sqrt(term1) .* sqrt(term2a - term2b - term2c);

end
