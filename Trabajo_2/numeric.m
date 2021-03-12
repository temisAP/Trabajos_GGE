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

s = 3;

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
title('Valores experimentales')

%% Karmalkar & Haneefa numérico

v_mess = V_mess/Voc;
i_mess = I_mess/Isc;

beta0 = [1 1];

for i = 1:5
    Kalmarkar_fun = @(p,v) 1-(1-p(1))*v - p(1)*v.^p(2);
    
    mdl_K = fitnlm(v_mess, i_mess, Kalmarkar_fun, beta0);
    
    gamma(i) = table2array(mdl_K.Coefficients(1,1));
    m(i) = table2array(mdl_K.Coefficients(2,1));
    Error_K(i) = mdl_K.RMSE;
    
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
title('Valores experimentales vs Karmalkar & Haneefa')

%% Das numérico

beta0 = [1.5 1.5];

for i = 1:5
    Das_fun = @(p,v) (1-v.^p(1))./(1+p(2)*v);
    
    mdl_D = fitnlm(v_mess, i_mess, Das_fun, beta0);
    
    k(i) = table2array(mdl_D.Coefficients(1,1));
    h(i) = table2array(mdl_D.Coefficients(2,1));
    Error_D(i) = mdl_D.RMSE;
    
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
title('Valores experimentales vs Das')

%% Pindado & Cubas numérico

beta0 = 1;

% Al ser una función definida a trozos, se define el vector V_mess_PC el
% cual contiene únicamente valores de V >= Vmp
V_mess_tramo1 = V_mess(V_mess <= Vmp);
V_mess_tramo2 = V_mess(V_mess >= Vmp);
I_mess_tramo2 = I_mess((length(V_mess) - length(V_mess_tramo2) + 1):end);

for i = 1:5
    
    PC_fun = @(p,V) Imp*(Vmp./V).*(1-((V-Vmp)/(Voc-Vmp)).^p);
    
    mdl_PC = fitnlm(V_mess_tramo2, I_mess_tramo2, PC_fun, beta0);
    
    eta(i) = table2array(mdl_PC.Coefficients(1,1));
    Error_PC(i) = mdl_PC.RMSE;
    
    beta0 =eta(i);
    
end

I_tramo1 = Isc*(1-(1-Imp/Isc)*(V_mess_tramo1/Vmp).^(Imp/(Isc-Imp)));
I_tramo2 = Imp*(Vmp./V_mess_tramo2).*(1-((V_mess_tramo2-Vmp)/(Voc-Vmp)).^eta(end));

I_PCsol = [I_tramo1' I_tramo2'];

figure()
grid on
hold on
plot(V_mess, I_mess, 'linewidth', 2)
plot(V_mess, I_PCsol, 'linewidth', 2)
xlabel('Voltage [V]')
ylabel('Current [A]')
title('Valores experimentales vs Pindado & Cubas')



