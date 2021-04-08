clc;
clear all;
close all;

%% Datos

%% Primera parte

Tref = 20 + 273.15; %K
Gref = 1367;        %W/m^2
load('Datos_experimentales/Cells_Data.mat');

alpha_Voc = -6e-3;
alpha_Isc = 0.32e-3;
alpha_Vmp = -6.1e-3;
alpha_Imp = 0.28e-3;

% KyH
KyH = struct();
KyH.name = 'KyH';
KyH.parameters = [Cells.Isc Cells.Imp Cells.Vmp Cells.Voc];
KyH.Tref = Tref;
KyH.Gref = Gref;

%1d2r
m_1d2r = struct();
m_1d2r.name = '1d2r';
m_1d2r.parameters = [Cells.Isc Cells.Imp Cells.Vmp Cells.Voc];
m_1d2r.Tref = Tref;
m_1d2r.a = 1.5;
m_1d2r.Gref = Gref;

%% Segunda parte 

N_serie = 6;
N_paralelo = 6;

%Crear panel
SP = solar_panel(N_serie, N_paralelo);
SP.Modelo = m_1d2r;
SP.Kelly_cosine_Limit = deg2rad(70);
SP.alpha = [alpha_Isc, alpha_Imp, alpha_Vmp, alpha_Voc]

%Crear entorno
Env = entorno();
Env.w = 0.052;              %rad/s
Env.desfase_P = -pi/2;      %rad
Env.desfase_T = Env.w*15;   %rad
Env.T_max = 80+273.15;      %K
Env.T_min = 20+273.15;      %K

% Crear satélite 
Sat = Satelite(SP,Env,200);

% Extraer la intensidad a lo largo del tiempo t
phi = 30;
t = linspace(0,200,1e2+1);
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

