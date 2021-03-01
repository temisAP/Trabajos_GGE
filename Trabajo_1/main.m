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
b = 0;                      % angulo beta -> sol/tietta
w = [0.05, 0.1, 0.5];       % rad/s


%% DESARROLLO

% Periodo de orbitas
T = 2*pi*sqrt(r.^3/mu);     % s
wa = 1./sqrt(r.^3/mu);      % rad/s

% Aungulo actitud sat respecto a beta // angulo rotado desde t = 0
for i = 1:3
    t(i,:) = linspace(0,T(i),1e3+1);
    alfa(i,:) = t(i,:)*wa(i);
    for j = 1:3
        roll(i,j,:) = t(i,:)*w(j);
    end
end

figure()
hold on
plot(sin(alfa(1,:)),'DisplayName', 'Orbita')
plot(sin(reshape(roll(1,1,:),1,[])),'DisplayName', 'Roll')
legend()

% Eclipse
ro = asin(rT./(rT + h));


