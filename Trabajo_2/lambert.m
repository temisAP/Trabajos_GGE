function W = lambert(x)
    sigma = -1 - log(-x);
    f_sigma = (0.23766*sqrt(sigma))/(1-0.0042*sigma*exp(-0.0201*sqrt(sigma)));
    W = -1 - sigma - 5.95061*(1-1/(1+f_sigma));
end 