%% Programa para guardar los valores del excel

clc
clear all
close all


%% DATOS EXPERIMENTALES
read_sheet = {'panel_satélite'};
read_filename = 'data.xlsx';

Cells = struct();

for s = 1:length(read_sheet)
    Cells(s).Name = read_sheet{s};
    Cells(s).V_mess = xlsread(read_filename, read_sheet{s}, 'A2:A1183')';
    Cells(s).I_mess = xlsread(read_filename, read_sheet{s}, 'B2:B1183')';
end

% Carga de valores experimentales
V_mess = Cells(s).V_mess;
I_mess = Cells(s).I_mess;
P_mess = V_mess.*I_mess;

% Plot V_I & V_P
figure(1)
hold on
plot(V_mess, P_mess, 'LineWidth', 2)
plot(V_mess, I_mess, 'LineWidth', 2)
box on; grid on
legend('Interpreter', 'Latex', 'location', 'SouthWest')
xlabel('$V$ [V]','Interpreter','latex');
ylabel({'$I$';'[A]'},'Interpreter','latex');
%Save_as_PDF(h_, ['Figuras/1_Nu_', sheet{s}],'horizontal',1);
hold off


%% CÁLCULO PUNTO MÁXIMA POTENCIA
% Encontrar posición V_mp
valV = V_mess(V_mess >= 16 &  V_mess <= 18);
posV = find(V_mess >= 16 &  V_mess <= 18);
valP = P_mess(posV);
[fit1, bondad] = fit(valV', valP', 'poly4');
coeff = coeffvalues(fit1);

x = linspace(16, 18, 100);

for i = 1:length(x)
    P(i) = coeff(1)*x(i)^4 + coeff(2)*x(i)^3 + coeff(3)*x(i)^2 + coeff(4)*x(i) + coeff(5);
end

[P_mp, pos_max] = max(P);
V_mp = x(pos_max);

% Encontrar posición I_mp
valI = I_mess(posV);
[fit2, bondad2] = fit(valV', valI', 'poly3');
coeff2 = coeffvalues(fit2);

I_mp = coeff2(1)*V_mp^3 + coeff2(2)*V_mp^2 + coeff2(3)*V_mp + coeff2(4);

%% CÁLCULO I_sc
valV = V_mess(V_mess >= 0 &  V_mess <= 7.5);
posV = find(V_mess >= 0 &  V_mess <= 7.5);
valI = I_mess(posV);

[fit3, bondad3] = fit(valV', valI', 'poly1');
coeff3 = coeffvalues(fit3);
Isc = coeff3(2);

%% CÁLCULO V_oc
valV = V_mess(V_mess >= 18 &  V_mess <= V_mess(end));
posV = find(V_mess >= 18 &  V_mess <= V_mess(end));
valI = I_mess(posV);

[fit4, bondad4] = fit(valV', valI', 'poly2');
coeff4 = coeffvalues(fit4);
roots = roots(coeff4');
V_oc = roots(1);

%%

Cells.Isc = Isc;
Cells.Imp = I_mp;
Cells.Vmp = V_mp;
Cells.Voc = V_oc;

V_oc_ref = 2667e-3;
Isc_ref = 

Cells.N_serie = 0;
Cells.N_paralelo = 0;
Cells.a = 0;

%save('Cells_Data.mat', 'Cells')