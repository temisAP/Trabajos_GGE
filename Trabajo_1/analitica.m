
%Calculo analítico potencia

clc;
clear all;
close all;

fc = 0.9; % factor de ocupacion REF : c.pdf ( pindado) pag 10.
rend = 0.29; % aprox valor DataSheet Azure triple joint

mu = 398600;                % km^3/s^2
rT = 6378;                  % km
h = [450, 500, 600];        % km
r = rT + h;                 % km
beta = 0;                   % angulo beta -> sol/tierra
%w = [0.05, 0.1, 0.5];       % rad/s
A = 0.3*0.1;                 % m^2 Area 3U 
G = 1361 ;                  % W/m2


%% DATOS ORBITA
RAAN = deg2rad(22);        % radianes
inc = pi/2;       %  Inclinacion % radianes % aproximación de 90 para el analitco
n_0p = [0 0 1];   %Vector normal al plano orbital
%% DESARROLLO

% Periodo de orbitas
T = 2*pi*sqrt(r.^3/mu);     % s
wa = 1./sqrt(r.^3/mu);      % rad/s

%% POSICION SOL

 r_sun_ECI = [1 0 0] ; % Fecha: Equinocio primavera
 r_sun_OP = mtimes(ROT_X(inc),ROT_Z(RAAN))* r_sun_ECI'; 
 
 

%% ECLIPSE

rho = asin (rT./(rT + h));
beta_s = pi/2 - acos(dot(r_sun_OP,n_0p));
phi = 2*acos(cos(rho)/cos(beta_s));




%% CALCULO POTENCIA
Te = T.*(phi/(2*pi));

% Angulo actitud sat respecto a beta // angulo rotado desde t = 0
for i = 1:3
    t(i,:) = linspace(0,T(i),1e4+1);
    alfa(i,:) = t(i,:)*wa(i);
    
%     alfa_1 = alfa(i,:);
    
    alfa(alfa(i,:)>= (pi - phi(1)/2) & alfa(i,:) < (pi + phi(1)/2) ) = 0;
end

alfa_y =alfa;
 
alfa_y(alfa_y ~= 0) = 1;
     
 
P_yi =  G*A*fc*1*rend*sin(beta_s)*alfa_y;         % Potencia cota inferior en y
P_ys =  G*A*fc*sqrt(2)*rend*sin(beta_s)*alfa_y;

P_media_yi =  G*A*fc*1*rend*sin(beta_s)*(T-Te)/T;         % Potencia cota inferior en y
P_media_ys =  G*A*fc*sqrt(2)*rend*sin(beta_s)*(T-Te)/T;   % Potencia cota superior en y


P_xi =  G*A*fc*1*rend*cos(beta_s)*cos(alfa);         % Potencia cota inferior en y
P_xs =  G*A*fc*sqrt(2)*rend*cos(beta_s)*cos(alfa);

%% PLOT


for i=1:3
    
    figure(i)
    hold on
    plot(alfa(i,:), P_yi(i,:))
    plot(alfa(i,:), P_ys(i,:))
    plot(alfa(i,:), P_xi(i,:))
    plot(alfa(i,:), P_xs(i,:))
    legend()
    title('cos(angulo panel)')
    grid on
    
end
    

%% FUNCIONES MATRICES ROTACION ( Angulo en radianes)

function [RX] = ROT_X(angle)

RX = [1 0 0;... 
      0 cos(angle) sin(angle);...
      0 -sin(angle) cos(angle)];

end


function [RY] = ROT_Y(angle)

RY = [cos(angle) 0 -sin(angle);...
      0 1 0;...
      sin(angle) 0 cos(angle)];

end


function [RZ] = ROT_Z(angle)

RZ = [cos(angle) sin(angle) 0;...
    -sin(angle) cos(angle) 0;...
    0 0 1];

end
