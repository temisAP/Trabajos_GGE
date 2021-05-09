function rmse = RMSE(V_exp, V_sim, N)
aux=0;
for i = 1:N
    aux = aux + (V_exp(i) - V_sim(i))^2;
end
rmse = sqrt(aux/N);