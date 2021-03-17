
function  [Rsh0, Rs0] = pendiente_2D2R(I_mess, V_mess)

n=20; %s=3
[fit1, bondad] =  fit(V_mess(1:n)',I_mess(1:n)','poly1');
p1 = coeffvalues(fit1);
Rsh0 = 1/(-p1(1));

n=2;
[fit2, bondad] = fit(V_mess(end-n:end)',I_mess(end-n:end)','poly1');
p2 = coeffvalues(fit2);
Rs0 = 1/(-p2(1));
end