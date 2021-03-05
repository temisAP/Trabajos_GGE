%{
    Programa que resuelve el Trabajo 1 de la asignatura
    Generacion y Gestion de Potencia Eelectrica
%}

clc;
clear all;
close all;


%% DATOS

mu = 398600;                % km^3/s^2
rT = 6378;                  % km
h = [450, 500, 600];        % km
r = rT + h;                 % km
beta = 0;                   % angulo beta -> sol/tietta
w = [0.05, 0.1, 0.5];       % rad/s
RAAN = 0;
inc = 0;



%%   DESARROLLO   %%


%% PERIODO ORBITAL Y ANGULOS EN FUNCION DEL TIEMPO

% Periodo de orbitas
T = 2*pi*sqrt(r.^3/mu);                 % s
anom_ver_punto = 1./sqrt(r.^3/mu);      % Velocidad angular anomalia verdadera


for i = 1:3
    t(i,:) = linspace(0,T(i),1e4+1);            % Vector de tiempos 1 periodo
    anom_ver(i,:) = t(i,:)*anom_ver_punto(i);   % Anomalia verdadera
    for j = 1:3
        roll(:,i,j) = t(i,:)*w(j);              % Rotacion sat sobre su eje Z
    end
end

% Cambios de base
Reo = Rz(RAAN)*Rx(inc);         % Tierra - Orbita -> angulo con sol + inclinacion




%% ECLIPSE

% utilizando phi
rho = asin(rT./(rT + h));
beta_s = pi/2 - acos([1,0,0]*Reo*[1,0,0]');
phi = 2*acos(cos(rho)/cos(beta_s));

% Sacando angulo de eclipse con rho
alfa_1 = anom_ver(1,:);
alfa_1(alfa_1 >= (pi - rho(1)) & alfa_1 < (pi + rho(1)) ) = 0;


%% CAMBIOS DE BASE

RAAN = 0;
inc = 0;

Reo = Rz(RAAN)*Rx(inc);         % Tierra - Orbita -> angulo con sol + inclinacion
Ros = Rz(anom_ver);             % Orbita - Sat -> ejes giran con anomalia verdadera
Rsp = Ry(pi/2)*Rz(w*t);         % Sat - paneles -> rotado 90 en y para que 
                                % coincida el eje Z con la direccion 3U
                                % Rota en funcion del tiempo sobre Z






%% Potencia
Wo = 1360;              % W
W = Wo*cos(beta);

desfase = 0;

% incidencia para cada panel x+, y+, x-, y-
for i = 1:4 
    cos_panel(i,:) = panel(w(1), t(1,:), (i-1)*pi/2);
end

figure()
    hold on
    for i = 1:4
        plot(t(1,:), cos_panel(i,:).*( cos(anom_ver(1,:)*2 + pi) + 1 )/2)
    end
    legend()
    title('cos(angulo panel)')
    
figure()
    plot(t(1,:), sum(cos_panel,1).*( cos(alfa_1*2 + pi) + 1 )/2)
    title('Suma 4 paneles')




%% CAMBIOS DE BASE

RAAN = 0;
inc = 0;

Reo = Rz(RAAN)*Rx(inc);         % Tierra - Orbita -> angulo con sol + inclinacion
Ros = Rz(anom_ver_punto);             % Orbita - Sat -> ejes giran con anomalia verdadera
Rsp = Ry(pi/2)*Rz(w*t);         % Sat - paneles -> rotado 90 en y para que 
                                % coincida el eje Z con la direccion 3U
                                % Rota en funcion del tiempo sobre Z
 
    
    
    
    

%% FUNCIONES

% Calculo de angulo sol-panel
function [cos_angulo] = panel(w, t, desfase)

    angulo = acos(cos(w(1)*t(1,:) + desfase));      %rad
    angulo(angulo>pi/2) = pi/2;

    cos_angulo = cos(angulo);
end


% Matrices de cambio de base
function [Rx] = ROT_X(angle)

    Rx = [1 0 0;... 
          0 cos(angle) sin(angle);...
          0 -sin(angle) cos(angle)];

end

function [Ry] = ROT_Y(angle)

    Ry = [cos(angle) 0 -sin(angle);...
          0 1 0;...
          sin(angle) 0 cos(angle)];

end

function [Rz] = ROT_Z(angle)

    Rz = [cos(angle) sin(angle) 0;...
        -sin(angle) cos(angle) 0;...
        0 0 1];

end