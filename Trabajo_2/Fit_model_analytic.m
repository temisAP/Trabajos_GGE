%%%%% Matriz de puntos caracteristicos de cada IV curve 
clear all
clc
close all

% % Nombre de las hojas del archivo excel
% read_filename = 'IV_curves.xlsx';
sheet = {'RTC France', 'TNJ', 'ZTJ', '3G30C','PWP201', 'KC200GT2', 'SPVSX5', 'PSC'};
% 
% % Selección de hoja (s)
% % 1 ---> RTC France
% % 2 ---> TNJ
% % 3 ---> ZTJ
% % 4 ---> 3G30C
% % 5 ---> PWP201
% % 6 ---> KC200GT2
% % 7 ---> SPVSX5
% % 8 ---> PSC
% 
% %s = 7;
% 
% % Bucle para acceder a cada hoja del excel
% for s = 1:8
% 
%     % Carga de valores experimentales
%     V_mess = xlsread(read_filename, sheet{s}, 'A21:A1202');
%     I_mess = xlsread(read_filename, sheet{s}, 'B21:B1202');
%     Isc = xlsread(read_filename, sheet{s}, 'B1');
%     Imp = xlsread(read_filename, sheet{s}, 'B2');
%     Vmp = xlsread(read_filename, sheet{s}, 'B3');
%     Voc = xlsread(read_filename, sheet{s}, 'B4');
%     betha = xlsread(read_filename, sheet{s}, 'B5'); % Imp/Isc
%     alpha = xlsread(read_filename, sheet{s}, 'B6'); % Vmp/Voc

% Cargar datos de archivo .mat
load('data.mat');

for s = 1:8 
    
    % Carga de valores experimentales
    V_mess = data{s,1};
    I_mess = data{s,2};

    % Carga de datos del fabricante
    Isc = data{s,3};
    Imp = data{s,4};
    Vmp = data{s,5};
    Voc = data{s,6};
    betha = data{s,7};
    alpha = data{s,8};

    %% Karmalkar & Haneefa’s model

    K = (1-betha-alpha)/(2*betha-1);
    aux = -(1/alpha)^(1/K)*(1/K)*log(alpha);
    m = real((lambertw(-1,aux)/log(alpha))+(1/K)+1);
    gamma = (2*betha-1)/((m-1)*alpha^m);

    I_Karmalkar_analytic = (1-(1-gamma)*(V_mess/Voc)-gamma*(V_mess/Voc).^m)*Isc;
    
    save_filename = 'Fit_model_analytic.xlsx';
    save_sheet = 'KyH';
    
    % Name
    pos = strjoin({'A',num2str(s+1)},'');
    A = cellstr(sheet{s});
    xlswrite(save_filename,A,save_sheet,pos);
    % m
    pos = strjoin({'B',num2str(s+1)},'');
    A = round(m,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % gamma
    pos = strjoin({'C',num2str(s+1)},'');
    A = round(gamma,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);


    %% Das' model

    aux2 = betha*log(alpha);
    k_Das = lambertw(-1,aux2)/log(alpha);
    h = (1/alpha)*((1/betha)-1/k_Das-1);

    I_Das_analytic = ((1-(V_mess./Voc).^k_Das)./(1+h.*(V_mess./Voc))).*Isc;
        
    save_filename = 'Fit_model_analytic.xlsx';
    save_sheet = 'Das';
    
    % Name
    pos = strjoin({'A',num2str(s+1)},'');
    A = cellstr(sheet{s});
    xlswrite(save_filename,A,save_sheet,pos);
    % k_Das
    pos = strjoin({'B',num2str(s+1)},'');
    A = round(k_Das,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % h
    pos = strjoin({'C',num2str(s+1)},'');
    A = round(h,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    
    %% Pindado  & Cubas
    
     % Al ser una función definida a trozos, se define el vector V_mess_tramo2 el
    % cual contiene únicamente valores de V >= Vmp
    V_mess_tramo1 = V_mess(V_mess < Vmp);
    V_mess_tramo2 = V_mess(V_mess >= Vmp);
    I_mess_tramo2 = I_mess((length(V_mess) - length(V_mess_tramo2) + 1):end);
    
    I_tramo1 = Isc*(1-(1-Imp/Isc)*(V_mess_tramo1/Vmp).^(Imp/(Isc-Imp)));
    eta = (Isc/Imp)*(Isc/(Isc-Imp))*((Voc-Vmp)/Voc);
    I_tramo2 = Imp*(Vmp./V_mess_tramo2).*(1-((V_mess_tramo2-Vmp)/(Voc-Vmp)).^eta);
    
    I_PC_analytic = [I_tramo1' I_tramo2'];
    %% Figura final
        % Plot de valores experimentales, Karmalkar y Das analytic
    h_ = figure(2);
        hold on
        plot(V_mess, I_mess, 'o', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Experimental')
        plot(V_mess, I_Karmalkar_analytic, '-', 'LineWidth', 1, 'Color', 'r', 'DisplayName', 'Karmalkar Analytic')
        plot(V_mess, I_Das_analytic, '-', 'LineWidth', 1, 'Color', 'b', 'DisplayName', 'Das')
        plot(V_mess, I_PC_analytic, '-', 'LineWidth', 1, 'Color', 'g','DisplayName', ...
            ["Pindado \& Cubas num\'erico"])
        scatter([0 Vmp Voc], [Isc Imp 0], 50, 'k', 'filled','o', 'DisplayName', 'Puntos caracteristicos')
        axis([0, V_mess(end), 0, I_mess(1)*1.05])
        hold off
        box on; grid on
        xlabel('$V$ [V]','Interpreter','latex')
        ylabel({'$I$';'[A]'},'Interpreter','latex')
        legend('Interpreter', 'Latex', 'location', 'SouthWest')
        Save_as_PDF(h_, ['Figuras/1_An_Das_', sheet{s}], 'horizontal');
        
        
    close all
end