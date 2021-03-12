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

s = 7;

% Carga de valores experimentales
V_mess = xlsread('IV_curves.xlsx', string(sheet(s)), 'A21:A1202');
I_mess = xlsread('IV_curves.xlsx', string(sheet(s)), 'B21:B1202');
Isc = xlsread('IV_curves.xlsx', string(sheet(s)), 'B1');
Imp = xlsread('IV_curves.xlsx', string(sheet(s)), 'B2');
Vmp = xlsread('IV_curves.xlsx', string(sheet(s)), 'B3');
Voc = xlsread('IV_curves.xlsx', string(sheet(s)), 'B4');
betha = xlsread('IV_curves.xlsx', string(sheet(s)), 'B5'); % Imp/Isc
alpha = xlsread('IV_curves.xlsx', string(sheet(s)), 'B6'); % Vmp/Voc

%% Karmalkar & Haneefa’s model

K = (1-betha-alpha)/(2*betha-1);
aux = -(1/alpha)^(1/K)*(1/K)*log(alpha);
m = real((lambertw(-1,aux)/log(alpha))+(1/K)+1);
gamma = (2*betha-1)/((m-1)*alpha^m);

I_Karmalkar_analytic = (1-(1-gamma)*(V_mess/Voc)-gamma*(V_mess/Voc).^m)*Isc;

% Plot de valores experimentales y Karmalkar analytic
figure(1)
grid on
hold on
plot(V_mess, I_mess, 'linewidth', 2)
plot(V_mess, I_Karmalkar_analytic, 'linewidth', 2)
plot([0 Vmp Voc], [Isc Imp 0], 'o', 'MarkerSize', 10)
xlabel('Voltage [V]')
ylabel('Current [A]')
legend('Experimental', 'Karmalkar Analytic')
title(string(sheet(s)))

%% Das' model

aux2 = betha*log(alpha);
k_Das = lambertw(-1,aux2)/log(alpha);
h = (1/alpha)*((1/betha)-1/k_Das-1);

I_Das_analytic = ((1-(V_mess/Voc).^k_Das)/(1+h*(V_mess/Voc)))*Isc;

% Plot de valores experimentales y Das analytic
figure(2)
grid on
hold on
plot(V_mess, I_mess, 'linewidth', 2)
plot(V_mess, I_Das_analytic, 'linewidth', 2)
plot([0 Vmp Voc], [Isc Imp 0], 'o', 'MarkerSize', 10)
xlabel('Voltage [V]')
ylabel('Current [A]')
legend('Experimental', 'Das Analytic')
title(string(sheet(s)))