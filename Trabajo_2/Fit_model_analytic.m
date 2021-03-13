%%%%% Matriz de puntos caracteristicos de cada IV curve 
clear all
clc
close all

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

%s = 7;
% Bucle para acceder a cada hoja del excel
for s = 1:8

    % Carga de valores experimentales
    V_mess = xlsread('IV_curves.xlsx', sheet{s}, 'A21:A1202');
    I_mess = xlsread('IV_curves.xlsx', sheet{s}, 'B21:B1202');
    Isc = xlsread('IV_curves.xlsx', sheet{s}, 'B1');
    Imp = xlsread('IV_curves.xlsx', sheet{s}, 'B2');
    Vmp = xlsread('IV_curves.xlsx', sheet{s}, 'B3');
    Voc = xlsread('IV_curves.xlsx', sheet{s}, 'B4');
    betha = xlsread('IV_curves.xlsx', sheet{s}, 'B5'); % Imp/Isc
    alpha = xlsread('IV_curves.xlsx', sheet{s}, 'B6'); % Vmp/Voc



    %% Karmalkar & Haneefa’s model

    K = (1-betha-alpha)/(2*betha-1);
    aux = -(1/alpha)^(1/K)*(1/K)*log(alpha);
    m = real((lambertw(-1,aux)/log(alpha))+(1/K)+1);
    gamma = (2*betha-1)/((m-1)*alpha^m);

    I_Karmalkar_analytic = (1-(1-gamma)*(V_mess/Voc)-gamma*(V_mess/Voc).^m)*Isc;

    % Plot de valores experimentales y Karmalkar analytic
    h_ = figure(1);
        hold on
        plot(V_mess, I_mess, '-', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Experimental')
        plot(V_mess, I_Karmalkar_analytic, '-.', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Karmalkar Analytic')
        scatter([0 Vmp Voc], [Isc Imp 0], 50, 'k', 'filled','o', 'DisplayName', 'Puntos caracterististicos')
        hold off
        axis([0, V_mess(end), 0, I_mess(1)*1.05])
        box on; grid on
        xlabel('$V$ [V]','Interpreter','latex')
        ylabel('$I$ [A]','Interpreter','latex')
        legend('Interpreter', 'Latex', 'location', 'SouthWest')
        Save_as_PDF(h_, ['Figuras/1_An_KyH_', sheet{s}], 'horizontal');



    %% Das' model

    aux2 = betha*log(alpha);
    k_Das = lambertw(-1,aux2)/log(alpha);
    h = (1/alpha)*((1/betha)-1/k_Das-1);

    I_Das_analytic = ((1-(V_mess./Voc).^k_Das)./(1+h.*(V_mess./Voc))).*Isc;

    % Plot de valores experimentales y Das analytic
    h_ = figure(2);
        hold on
        plot(V_mess, I_mess, '-', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Experimental')
        plot(V_mess, I_Das_analytic, '-.', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Das')
        scatter([0 Vmp Voc], [Isc Imp 0], 50, 'k', 'filled','o', 'DisplayName', 'Puntos caracterististicos')
        axis([0, V_mess(end), 0, I_mess(1)*1.05])
        hold off
        box on; grid on
        xlabel('$V$ [V]','Interpreter','latex')
        ylabel('$I$ [A]','Interpreter','latex')
        legend('Interpreter', 'Latex', 'location', 'SouthWest')
        Save_as_PDF(h_, ['Figuras/1_An_Das_', sheet{s}], 'horizontal');
        
        
    close all
end