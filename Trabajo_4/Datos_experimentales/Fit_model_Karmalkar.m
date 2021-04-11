%%%%%%%%%% K A R M A L K A R   &   H A N E E F A %%%%%%%%%%%%%
clear all
close all
clc

load('Cells_Data.mat');
V_mess = Cells.V_mess;
I_mess = Cells.I_mess;

%% PUNTOS EXPERIMENTALES PANEL

% Datos
Vmp = Cells.Vmp;
Imp = Cells.Imp;
Isc = Cells.Isc; 
Voc = Cells.Voc;

puntos_x_datos = [0, Vmp, Voc];
puntos_y_datos = [Isc, Imp, 0];

% Parametros adimensionales
betha = Imp/Isc;
alpha = Vmp/Voc;

% Calculo 
K = (1-betha-alpha)/(2*betha-1);
aux = -(1/alpha)^(1/K)*(1/K)*log(alpha);
m = real((lambert(aux)/log(alpha))+(1/K)+1);
gamma = (2*betha-1)/((m-1)*alpha^m);

I_Karmalkar_analytic_exp = (1-(1-gamma)*(V_mess/Voc)-gamma*(V_mess/Voc).^m)*Isc;

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

% Parametros adimensionales
betha = Imp/Isc;
alpha = Vmp/Voc;

% Calculo 
K = (1-betha-alpha)/(2*betha-1);
aux = -(1/alpha)^(1/K)*(1/K)*log(alpha);
m = real((lambert(aux)/log(alpha))+(1/K)+1);
gamma = (2*betha-1)/((m-1)*alpha^m);

I_Karmalkar_analytic_datasheet = (1-(1-gamma)*(V_mess/Voc)-gamma*(V_mess/Voc).^m)*Isc;

%x = linspace(0,21.336,length(I_Karmalkar_analytic_datasheet));

%% FIGURAS ERROR

h_ = figure(1);
    hold on
    plot(V_mess, abs(I_Karmalkar_analytic_exp-I_mess), '-', 'LineWidth', 1, 'Color', 'k')
    box on; grid on
    xlabel('$V$ [V]','Interpreter','latex');
    ylabel({'$I-I_{exp}$';'[A]'},'Interpreter','latex');
    %Save_as_PDF(h_, ['Figuras/Error_KyH_exp'],'horizontal', 7.5, 10);

h_ = figure(2);
    hold on
    plot(V_mess, abs(I_Karmalkar_analytic_datasheet-I_mess), '-', 'LineWidth', 1, 'Color', 'k')
    box on; grid on
    xlabel('$V$ [V]','Interpreter','latex');
    ylabel({'$I-I_{exp}$';'[A]'},'Interpreter','latex');
    %Save_as_PDF(h_, ['Figuras/Error_KyH_datasheet'],'horizontal', 7.5, 10);


%% FIGURAS CURVAS
h_ = figure(3);
    hold on 
    plot(V_mess(1:25:end), I_mess(1:25:end), 'o', 'LineWidth', 0.5, 'MarkerSize', 5, 'Color', 'k','DisplayName', ...
        ["Datos experimentales"])
    plot(puntos_x_datos, puntos_y_datos, '^', 'Linewidth', 1,'Color', 'k', 'DisplayName', ["Puntos caracter\'isticos: datos experimentales"])
    plot(V_mess, I_Karmalkar_analytic_exp, '-', 'LineWidth', 1, 'Color', 'k','DisplayName', ...
        ["Karmalkar \& Haneefa: datos experimentales"])
    box on; grid on
    legend('Interpreter', 'Latex', 'location', 'SouthWest')
    xlabel('$V$ [V]','Interpreter','latex');
    ylabel({'$I$';'[A]'},'Interpreter','latex');
    ylim([0 0.6])
    %Save_as_PDF(h_, ['Figuras/KyH_datos'],'horizontal');
    
h_ = figure(4);
    hold on
    plot(V_mess(1:25:end), I_mess(1:25:end), 'o', 'LineWidth', 0.5, 'MarkerSize', 5, 'Color', 'k','DisplayName', ...
        ["Datos experimentales"])
    plot(puntos_x_sheet, puntos_y_sheet, '^', 'Linewidth', 1, 'Color', 'k', 'DisplayName', ["Puntos caracter\'isticos: $datasheet$"])
    plot(V_mess, I_Karmalkar_analytic_datasheet, '-', 'LineWidth', 1, 'Color', 'k','DisplayName', ...
        ["Karmalkar \& Haneefa: $datasheet$"])
    box on; grid on
    legend('Interpreter', 'Latex', 'location', 'SouthWest')
    xlabel('$V$ [V]','Interpreter','latex');
    ylabel({'$I$';'[A]'},'Interpreter','latex');
    ylim([0 0.6])
    %Save_as_PDF(h_, ['Figuras/KyH_sheet'],'horizontal');
    
h_ = figure(5);
    hold on
    plot(V_mess(1:25:end), I_mess(1:25:end), 'o', 'LineWidth', 0.5, 'MarkerSize', 5, 'Color', 'k','DisplayName', ...
        ["Datos experimentales"])
    plot(V_mess, I_Karmalkar_analytic_exp, '--', 'LineWidth', 1, 'Color', 'k','DisplayName', ...
        ["Karmalkar \& Haneefa: datos experimentales"])
    plot(V_mess, I_Karmalkar_analytic_datasheet, '-', 'LineWidth', 1, 'Color', 'k','DisplayName', ...
        ["Karmalkar \& Haneefa: $datasheet$"])
    box on; grid on
    legend('Interpreter', 'Latex', 'location', 'SouthWest')
    xlabel('$V$ [V]','Interpreter','latex');
    ylabel({'$I$';'[A]'},'Interpreter','latex');
    ylim([0 0.6])
    %Save_as_PDF(h_, ['Figuras/KyH_ambos'],'horizontal');