%{
    Programa que resuelve el Trabajo 1 de la asignatura
    Generacion y Gestion de Potencia Eelectrica
%}

clc;
clear all;
close all;
fig = 1;


%% DATOS

% Tierra
mu = 398600;                % km^3/s^2
rT = 6378;                  % km
J2 = 1.0827*10^-3;          % -

% Sol
beta = deg2rad(0);                  % rad (angulo beta -> sol/tierra)
beta_v = [cos(beta) sin(beta) 0];   % versor solar
G = 1361 ;                          % W/m2

% Orbita
h = [450, 500, 600];        % km
r = rT + h;                 % km
RAAN = deg2rad(22);         % rad

% Satelite
w = [0.05, 0.1, 0.5];       % rad/s
A = 0.3*0.1;                % m^2 Area 3U 
fc = 0.9;                   % factor de ocupacion REF : c.pdf ( pindado) pag 10.
rend = 0.29;                % aprox valor DataSheet Azure triple joint



%% CALCULO INCLINACION

cte = 2*pi/(365.25*24*3600);
inc = acos(((-3*rT^2*J2*mu^0.5)./(2*cte*r.^(7/2))).^(-1));

%% PERIODO ORBITAL Y ANGULOS EN FUNCION DEL TIEMPO

% Periodo de orbitas
T = 2*pi*sqrt(r.^3/mu);                 % s
anom_ver_punto = 1./sqrt(r.^3/mu);      % Velocidad angular anomalia verdadera

N=1e4+1; % Mallado temporal
for i = 1:3
    time(i,:) = linspace(0,T(i),N);            % Vector de tiempos 1 periodo
    anom_ver(i,:) = time(i,:)*anom_ver_punto(i);   % Anomalia verdadera
    for j = 1:3
        roll(:,i,j) = time(i,:)*w(j);              % Rotacion sat sobre su eje Z
    end
end



%% ECLIPSE
disp('*** Eclipses ***')
eclipse = ones(size(anom_ver)); % Vector señal eclipse booleano (0-1)

