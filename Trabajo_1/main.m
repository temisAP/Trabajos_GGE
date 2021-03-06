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
RAAN = deg2rad(25);
inc = 0;



%% PERIODO ORBITAL Y ANGULOS EN FUNCION DEL TIEMPO

% Periodo de orbitas
T = 2*pi*sqrt(r.^3/mu);                 % s
anom_ver_punto = 1./sqrt(r.^3/mu);      % Velocidad angular anomalia verdadera


for i = 1:3
    time(i,:) = linspace(0,T(i),1e5+1);            % Vector de tiempos 1 periodo
    anom_ver(i,:) = time(i,:)*anom_ver_punto(i);   % Anomalia verdadera
    for j = 1:3
        roll(:,i,j) = time(i,:)*w(j);              % Rotacion sat sobre su eje Z
    end
end

% Cambios de base
Reo = Rz(RAAN)*Rx(inc);         % Tierra - Orbita -> angulo con sol + inclinacion




%% ECLIPSE

% Angulo 
rho = asin(rT./(rT + h));
beta_s = pi/2 - acos([1,0,0]*Reo*[1,0,0]');
phi = real(2*acos(cos(rho)/cos(beta_s)));

% Vector señal eclipse 1-0
eclipse = ones(size(anom_ver));
if phi ~= [0, 0, 0]
    disp('Eclipse')
    for i = 1:3
        eclipse(i, anom_ver(i,:) >= (pi - phi(i)/2) & anom_ver(i,:) < (pi + phi(i)/2) ) = 0;
    end
else
    disp('No hay eclipse')
end

figure()
    hold on
    plot(eclipse(1,:),'DisplayName','450 km')
    plot(eclipse(2,:),'DisplayName','500 km')
    plot(eclipse(3,:),'DisplayName','600 km')
    legend()
    title('Eclipse')


    
%% ANGULO PANELES

for orb = 1:length(h)       % Bucle en alturas
    
    for vel = 1:length(w)   % Bucle en velocidades angulares
        
        for p = 1:4         % Bucle en paneles
            
            [angulo_panel(:,orb,vel,p), senal_panel(:,orb,vel,p)] = ...
                panel(w(vel), time(orb,:), (p-1)*pi/2);
            
        end
        
    end
    
end

figure()
    hold on
    for p = 1:1
        %plot(time(1,:), cos(angulo_panel(:,1,1,p)).*senal_panel(:,1,1,p),...
        %     'DisplayName',['Panel ' num2str(p)])
        plot(time(1,:), cos(angulo_panel(:,1,1,p)),'DisplayName',['Panel ' num2str(p)])
         plot(time(1,:), senal_panel(:,1,1,p),'DisplayName',['Señal Panel ' num2str(p)])
        % plot(t(1,:), cos_panel(i,:).*( cos(anom_ver(1,:)*2 + pi) + 1 )/2)
    end
    legend()
    title('cos(angulo panel)')



%% SIMULACION

for orb = 1%:length(h)                   % Bucle en alturas
    
    for vel = 1%:length(w)               % Bucle en velocidades angulares
        
        for t = 1:length(time(orb,:))   % Bucle en tiempo
            
            senal = eclipse(orb,t);
            Ros = Rz(anom_ver(orb,t));          % Orbita - Sat
            %bsat(t,orb,vel) = [1 0 0]*Ros*[1 0 0]'*senal;
            %bsat(t,orb,vel) = (-([1 0 0]*Ros*[1 0 0]'+1)/2 + 1)*senal;
            %bsat = (-([1 0 0]*Ros+1)/2 + 1)*senal;
            Rsp = Rx(angulo_panel(t,orb,vel,1));    % Sat - paneles
            %bpan(t,orb,vel) = [0 -1 0]*Rsp*[1 0 0]';
            %bpan(t,orb,vel) = bsat*Rsp*[0 -1 0]';
            senal = eclipse(orb,t)*senal_panel(t,orb,vel,1);
            test(t) = abs([1 0 0]*Ros*Rsp*[0 -1 0]'*senal);
            
        end
        
    end
    
end

% Plot test
figure()
    hold on
%    plot(bsat(:,1,1))
%    plot(bpan(:,1,1))
    plot(anom_ver(1,:),test)



%% Potencia
Wo = 1361;              % W


%% CAMBIOS DE BASE
%{
RAAN = 0;
inc = 0;

Reo = Rz(RAAN)*Rx(inc);             % Tierra - Orbita -> angulo con sol + inclinacion
Ros = Rz(anom_ver);                 % Orbita - Sat -> ejes giran con anomalia verdadera
Rsp = Ry(pi/2)*Rz(angulo_panel);    % Sat - paneles -> rotado 90 en y para que 
                                    % coincida el eje Z con la direccion 3U
                                    % Rota en funcion del tiempo sobre Z
 
%}

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