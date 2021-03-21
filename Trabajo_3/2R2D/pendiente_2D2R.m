
function  [Rsh0, Rs0] = pendiente_2D2R(I_mess, V_mess,s)

% Rsh0 
    %{ 
        Numero de puntos para interpolar
        Para s=1,2,3,4  : n = 3
        Para s=5        : n = 2 (aunque con 3 ahora ha ido bien)
    %}
    n = 3;
    [fit1, bondad] =  fit(V_mess(1:n)',I_mess(1:n)','poly1');
    p1 = coeffvalues(fit1);
    Rsh0 = 1/(-p1(1));
    
    % Rsh0 = 270; %19 marzo dani filtro s=3
    % Rsh0 = 210.6974; %19 marzo  dani filtro s=3
    % Rsh0 = 416; %19 marzo  dani filtro s=3
    % Rsh0 = 343.6159; %s= 3 buena del paper
    
% Rs0
    %{ 
        Numero de puntos para interpolar
        Para s=1,2,3,4  : n = 3
        Para s=5        : n = 2 (aunque con 3 ahora ha ido bien)
    %}
    n = 3;
    [fit2, bondad] = fit(V_mess(end-n:end)',I_mess(end-n:end)','poly1');
    p2 = coeffvalues(fit2);
    Rs0 = 1/(-p2(1));
    
    % Rs0 = 0.2576 % S= 3 buena del paper
    % Rs0 = 0.2479; %19 marzo  dani filtro s=3
    % Rs0 = 0.2011;%19 marzo  dani filtro s=3
    % Rs0 = 0.24;%19 marzo  dani filtro s=3
    
    if s==1
        Rsh0 = 45.2093;
        Rs0 = 0.09;
    elseif s==2
        Rsh0 = 227.152;
        Rs0 = 0.3015;
    elseif s == 3
        Rsh0 = 343.6159;
        Rs0 = 0.2576;
    elseif s == 4
        Rsh0 = 4783.0;
        Rs0 = 0.1735 ;
    elseif s == 5
        Rsh0 = Rsh0;
        Rs0 = Rs0;
    elseif s == 6
        Rsh0 = Rsh0;
        Rs0 = Rs0;
    elseif s == 7
        Rsh0 = Rsh0;
        Rs0 = Rs0;
    elseif s == 8
        Rsh0 = Rsh0;
        Rs0 = Rs0;
    elseif s == 9
        Rsh0 = Rsh0;
        Rs0 = Rs0;
    elseif s == 10
        Rsh0 = Rsh0;
        Rs0 = Rs0;
    elseif s == 11
        Rsh0 = Rsh0;
        Rs0 = Rs0;
    end
 
    
    
end


