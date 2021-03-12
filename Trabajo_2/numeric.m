clear all;
close all;
clc;

% Constantes
%k = 1.3806503e-23;  % [J/k] Stefan Boltzman
q = 1.60217646e-19; % [C] Carga del electrón

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

s = 2;

% Carga de valores experimentales
V_mess = xlsread('IV_curves.xlsx', string(sheet(s)), 'A21:A1202');
I_mess = xlsread('IV_curves.xlsx', string(sheet(s)), 'B21:B1202');

% Carga de datos del fabricante
Isc = xlsread('IV_curves.xlsx', string(sheet(s)), 'B1');
Imp = xlsread('IV_curves.xlsx', string(sheet(s)), 'B2');
Vmp = xlsread('IV_curves.xlsx', string(sheet(s)), 'B3');
Voc = xlsread('IV_curves.xlsx', string(sheet(s)), 'B4');
betha = xlsread('IV_curves.xlsx', string(sheet(s)), 'B5');
alpha = xlsread('IV_curves.xlsx', string(sheet(s)), 'B6');


% Plot de valores experimentales
figure()
grid on
hold on
plot(V_mess, I_mess, 'linewidth', 2)
plot([0 Vmp Voc], [Isc Imp 0], 'o', 'MarkerSize', 10)
xlabel('Voltage [V]')
ylabel('Current [A]')
title(string(sheet(s)))

%% Karmalkar & Haneefa numérico

v_mess = V_mess/Voc;
i_mess = I_mess/Isc;

beta0 = [1 1];

for i = 1:5
    Kalmarkar_fun = @(p,v) 1-(1-p(1))*v - p(1)*v.^p(2);
    
    mdl = fitnlm(v_mess, i_mess, Kalmarkar_fun, beta0);
    
    gamma(i) = table2array(mdl.Coefficients(1,1));
    m(i) = table2array(mdl.Coefficients(2,1));
    Error(i) = mdl.RMSE;
    
    beta0 =[gamma(i) m(i)];
    
end

I_Ksol = (1-(1-gamma(end))*v_mess - gamma(end)*v_mess.^m(end))*Isc;

figure()
grid on
hold on
plot(V_mess, I_mess, 'linewidth', 2)
plot(V_mess, I_Ksol, 'linewidth', 2)
xlabel('Voltage [V]')
ylabel('Current [A]')

%% Das numérico

beta0 = [1.5 1.5];

for i = 1:5
    Das_fun = @(p,v) (1-v.^p(1))./(1+p(2)*v);
    
    mdl_2 = fitnlm(v_mess, i_mess, Das_fun, beta0);
    
    k(i) = table2array(mdl_2.Coefficients(1,1));
    h(i) = table2array(mdl_2.Coefficients(2,1));
    Error_2(i) = mdl_2.RMSE;
    
    beta0 =[k(i) h(i)];
    
end

I_Dsol = (1-v_mess.^k(end))./(1+h(end)*v_mess)*Isc;

figure()
grid on
hold on
plot(V_mess, I_mess, 'linewidth', 2)
plot(V_mess, I_Dsol, 'linewidth', 2)
xlabel('Voltage [V]')
ylabel('Current [A]')

%%

