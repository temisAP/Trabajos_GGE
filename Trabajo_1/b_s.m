%{
    Para distintos beta_s ver cómo evoluciona la potencia media 
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


%% PRINCIPIO DEL BUCLE

beta = linspace(deg2rad(-23.5),deg2rad(360-23.5),366);
t1 = datetime(2021,12,21);
t2 = datetime(2022,12,21);
days = t1:t2;

calculo = 'n';

if calculo == 'y'

for b=1:length(beta)
    
    beta_v = [cos(beta(b)) sin(beta(b)) 0];   % versor solar
    
    %% Eclipse
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
        else
            disp(['No hay eclipse para h = ',num2str(h(orb)), 'km'])
        end
        
    end  
        
    %% SIMULACION
    
    for orb = 1:length(h)                   % Bucle en alturas
        
        inclinacion = inc(orb);             % Inclinacion para cada orbita
        
        for vel = 1:length(w)               % Bucle en velocidades angulares
            for p = 1:4                      % Bucle en paneles
                for t = 1:length(time(orb,:))   % Bucle en tiempo
                    
                    C_plano_tierra = Rx(inclinacion)*Rz(RAAN);      % Tierra -> plano orbital
                    C_orbita_plano = Rz(anom_ver(orb,t));           % plano orbital -> orbita
                    C_sat_orbita = Rx(roll(t,orb,vel)+(p-1)*pi/2);         % orbita -> sat
                    
                    C_sat_tierra = C_sat_orbita*C_orbita_plano*C_plano_tierra;
                    
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
    
    for orb = 1:length(h)                   % Bucle en alturas
        for vel = 1:length(w)               % Bucle en velocidades angulares
            Potencia_media_generada(orb,vel,b) = trapz(time(orb,:), P_m(:,1,orb,vel))/T(orb);
        end
    end
    
end

end

%% REPRESENTACION GRAFICA 

if calculo == 'n'
    load('Potencia_media_generada');
elseif calculo == 'y'
    save('Potencia_media_generada');
end

for vel = 1:length(w)               % Bucle en velocidades angulares
    h_plot = figure(fig);
        hold on
        pot(:,:) = Potencia_media_generada(:,vel,:);
        plot(days,pot(1,:),'-', 'LineWidth', 2, 'Color', 'k', 'DisplayName', ['h = ',num2str(h(1)),' km'])
        plot(days,pot(2,:),'--', 'LineWidth', 2, 'Color', 'k', 'DisplayName', ['h = ',num2str(h(2)),' km'])
        plot(days,pot(3,:),'-.', 'LineWidth', 2, 'Color', 'k', 'DisplayName', ['h = ',num2str(h(3)),' km'])
        legend('Interpreter', 'Latex', 'location', 'best')
        xlh = xlabel('Fecha','Interpreter','latex');
        xlh.Position(1) = xlh.Position(1) + abs(xlh.Position(1) * 0.75);
        ylh = ylabel({'$P_{media}$';'[W]'},'Interpreter','latex');
        ylh.Position(1) = ylh.Position(1) - abs(ylh.Position(1) * 0.4); %X
        ylh.Position(2) = ylh.Position(2) + abs(ylh.Position(2) * 0.15); %Y
        Save_as_PDF(h_plot, ['Figures/b_s',num2str(vel)],0);    % Save_as_PDF(h, 'Figuras/test',0)
        box on
        grid on
        hold off
        fig = fig+1;
end

%% MAXIMOS Y MINIMOS

for orb = 1:length(h)
    disp(['Potencias medias generadas para h = ',num2str(h(orb)), ' km'])    
    for vel = 1:length(w)               
        ppt(:) = Potencia_media_generada(orb,vel,:);
        
        [pk_max,loc_max] = findpeaks(ppt);
        
        [pk_min,loc_min] = findpeaks(-ppt);
        
        disp([' ','w =', num2str(w(vel)),' rad/s'])
        for i=1:length(pk_max)
            disp([' ','(',num2str(pk_max(i)),',',datestr(days(loc_max(i))),')'])
        end
        for i=1:length(pk_min)
            disp([' ','(',num2str(-pk_min(i)),',',datestr(days(loc_min(i))),')'])
        end
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