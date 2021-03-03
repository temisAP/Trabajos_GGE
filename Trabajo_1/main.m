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



%% DESARROLLO

% Periodo de orbitas
T = 2*pi*sqrt(r.^3/mu);     % s
wa = 1./sqrt(r.^3/mu);      % rad/s


% Aungulo actitud sat respecto a beta // angulo rotado desde t = 0
for i = 1:3
    t(i,:) = linspace(0,T(i),1e4+1);
    alfa(i,:) = t(i,:)*wa(i);
    for j = 1:3
        roll(i,j,:) = t(i,:)*w(j);
    end
end


% Eclipse
rho = asin(rT./(rT + h));
alfa_1 = alfa(1,:);
alfa_1(alfa_1 >= (pi - rho(1)) & alfa_1 < (pi + rho(1)) ) = 0;



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
        plot(t(1,:), cos_panel(i,:).*( cos(alfa(1,:)*2 + pi) + 1 )/2)
    end
    legend()
    title('cos(angulo panel)')
    
figure()
    plot(t(1,:), sum(cos_panel,1).*( cos(alfa_1*2 + pi) + 1 )/2)
    title('Suma 4 paneles')





%% FUNCIONES

function [cos_angulo] = panel(w, t, desfase)

    angulo = acos(cos(w(1)*t(1,:) + desfase));      %rad
    angulo(angulo>pi/2) = pi/2;

    cos_angulo = cos(angulo);
end