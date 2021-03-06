%%%%%%%%%%%%%%%%%%%%%%%%% 1D2R %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
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

puntos_x_datos = [0, Vmp, Voc];
puntos_y_datos = [Isc, Imp, 0];

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

puntos_x_sheet = [0, Vmp, Voc];
puntos_y_sheet = [Isc, Imp, 0];

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

%% FIGURAS ERROR

h_ = figure(1);
hold on
plot(V_mess, abs(I_modelo_exp-I_mess), '-', 'LineWidth', 1, 'Color', 'k')
box on; grid on
xlabel('$V$ [V]','Interpreter','latex');
ylabel({'$I-I_{exp}$';'[A]'},'Interpreter','latex');
%Save_as_PDF(h_, ['Figuras/Error_1d2r_exp'],'horizontal', 7.5, 10);

h_ = figure(2);
hold on
plot(V_mess, abs(I_modelo_datasheet-I_mess), '-', 'LineWidth', 1, 'Color', 'k')
box on; grid on
xlabel('$V$ [V]','Interpreter','latex');
ylabel({'$I-I_{exp}$';'[A]'},'Interpreter','latex');
%Save_as_PDF(h_, ['Figuras/Error_1d2r_datasheet'],'horizontal', 7.5, 10);


%% FIGURAS CURVAS
h_ = figure(3);
    hold on 
    plot(V_mess(1:25:end), I_mess(1:25:end), 'o', 'LineWidth', 0.5, 'MarkerSize', 5, 'Color', 'k','DisplayName', ...
        ["Datos experimentales"])
    plot(puntos_x_datos, puntos_y_datos, '^', 'Linewidth', 1,'Color', 'k', 'DisplayName', ["Puntos caracter\'isticos: datos experimentales"])
    plot(V_mess, I_modelo_exp, '-', 'LineWidth', 1, 'Color', 'k','DisplayName', ...
        ["1D2R: datos experimentales"])
    box on; grid on
    legend('Interpreter', 'Latex', 'location', 'SouthWest')
    xlabel('$V$ [V]','Interpreter','latex');
    ylabel({'$I$';'[A]'},'Interpreter','latex');
    ylim([0 0.6])
    %Save_as_PDF(h_, ['Figuras/1d2r_datos'],'horizontal');
    
h_ = figure(4);
    hold on
    plot(V_mess(1:25:end), I_mess(1:25:end), 'o', 'LineWidth', 0.5, 'MarkerSize', 5, 'Color', 'k','DisplayName', ...
        ["Datos experimentales"])
    plot(puntos_x_sheet, puntos_y_sheet, '^', 'Linewidth', 1, 'Color', 'k', 'DisplayName', ["Puntos caracter\'isticos: $datasheet$"])
    plot(V_mess, I_modelo_datasheet, '-', 'LineWidth', 1, 'Color', 'k','DisplayName', ...
        ["1D2R: $datasheet$"])
    box on; grid on
    legend('Interpreter', 'Latex', 'location', 'SouthWest')
    xlabel('$V$ [V]','Interpreter','latex');
    ylabel({'$I$';'[A]'},'Interpreter','latex');
    ylim([0 0.6])
    %Save_as_PDF(h_, ['Figuras/1d2r_sheet'],'horizontal');
    
h_ = figure(5);
    hold on
    plot(V_mess(1:25:end), I_mess(1:25:end), 'o', 'LineWidth', 0.5, 'MarkerSize', 5, 'Color', 'k','DisplayName', ...
        ["Datos experimentales"])
    plot(V_mess, I_modelo_exp, '--', 'LineWidth', 1, 'Color', 'k','DisplayName', ...
        ["1D2R: datos experimentales"])
    plot(V_mess, I_modelo_datasheet, '-', 'LineWidth', 1, 'Color', 'k','DisplayName', ...
        ["1D2R: $datasheet$"])
    box on; grid on
    legend('Interpreter', 'Latex', 'location', 'SouthWest')
    xlabel('$V$ [V]','Interpreter','latex');
    ylabel({'$I$';'[A]'},'Interpreter','latex');
    ylim([0 0.6])
    %Save_as_PDF(h_, ['Figuras/1d2r_ambos'],'horizontal');