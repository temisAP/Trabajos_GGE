clc;
clear all;
close all;

%% Datos

%% Primera parte
% Sacar los parámetros de los modelos KyH y 1d2r (analíticos) para 
% caracterizar los paneles.
T = 20 + 273.15; %K

%% Segunda parte 

N_serie = 6;
N_paralelo = 3;

%Crear panel
SP = solar_panel(N_serie, N_paralelo);
SP.Modelo = 'KyH';
SP.Parametros = [0.1, 1, 0.1, 10];
SP.Kelly_cosine_Limit = deg2rad(70);

%Crear entorno
Env = entorno();
Env.w = 0.052; %rad/s
Env.desfase_P = -pi/2;
Env.desfase_T = Env.w*15;
Env.T_max = 80;
Env.T_min = 20;

% Crear satélite 
Sat = Satelite(SP,Env,200);

% Extraer la intensidad a lo largo del tiempo t
phi = 30;
t = linspace(0,200,1e4+1);
I = Sat.get_current(t,phi);


%% Hasta aquí va bien, solo hay que completar las funciones del panel para que saque la corriente
%% Luego los plots y hemos terminado



t = linspace(0,200,1e4+1);
w = 0.052; %rad/s

incidencia = Inclinacion_Sol_Panel_ft(w, t);


% Temperatura
desfase_T = w*15;
T_max = 80;
T_min = -20;

temp = Temperatura_Panel_ft(w, t, desfase_T, T_max, T_min);


figure()
    hold on
    plot(rad2deg(w*t),incidencia)
    plot(rad2deg(w*t),temp)

incidencia = Inclinacion_Sol_Panel_ft(w, t);

figure()
    plot(rad2deg(w*t), incidencia)



%% FUNCTIONS

function incidencia = Inclinacion_Sol_Panel_ft(w, t)

    desfase = -pi/2;
    [angulo, senal] = Normal_Sol_Panel(w, t, desfase);
    
    incidencia = senal.*Kelly_cos(angulo);

end

function temp = Temperatura_Panel_ft(w, t, desfase_T, T_max, T_min)

    desfase_P = -pi/2;
    [angulo, senal] = Normal_Sol_Panel(w, t, desfase_P-desfase_T);

    temp = (T_max+T_min)/2 + (T_max-T_min)/2*cos(angulo);

end


function [angulo, senal] = Normal_Sol_Panel(w, t, desfase)

    angulo = acos(cos(w*t(:) + desfase));      %rad
    
    senal = ones(size(angulo));
    senal(angulo>pi/2) = 0;

end


function kcos = Kelly_cos(theta)

    cte = 90/75;
    limit = deg2rad(75);
    kcos = zeros(size(theta));
    
    kcos(theta >= 0 & theta < limit) = cos(theta(theta >= 0 & theta < limit)*cte);

end

