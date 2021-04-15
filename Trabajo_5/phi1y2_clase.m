%% Primera estimación de la energía descargada

for f = 1:2:length(Ensayos_Bateria)

    Id = Ensayos_Bateria.(fields{f}).I;
    V = Ensayos_Bateria.(fields{f}).V;
    time = Ensayos_Bateria.(fields{f}).t;

    phi1(1) = 0;
    phi2(1) = 0;
    for t = 2:length(time)
        Dt = time(t)-time(t-1);
        phi1(t) = phi1(t-1) + Id(t)*(V(t)+V(t-1))/2 * Dt;
        phi2(t) = phi2(t-1) + Id(t)^2;
    end
    Ensayos_Bateria.(fields{f}).phi1 = phi1';
    Ensayos_Bateria.(fields{f}).phi2 = phi2';

    clear Id V time t Dt phi1 phi2 %Esto es para luego no tener 1000 variables

end

%% Modelo lineal

% Fit no linear model:
% Vector de pesos para datos descompensados

%% Modelo exponencial

% Fit no linear model:
%