% Angulos de Sol y eclipse para cada orbita
for orb=1:length(h)
    
    inclinacion = inc(orb);
    
    Reo = Rx(inclinacion)*Rz(RAAN);         % Tierra - Orbita -> angulo con sol + inclinacion
    rho(orb) = asin(rT./(rT + h(orb)));
    beta_s(orb) = pi/2 - acos((Reo*beta_v')'*[0,0,1]');
    phi(orb) = real(2*acos(cos(rho(orb))/cos(beta_s(orb))));
    
    if phi(orb) ~= 0
        eclipse(orb, anom_ver(orb,:) >= (pi - phi(orb)/2) & anom_ver(orb,:) < (pi + phi(orb)/2) ) = 0;
        t_eclipse(orb) = max(time(eclipse(orb,:) == 0)) - min(time(eclipse(orb,:) == 0));
        anom_ver_eclipse_ini(orb) = min(anom_ver(eclipse(orb,:) == 0));
        anom_ver_eclipse_fin(orb) = max(anom_ver(eclipse(orb,:) == 0));

        disp(['Eclipse para h = ',num2str(h(orb)), ' km'])
        disp(['  ','t_eclipse = ',num2str(round(t_eclipse(orb))),' s'])
        disp(['  ','anom_ver_eclipse_ini = ',num2str(rad2deg(anom_ver_eclipse_ini(orb))),' deg'])
        disp(['  ','anom_ver_eclipse_fin = ',num2str(rad2deg(anom_ver_eclipse_fin(orb))+180),' deg'])
        
    else
        disp(['No hay eclipse para h = ',num2str(h(orb)), 'km'])
    end
    
end

% Plot eclipses
% h_plot(fig) = figure(fig);
%     hold on
%     plot(eclipse(1,:),'DisplayName','450 km')
%     plot(eclipse(2,:),'DisplayName','500 km')
%     plot(eclipse(3,:),'DisplayName','600 km')
%     legend()
%     title('Eclipse')
%     fig = fig+1;


    
%% ANGULO PANELES

for orb = 1:length(h)       % Bucle en alturas
    for vel = 1:length(w)   % Bucle en velocidades angulares  
        for p = 1:4         % Bucle en paneles  
            [angulo_panel(:,orb,vel,p), senal_panel(:,orb,vel,p)] = ...
                panel(w(vel), time(orb,:), (p-1)*pi/2);  
        end
    end
end

% h_plot(fig)=figure(fig);
%     hold on
%     for p = 1:1
%         %plot(time(1,:), cos(angulo_panel(:,1,1,p)).*senal_panel(:,1,1,p),...
%         %     'DisplayName',['Panel ' num2str(p)])
%         plot(time(1,:), cos(angulo_panel(:,1,1,p)),'DisplayName',['Panel ' num2str(p)])
%          plot(time(1,:), senal_panel(:,1,1,p),'DisplayName',['Señal Panel ' num2str(p)])
%         % plot(t(1,:), cos_panel(i,:).*( cos(anom_ver(1,:)*2 + pi) + 1 )/2)
%     end
%     legend()
%     title('cos(angulo panel)')
%     fig = fig+1;


%% SIMULACION

for orb = 1:length(h)                   % Bucle en alturas
    
    inclinacion = inc(orb);             % Inclinacion para cada orbita
    
    for vel = 1:length(w)               % Bucle en velocidades angulares        
        for p = 1:4                      % Bucle en paneles                 
            for t = 1:length(time(orb,:))   % Bucle en tiempo
                
                C_tierra_sol = Rz(beta);                        % Sol -> Tierra -> beta
                C_plano_tierra = Rx(inclinacion)*Rz(RAAN);      % Tierra -> plano orbital  
                C_orbita_plano = Rz(anom_ver(orb,t));           % plano orbital -> orbita
                C_sat_orbita = Rx(w(vel)*t+(p-1)*pi/2);         % orbita -> sat

                C_sat_tierra = C_sat_orbita*C_orbita_plano*C_plano_tierra*C_tierra_sol ;

                
                r_tierra = beta_v;
                r_orbita = C_sat_tierra*r_tierra'; 
                
                potencia_panel(t,p,orb,vel) = G*rend*A*fc*(r_orbita'*[0 0 1]')*eclipse(orb,t);  % Caras con panel: Y Z
                                
            end
        end
    end
end

% Suma de la contribucion de los paneles
potencia_panel = max(0,potencia_panel); %Hacer 0 cuando las caras están de espaldas al Sol
P_m = sum(potencia_panel,2);

% Plot potencias
for orb=1:length(h)
    for vel =1:length(w)
        h_plot(fig) = figure(fig);
            hold on
            for p = 1:4
                plot(rad2deg(anom_ver(1,:)),potencia_panel(:,p,orb,vel),'DisplayName',['Panel ' num2str(p)])
            end
            plot(rad2deg(anom_ver(1,:)),P_m(:,1,orb,vel),'DisplayName','Potencia total')
            box on
            legend()
            title(['Simuacion ',num2str(h(orb)),' ',num2str(w(vel))])
            xlabel('\nu[deg]')
            ylabel('Potencia')
            hold off
            fig = fig+1;
    end
end

% Potencias medias
disp(' *** Potencias medias ***')

for orb = 1:length(h)                   % Bucle en alturas    
    disp(['Potencias medias generadas para h = ',num2str(h(orb)), ' km'])    
    for vel = 1:length(w)               % Bucle en velocidades angulares     
        Potencia_media_generada(orb,vel) = trapz(time(orb,:), P_m(:,1,orb,vel))/T(orb);
        disp(['  ','w = ', num2str(w(vel)),' rad/s -> ','Pm = ',num2str(Potencia_media_generada(orb,vel)), ' W'])
    end
end


%% FUNCIONES

% Calculo de angulo sol-panel
function [angulo, senal] = panel(w, t, desfase)

    angulo = acos(cos(w*t(:) + desfase));      %rad
    
    senal = ones(size(angulo));
    senal(angulo>pi/2) = 0;
    %angulo(angulo>pi/2) = pi/2;

    %cos_angulo = cos(angulo);
end


% Matrices de cambio de base
function [Rx] = Rx(angle)

    Rx = [1 0 0;... 
          0 cos(angle) sin(angle);...
          0 -sin(angle) cos(angle)];

end

function [Ry] = Ry(angle)

    Ry = [cos(angle) 0 -sin(angle);...
          0 1 0;...
          sin(angle) 0 cos(angle)];

end

function [Rz] = Rz(angle)

    Rz = [cos(angle) sin(angle) 0;...
        -sin(angle) cos(angle) 0;...
        0 0 1];

end