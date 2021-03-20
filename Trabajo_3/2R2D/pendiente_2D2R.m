
function  [Rsh0, Rs0] = pendiente_2D2R(I_mess, V_mess)

 n=3; %s=3 % s=1,2,4
%  n = 2 %s=5
 [fit1, bondad] =  fit(V_mess(1:n)',I_mess(1:n)','poly1');
 p1 = coeffvalues(fit1);
%  Rsh0 = 1/(-p1(1));
% Rsh0 = 270; %19 marzo dani filtro s=3
% Rsh0 = 210.6974; %19 marzo  dani filtro s=3
% Rsh0 = 416; %19 marzo  dani filtro s=3
  Rsh0 = 343.6159; %s= 3 buena del paper
 n=3; %s=1,2,4
%  n = 2; %s =5
[fit2, bondad] = fit(V_mess(end-n:end)',I_mess(end-n:end)','poly1');
p2 = coeffvalues(fit2);
Rs0 = 1/(-p2(1));
%   Rs0 = 0.2576 % S= 3 buena del paper
% Rs0 = 0.2479; %19 marzo  dani filtro s=3
%  Rs0 = 0.2011;%19 marzo  dani filtro s=3
%   Rs0 = 0.24;%19 marzo  dani filtro s=3
end


