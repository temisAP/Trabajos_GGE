function rmse = RMSE(Isc, I_mess, I_anal, N)
aux=0;
for i = 1:N
    aux = aux + (I_mess(i) - I_anal(i))^2;
end
rmse = (100/Isc)*sqrt(aux/N);