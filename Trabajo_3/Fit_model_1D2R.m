%%Fit model 1D2R
%%%%% Matriz de puntos caracteristicos de cada IV curve 
clear all
clc

% Nombre de las hojas del archivo excel
sheet = {'RTC France', 'TNJ', 'ZTJ', '3G30C','PWP201', 'KC200GT2', 'SPVSX5', 'PSC'};

% Selección de hoja (s)
% 1 ---> RTC France
% 2 ---> TNJ
% 3 ---> ZTJ
% 4 ---> 3G30C
% 5 ---> PWP201
% 6 ---> KC200GT2
% 7 ---> SPVSX5
% 8 ---> PSC

s = 3;

% Carga de valores experimentales
V_mess = xlsread('IV_curves.xlsx', string(sheet(s)), 'A21:A1202');
I_mess = xlsread('IV_curves.xlsx', string(sheet(s)), 'B21:B1202');
Isc = xlsread('IV_curves.xlsx', string(sheet(s)), 'B1');
Imp = xlsread('IV_curves.xlsx', string(sheet(s)), 'B2');
Vmp = xlsread('IV_curves.xlsx', string(sheet(s)), 'B3');
Voc = xlsread('IV_curves.xlsx', string(sheet(s)), 'B4');
betha = xlsread('IV_curves.xlsx', string(sheet(s)), 'B5'); % Imp/Isc
alpha = xlsread('IV_curves.xlsx', string(sheet(s)), 'B6'); % Vmp/Voc

%% Modelo analítico 2R2D


kB = 1.380649e-23; %J K-1
qe = 1.6e-19; %C
T = 288.15; %K
Vt = 3*kB*T/qe;

V_mess = V_mess';
I_mess = I_mess';


%Cálculo de paramétro Referencia: 2015_MPE

%Calculo pendiente:

Rsh0 = -(I_mess(1,2)-I_mess(1,1))/(V_mess(1,2)-V_mess(1,1));
Rs0 = -(I_mess(1,end)-I_mess(1,end-1))/(V_mess(1,end)-V_mess(1,end-1));

%% Paso1 Estimar el parámetro a2
a2 = 2;

% A1 = Rsh0*(Isc-Imp)-Vmp-a2*Vt*((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs));
% A2 = (Rsh0*Isc-Voc)-a2*Vt((Rsh0-Rs0)/(Rs0-Rs));
% A3 = (Vmp+Imp*Rs-Voc)*(((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs))-((Rsh0-Rs0)/(Rs0-Rs))*exp((Vmp+Imp*Rs-Voc)/(a2*Vt)));
% A4 = (Rsh0*(Isc-Imp)-Vmp)-(Rsh0*Isc-Voc)*exp((Vmp+Imp*Rs-Voc)/(a2*Vt));

%% Paso2 despejar Rs

Rs_guess =0.08;
Rs_sol = fzero(@(Rs) log((Rsh0*(Isc-Imp)-Vmp-a2*Vt*((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs)))/((Rsh0*Isc-Voc)-a2*Vt((Rsh0-Rs0)/(Rs0-Rs)))) ...
                      -(Vmp+Imp*Rs-Voc)*(((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs))-(((Rsh0-Rs0)/(Rs0-Rs))*exp((Vmp+Imp*Rs-Voc)/(a2*Vt))))/...
                      ((Rsh0*(Isc-Imp)-Vmp)-(Rsh0*Isc-Voc)*exp((Vmp+Imp*Rs-Voc)/(a2*Vt))),Rs_guess);
% syms Rs Rsh0 Rs0 Isc Voc Imp Vmp a2 Vt
% eqn = (log((Rsh0*(Isc-Imp)-Vmp-a2*Vt*((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs)))/((Rsh0*Isc-Voc)-a2*Vt((Rsh0-Rs0)/(Rs0-Rs)))) ...
%                        -(Vmp+Imp*Rs-Voc)*(((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs))-(((Rsh0-Rs0)/(Rs0-Rs))*exp((Vmp+Imp*Rs-Voc)/(a2*Vt))))/...
%                        ((Rsh0*(Isc-Imp)-Vmp)-(Rsh0*Isc-Voc)*exp((Vmp+Imp*Rs-Voc)/(a2*Vt)))) == 0;
% solve(eqn,Rs)
Rs=0.0802;
%% Paso 3 Obtener el parámetro a1

B1 = ((Rsh0*(Isc-Imp)-Vmp)-(Rsh0*Isc-Voc)*exp((Vmp + Imp*Rs-Voc)/(a2*Vt)));
B2 = ((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs)-((Rsh0-Rs0)/(Rs0-Rs))*exp((Vmp+Imp*Rs-Voc)/(a2*Vt)))^(-1);
a1Vt = B1*B2;
a1 = a1Vt/Vt;
a1=0.9980;
%% Paso 4 obtener I_01

I_01 = a1/(a1-a2)*exp(-Voc/(a1*Vt))*(a2*Vt*(Rsh0-Rs0)-(Rs0-Rs)*(Rsh0*Isc-Voc))/((Rsh0-Rs)*(Rs0-Rs));
I_01=2.4409*10^-16;

%% Paso 5 obtener I_02

I_02 = a2/(a1-a2)*exp(-Voc/(a2*Vt))*(a1*Vt*(Rsh0-Rs0)-(Rs0-Rs)*(Rsh0*Isc-Voc))/((Rsh0-Rs)*(Rs0-Rs));
I_02=8.4461*10^-10;

%% Paso 6 Obtener Rsh

Rsh = Rsh0-Rs;
Rsh=343.5357;

%% Paso 7 Obtener Ipv

Ipv = (Rsh+Rs)/Rsh*Isc;
Ipv=0.4629;

%% MODELO 2D2R
 I_modelo = zeros(size(V_mess,2),1)';
for i=1:size(V_mess,2)
	I_modelo(i) = fzero(@(I) Ipv - I_01*(exp((V_mess(1,i)+I*Rs)/(a1*Vt))-1) - I_02*(exp((V_mess(1,i)+I*Rs)/(a2*Vt))-1) - (V_mess(1,i)+I*Rs)/Rsh - I, 0);
end
error = (sum((I_modelo - I_mess).^2))^0.5;

% I_modelo = fzero(@(I)Ipv - I_01*(exp((V+I*Rs)/(a1*Vt))-1) - I_02*(exp((V+I*Rs)/(a2*Vt))-1) - (V+I*Rs)/Rsh - I, 0);


figure(2)
grid on
hold on
plot(V_mess, I_mess, 'linewidth', 2)
plot(V_mess, I_modelo, 'linewidth', 2)
plot([0 Vmp Voc], [Isc Imp 0], 'o', 'MarkerSize', 10)
xlabel('Voltage [V]')
ylabel('Current [A]')
legend('Experimental', 'Das Analytic')
title(string(sheet(s)))