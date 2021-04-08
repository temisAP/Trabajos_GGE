%%%%%%%%%% K A R M A L K A R   &   H A N E E F A %%%%%%%%%%%%%
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

% Parametros adimensionales
betha = Imp/Isc;
alpha = Vmp/Voc;

% Calculo 
K = (1-betha-alpha)/(2*betha-1);
aux = -(1/alpha)^(1/K)*(1/K)*log(alpha);
m = real((lambert(aux)/log(alpha))+(1/K)+1);
gamma = (2*betha-1)/((m-1)*alpha^m);

I_Karmalkar_analytic_exp = (1-(1-gamma)*(V_mess/Voc)-gamma*(V_mess/Voc).^m)*Isc;

h_ = figure();
hold on
plot(V_mess, I_Karmalkar_analytic_exp, '-', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
    ["Karmalkar \& Haneefa anal\'itico con puntos experimentales"])
plot(V_mess, I_mess, '--', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
    ["Karmalkar \& Haneefa experimental"])
box on; grid on
legend('Interpreter', 'Latex', 'location', 'NorthWest')
xlabel('$V$ [V]','Interpreter','latex');
ylabel({'$I$';'[A]'},'Interpreter','latex');
%                Save_as_PDF(h_, ['Figuras/1_An_dif_', sheet{s}],'horizontal', 7.5, 10);

%% PUNTOS CARACTERISTICOS DATA SHEET

% Datos
Isc = 0.506;
Imp = 0.487;
Vmp = 2.371;
Voc = 2.667;

% Parametros adimensionales
betha = Imp/Isc;
alpha = Vmp/Voc;

% Calculo 
K = (1-betha-alpha)/(2*betha-1);
aux = -(1/alpha)^(1/K)*(1/K)*log(alpha);
m = real((lambert(aux)/log(alpha))+(1/K)+1);
gamma = (2*betha-1)/((m-1)*alpha^m);

I_Karmalkar_analytic_datasheet = (1-(1-gamma)*(V_mess/Voc)-gamma*(V_mess/Voc).^m)*Isc;

% h_ = figure();
% hold on
% plot(V_mess, I_Karmalkar_analytic_datasheet, '-.', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
%     ["Karmalkar \& Haneefa anal\'itico"])
% plot(V_mess, I_mess, '--', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
%     ["Karmalkar \& Haneefa experimental"])
% box on; grid on
% legend('Interpreter', 'Latex', 'location', 'NorthWest')
% xlabel('$V$ [V]','Interpreter','latex');
% ylabel({'$I$';'[A]'},'Interpreter','latex');
%                Save_as_PDF(h_, ['Figuras/1_An_dif_', sheet{s}],'horizontal', 7.5, 10);