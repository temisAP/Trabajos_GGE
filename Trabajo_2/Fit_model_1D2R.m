%% Fit model 1D2R

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

%% Modelo 1D2R

kB = 1.380649e-23; %J K-1
qe = 1.6e-19; %C
T = 288.15; %K
Vt = kB*T/qe;

V_mess = V_mess';
I_mess = I_mess';

% Minimize Least squares
[umin,fval]=fminsearch(@(u)RECT(u,V_mess,I_mess),[1,1e-8,1,10,1]);

% Results: parameters of equivalent circuit

Ipv=umin(1);
I0=umin(2);
Rs=umin(3);
Rsh=umin(4);
a=umin(5);

% plot results

I_modelo = zeros(size(V_mess,2),1)';
for i=1:size(V,2)
    I_modelo(i) = Panel_Current(umin,V_mess(i));
end

figure (1)
plot (V_mess,I_exp, 'o');
hold on
plot (V_mess,I_modelo,'k');

function I_modelo = Panel_Current(u, V_mesh)
global Vt

%Ipv=u(1); I0=u(2); Rs=u(3); Rsh=u(4); a=u(5);

I_modelo =fzero(@(I) u(1)-u(2)*(exp((V_mesh+u(3)*I)/(Vt*u(5)))-1)-(V_mesh+u(3)*I)/u(4)-I, 0);
end

function error = RECT(u, V_mesh, I_exp)

for i=1:size(V_mesh,2)
    I_modelo(i) = Panel_Current(u,V_mesh(i));
end
error = (sum((I_modelo - I_exp).^2))^0.5;

end
