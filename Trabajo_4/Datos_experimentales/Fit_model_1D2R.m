%%%%%%%%%%%%%%%%%%%%%%%%% 1D2R %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
clc

load('Cells_Data.mat');
V_mess = Cells.V_mess;
I_mess = Cells.I_mess;

%% PUNTOS EXPERIMENTALES

% Datos
Vmp = Cells.Vmp;
Imp = Cells.Imp;
Isc = Cells.Isc;
Voc = Cells.Voc;

a = Cells.a; % 
n = Cells.N_serie; % 

kB = 1.380649e-23; %J K-1
qe = 1.6e-19; %C
T = 273.15 + 20; %K 
Vt = n*kB*T/qe;  % n número de células

% Parameter calculations

[Ipv,I0,Rs,Rsh] = param_1D_2R_Lap(Isc,Voc,Imp,Vmp,a, Vt);
umin = [Ipv,I0,Rs,Rsh,a];

% For ploting results

I_modelo_exp = zeros(size(V_mess,2),1)';
for i=1:size(V_mess,2)
    I_modelo_exp(i) = Panel_Current(umin,V_mess(i), Vt);
end

N = size(I_mess,2);
rmse = RMSE(Isc, I_mess, I_modelo_exp, N);

% h_ = figure();
% hold on
% plot(V_mess, I_modelo, '-', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
%     ["1D2R anal\'itico con puntos experimentales"])
% plot(V_mess, I_mess, '--', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
%     ["Puntos experimentales"])
% box on; grid on
% legend('Interpreter', 'Latex', 'location', 'NorthWest')
% xlabel('$V$ [V]','Interpreter','latex');
% ylabel({'$I$';'[A]'},'Interpreter','latex');
%                Save_as_PDF(h_, ['Figuras/1_An_dif_', sheet{s}],'horizontal', 7.5, 10);

%% PUNTOS CARACTERISTICOS DATA SHEET CELULA

% Datos
Isc_ref = Cells.Isc_ref;
Imp_ref = Cells.Imp_ref;
Vmp_ref = Cells.Vmp_ref;
Voc_ref = Cells.Voc_ref;

% Pasar de célula a panel 
Isc = Isc_ref * Cells.N_paralelo;
Imp = Imp_ref * Cells.N_paralelo;
Vmp = Vmp_ref * Cells.N_serie;
Voc = Voc_ref * Cells.N_serie;

% Parameter calculations

[Ipv,I0,Rs,Rsh] = param_1D_2R_Lap(Isc,Voc,Imp,Vmp,a, Vt);
umin = [Ipv,I0,Rs,Rsh,a];

% For ploting results

I_modelo_datasheet = zeros(size(V_mess,2),1)';
for i=1:size(V_mess,2)
    I_modelo_datasheet(i) = Panel_Current(umin,V_mess(i), Vt);
end

N = size(I_mess,2);
rmse = RMSE(Isc, I_mess, I_modelo_datasheet, N);

h_ = figure();
hold on
plot(V_mess, I_modelo_exp, '-', 'LineWidth', 2, 'Color', 'r','DisplayName', ...
    ["1D2R anal\'itico con puntos experimentales"])
plot(V_mess, I_modelo_datasheet, '-', 'LineWidth', 2, 'Color', 'b','DisplayName', ...
    ["1D2R anal\'itico data sheet"])
plot(V_mess, I_mess, '--', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
    ["1D2R experimental"])
box on; grid on
legend('Interpreter', 'Latex', 'location', 'NorthWest')
xlabel('$V$ [V]','Interpreter','latex');
ylabel({'$I$';'[A]'},'Interpreter','latex');
ylim([0 0.6])
%               Save_as_PDF(h_, ['Figuras/1_An_dif_', sheet{s}],'horizontal', 7.5, 10);