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
%{
figure()
hold on
plot(sin(alfa(1,:)),'DisplayName', 'Orbita')
plot(sin(reshape(roll(1,1,:),1,[])),'DisplayName', 'Roll')
legend()
%}

% Eclipse
rho = asin(rT./(rT + h));
% alfa(alfa >= (pi - rho) & ro < (-pi + rho) ) = 0;



%% Potencia
Wo = 1360;              % W
W = Wo*cos(beta)*sin(alfa/2);

desfase = 0;%-3*pi/2;

% incidencia para cada
for i = 1:4 
    cos_panel(i,:) = panel(w(1), t(1,:), -(i-1)*pi);
end

figure()
title('cos(aol-panel)')
hold on
for i = 1:4
    plot(t(1,:), W(1,:).*cos_panel(i,:))
end
legend()


%{
roll = w(1)*t(1,:);

desfase = 0;%-3*pi/2;
roll_panel = 2*roll + desfase;
cos_panel = ( cos(roll_panel) + 1 )/2 ;

figure()
title('roll panel')
plot(roll(1:300),cos_panel(1:300),'LineWidth', 2)



%% https://es.mathworks.com/matlabcentral/answers/263666-how-to-create-positive-or-negative-half-cycle-of-sine-wave

% t = linspace(0,pi,1e3+1);
f = 0.5;% Input Signal Frequency
x = sin(roll_panel*f - pi/2);% Generate Sine Wave  f*roll+pi/4
x(x>0) = 0;                       % Rectified Sine Wave
x(x~=0) = 1;
plot(t(1,:),x);

figure()
hold on
plot(roll(1:300),cos_panel(1:300),'LineWidth', 2)
plot(roll(1:300),x(1:300),'LineWidth', 2)
plot(roll(1:300),cos_panel(1:300).*x(1:300),'LineWidth', 2)
%}



%% FUNCIONES

function [cos_panel] = panel(w, t, desfase)

    % Generar angulo sol-panel
    roll = w*t;
    roll_panel = 2*roll + desfase;
    cos_panel = ( cos(roll_panel) + 1 )/2 ;
    
    % Rectificar onda
    f = 0.5;
    x = sin(roll_panel*f - pi/2);
    x(x>0) = 0;
    x(x~=0) = 1;
    
    cos_panel = cos_panel.*x;
    


end