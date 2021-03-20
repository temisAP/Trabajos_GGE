%%%% Matriz de puntos caracteristicos de cada IV curve
clear all
close all
clc
%%
% Nombre de las hojas del archivo excel
read_filename = 'IV_curves.xlsx';
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


%% Bucle para cada hoja
s=4;
% % for s = 1:8

  %cargar las pendientes
      %Valores de I V obtenido de forma numerica
    
  load('I4.mat','I_modelo');
  I_numerico=I_modelo;
  load('V4.mat','V_mess');
  V_numerico = V_mess;
%     
    clear V_mess I_mess Isc Imp Vmp Voc betha alpha
    
    % Carga de valores experimentales
    V_mess = xlsread(read_filename, sheet{s}, 'A21:A1202');
    I_mess = xlsread(read_filename, sheet{s}, 'B21:B1202');
    Isc = xlsread(read_filename, sheet{s}, 'B1');
    Imp = xlsread(read_filename, sheet{s}, 'B2');
    Vmp = xlsread(read_filename, sheet{s}, 'B3');
    Voc = xlsread(read_filename, sheet{s}, 'B4');
    V_mess = V_mess';
    I_mess = I_mess';
    
    

%%     
    n = [1,3,3,3,36,54,15]; % Pindado 2016 %Numero de células para cada fabricante
    T = [33,28,28,28,45,25,20];
    %Rsh0 = [1,2,743,4,5,6,7,8,9,10]
    %Rs = [1,2,0.248;,4,5,6,7,8,9,10]
    %Rs_guess = [1,2,0.07;,4,5,6,7,8,9,10]
    
   





%%
% Temperatura
global Vt
kB = 1.380649e-23; %J K-1
qe = 1.6e-19; %C
T = 273.15+T(s); %K

Vt = n(s)*kB*T/qe;  % n número de células
%%
%Son los datos del paper de   Pindado 2015 con un primer ajuste, que leugo
%los guarde y los cargue para comprobar que las ecuaciones en si estaban
%bien. Si descomentan esta parte se ve que va bien para esos datos.
% load('I_modelo.mat','I_modelo');
% I_mess=I_modelo;
% load('V_mess.mat','V_mess');
% Pot = I_mess.*V_mess;
%  
% maximum = max(Pot);
% [x,index]=find(Pot==maximum);
% Imp = I_mess(index);
% Vmp =  V_mess(index);
% Isc = I_mess(1);
% Voc = V_mess(64); %aprox


[Rsh0, Rs0] = pendiente_2D2R(I_numerico, V_numerico);

a2=2;
[Ipv,I01,I02,Rs,Rsh,a1] = param_2D2R(Isc,Voc,Imp,Vmp,a2,Rsh0, Rs0);
umin = [Ipv,I01,I02,Rs,Rsh,a1,a2];




I_modelo2 = zeros(size(V_mess,2),1)';
     for i=1:size(V_mess,2)
        I_modelo2(i) = Panel_Current_2D2R(umin,V_mess(i));
     end
  error = (sum((I_modelo2 - I_mess).^2))^0.5;
  error2 = (((I_modelo2 - I_mess).^2)).^0.5;
  

    %% Figuras
    h_ = figure(1);
        hold on
        plot(V_mess, I_mess, '-', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Experimental')
        plot(V_mess, I_modelo2, '-.', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', '2D2R')
        scatter([0 Vmp Voc], [Isc Imp 0], 50, 'k', 'filled','o', 'DisplayName', 'Puntos caracteristicos')
        hold off
%         axis([0, V_mess(end), 0, I_mess(1)*1.05])
        box on; grid on
        xlabel('$V$ [V]','Interpreter','latex')
        ylabel({'$I$';'[A]'},'Interpreter','latex')
        legend('Interpreter', 'Latex', 'location', 'SouthWest')
%         Save_as_PDF(h_, ['Figures/2D2R', sheet{s}], 'horizontal');
h_ = figure(2);

        plot(V_mess,error2, '-', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Experimental')
        box on; grid on
        xlabel('$V$ [V]','Interpreter','latex')
        ylabel({'$Error$'},'Interpreter','latex')
        legend('Interpreter', 'Latex', 'location', 'SouthWest')
     
    %% Exportar resultados
    
%     save_filename = 'Fit_model_2D2R.xlsx';
%     save_sheet = 'Hoja1';
%     
%     % Name
%     pos = strjoin({'A',num2str(s+1)},'');
%     A = cellstr(sheet{s});
%     xlswrite(save_filename,A,save_sheet,pos);
%     % Ipv
%     pos = strjoin({'B',num2str(s+1)},'');
%     A = round(Ipv,3,'significant');
%     xlswrite(save_filename,A,save_sheet,pos);
%     % I01
%     pos = strjoin({'C',num2str(s+1)},'');
%     A = round(I01,3,'significant');
%     xlswrite(save_filename,A,save_sheet,pos);
%     % I02
%     pos = strjoin({'D',num2str(s+1)},'');
%     A = round(I02,3,'significant');
%     xlswrite(save_filename,A,save_sheet,pos);
%     % Rs
%     pos = strjoin({'E',num2str(s+1)},'');
%     A = round(Rs,3,'significant');
%     xlswrite(save_filename,A,save_sheet,pos);
%     % Rsh
%     pos = strjoin({'F',num2str(s+1)},'');
%     A = round(Rsh,3,'significant');
%     xlswrite(save_filename,A,save_sheet,pos);
%     % a1
%     pos = strjoin({'G',num2str(s+1)},'');
%     A = round(a1,3,'significant');
%     xlswrite(save_filename,A,save_sheet,pos);
    % a2
%     pos = strjoin({'H',num2str(s+1)},'');
%     A = round(a2,3,'significant');
%     xlswrite(save_filename,A,save_sheet,pos);
%     

% end
