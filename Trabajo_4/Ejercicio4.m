clc;
clear all;
close all;

%% Datos

%% Primera parte

Tref = 20 + 273.15; %K
Gref = 1367;        %W/m^2
load('Datos_experimentales/Cells_Data.mat');
% e-2 va como un tiro, SI O NO, SI O NO? ESTAMOS? VALE? ESTAMOS O NO?
alpha_Voc = -6e-2;
alpha_Isc = 0.32e-2;
alpha_Vmp = -6.1e-2;
alpha_Imp = 0.28e-2;

% KyH
KyH = struct();
KyH.name = 'KyH';
KyH.parameters = [Cells.Isc Cells.Imp Cells.Vmp Cells.Voc];
KyH.Tref = Tref;
KyH.Gref = Gref;
KyH.a = Cells.a;

%1d2r
m_1d2r = struct();
m_1d2r.name = '1d2r';
m_1d2r.parameters = [Cells.Isc Cells.Imp Cells.Vmp Cells.Voc];
m_1d2r.Tref = Tref;
m_1d2r.a = Cells.a;
m_1d2r.Gref = Gref;

%% Segunda parte 

%Crear panel
SP = solar_panel();
SP.N_serie = Cells.N_serie;
SP.N_paralelo = Cells.N_paralelo;
SP.Modelo = KyH;
SP.Kelly_cosine_Limit = 75;
SP.alpha = [alpha_Isc, alpha_Imp, alpha_Vmp, alpha_Voc];

%Crear entorno
Env = entorno();
Env.T_max = 80+273.15;      %K
Env.T_min = -20+273.15;      %K
Env.Go = Gref;            %W/m2

% Crear satélite 
Sat = Satelite(SP,Env,35);
Sat.w = 0.052;
Sat.desfase_P = -pi/2;
Sat.desfase_T = Sat.w*15;

% Extraer la intensidad a lo largo del tiempo t
phi = 30;
t = linspace(0,200,1e3+1);
I = Sat.get_current(t);

figure()
hold on
    plot(t,I*1e3);
    plot(t,Env.T);
    plot(t,Env.G);
    xlabel('t');
    legend('I','T','G');
    grid on, box on


%% Hasta aquí va bien, solo hay que completar las funciones del panel para que saque la corriente
%% Luego los plots y hemos terminado



t = linspace(0,200,1e3+1);
w = 0.052; %rad/s
desfase_P = -pi/2;
cos_limit = 75;

incidencia = Inclinacion_Sol_Panel_ft(w, t, desfase_P, cos_limit);


% Temperatura
desfase_T = w*15;
T_max = 80;
T_min = -20;

temp = Temperatura_Panel_ft(w, t, desfase_P, desfase_T, T_max, T_min);


figure()
    hold on
    plot(rad2deg(w*t),incidencia)
    plot(rad2deg(w*t),temp)

figure()
    plot(rad2deg(w*t), incidencia)
    
figure()
    plot(t,I)



%% FUNCTIONS

function incidencia = Inclinacion_Sol_Panel_ft(w, t, desfase_P, cos_limit)

    [angulo, senal] = Normal_Sol_Panel(w, t, desfase_P);
    
    incidencia = senal.*Kelly_cos(angulo, cos_limit);

end

function temp = Temperatura_Panel_ft(w, t, desfase_P, desfase_T, T_max, T_min)


    [angulo, senal] = Normal_Sol_Panel(w, t, desfase_P-desfase_T);

    temp = (T_max+T_min)/2 + (T_max-T_min)/2*cos(angulo);

end


function [angulo, senal] = Normal_Sol_Panel(w, t, desfase)

    angulo = acos(cos(w*t + desfase));      %rad
    
    senal = ones(size(angulo));
    senal(angulo>pi/2) = 0;

end


function kcos = Kelly_cos(theta, cos_limit)

    cte = 90/cos_limit;
    limit = deg2rad(cos_limit);
    kcos = zeros(size(theta));
    
    kcos(theta >= 0 & theta < limit) = cos(theta(theta >= 0 & theta < limit)*cte);

end
