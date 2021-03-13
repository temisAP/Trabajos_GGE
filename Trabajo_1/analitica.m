clc;
clear all;
close all;
fig = 1;


%% CÁLCULO ANALÍTICO DE POTENCIA

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
for i = 1:length(h)
    t(i,:) = linspace(0,T(i),1e4+1);
    alfa(i,:) = t(i,:)*wa(i);
    alfa_1(i,:) = rad2deg(t(i,:)*wa(i));
%     alfa_1 = alfa(i,:);
    
   %alfa((alfa(i,:)-mod(alfa(i,:),2*pi)*2*pi)>= (pi - phi(1)/2) & (alfa(i,:)-mod(alfa(i,:),2*pi)*2*pi) < (pi + phi(1)/2) ) = 0;
%     alfa(alfa(i,:)>= (pi - phi(i)/2) & alfa(i,:) < (pi + phi(i)/2) )) = 0;
    for j = 1:length(alfa)
        if alfa(i,j)>= (pi - phi(i)/2) 
            if alfa(i,j) <= (pi + phi(i)/2)
            alfa(i,j) = 0;
            end
        end
    end
end

alfa_y =alfa;
 
alfa_y(alfa_y ~= 0) = 1;
     
% Potencia en y 
P_yi =  G*A*fc*1*rend*sin(beta_s)*alfa_y;         % Potencia cota inferior en y
P_ys =  G*A*fc*sqrt(2)*rend*sin(beta_s)*alfa_y;

% Potencia en x
P_xi =  abs(G*A*fc*1*rend*cos(beta_s)*sin(alfa));         % Potencia cota inferior en y
P_xs =  abs(G*A*fc*sqrt(2)*rend*cos(beta_s)*sin(alfa));

% Potencias medias.

P_i = P_xi + P_yi;
P_s = P_xs + P_ys;
P_m = (P_s + P_i)/2;

for i=1:length(h)
    Potencia_media_inferior_generada(i) = trapz(t(i,:), P_i(i,:))/T(i);
    Potencia_media_superior_generada(i) = trapz(t(i,:), P_s(i,:))/T(i);
    Potencia_media_generada(i) = trapz(t(i,:), P_m(i,:))/T(i);
    Potencia_media_analitica(i) = G*A*fc*rend*cos(beta_s)*(1 + sqrt(2))/2*1/(2*pi)*(integral(@(x)sin(x),0,(pi-phi(i)/2))+abs(integral(@(x)sin(x),(pi+phi(i)/2), 2*pi)))+...
                               2*G*A*fc*rend*sin(beta_s)*(1 + sqrt(2))/2*(T(i)-Te(i))/(2*T(i));
end

%% PLOT

graph_rep = 'yes';

if graph_rep == 'yes'
    
    for i = 1:length(h)
        h(fig) = figure(fig);
        hold on
        plot(alfa_1(i,:), P_i(i,:), '-.', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
            ["Potencia m\'inima"])
        plot(alfa_1(i,:), P_s(i,:), '--', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
            ["Potencia m\'axima"])
        plot(alfa_1(i,:), P_m(i,:), '-', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
            ["Potencia media"])
        axis([0, 361, 0, 20])
        box on; grid on
        legend('Interpreter', 'Latex', 'location', 'SouthEast')
        xlabel('$\theta$ [$^\circ$]','Interpreter','latex');
        ylabel({'$P$';'[W]'},'Interpreter','latex');
        Save_as_PDF(h(fig), ['Figures/analitica',num2str(fig)],'horizontal');
        hold off
        fig = fig+1;
    end
    
end


graph_rep = 'noo';

if graph_rep == 'yes'
    
    for i = 1:length(h)
        h(fig) = figure(fig);
        hold on
        plot(t(i,:), P_i(i,:), '-.', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
            ["Potencia m\'inima"])
        plot(t(i,:), P_s(i,:), '--', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
            ["Potencia m\'axima"])
        plot(t(i,:), P_m(i,:), '-', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
            ["Potencia media"])
        axis([0, 361, 0, 20])
        box on; grid on
        legend('Interpreter', 'Latex', 'location', 'Best')
        xlabel('$t$ [s]','Interpreter','latex');
        ylabel({'$P$';'[W]'},'Interpreter','latex');
        Save_as_PDF(h(fig), ['Figures/analitica',num2str(fig)],'horizontal');
        hold off
        fig = fig+1;
    end
    
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

