%%%% Matriz de puntos caracteristicos de cada IV curve
clear all
close all
clc
format long
%%
% Nombre de las hojas del archivo excel
% read_filename = '../IV_curves.xlsx';
% sheet = {'RTC France', 'TNJ', 'ZTJ', '3G30C','PWP201', 'KC200GT2', 'SPVSX5', 'PSC','CTJ30','ATJ','4S1P'};

% Selección de hoja (s)
% 1 ---> RTC France
% 2 ---> TNJ
% 3 ---> ZTJ
% 4 ---> 3G30C
% 5 ---> PWP201
% 6 ---> KC200GT2
% 7 ---> SPVSX5
% 8 ---> PSC
% 9 ---> CTJ30
% 10 --> ATJ
% 11 --> 4S1P
load('../data.mat');

%% Bucle para cada hoja
for s = 1:11
    
    %Carga valores de I V obtenidos de forma numerica
    
    load(strjoin({'Pendientes/I',num2str(s),'.mat'},''),'I_modelo');
    I_numerico=I_modelo;
    load(strjoin({'Pendientes/V',num2str(s),'.mat'},''),'V_mess');
    V_numerico = V_mess;
    
    % Limpia las variables para poder volver a trasponerlas
    clear V_mess I_mess Isc Imp Vmp Voc betha alpha
    
    % Carga de valores experimentales
%     V_mess = xlsread(read_filename, sheet{s}, 'A21:A1202');
%     I_mess = xlsread(read_filename, sheet{s}, 'B21:B1202');
%     Isc = xlsread(read_filename, sheet{s}, 'B1');
%     Imp = xlsread(read_filename, sheet{s}, 'B2');
%     Vmp = xlsread(read_filename, sheet{s}, 'B3');
%     Voc = xlsread(read_filename, sheet{s}, 'B4');

   % Carga de valores experimentales
    V_mess = data{s,1};
    I_mess = data{s,2};

    % Carga de datos del fabricante
    Isc = data{s,3};
    Imp = data{s,4};
    Vmp = data{s,5};
    Voc = data{s,6};
%     betha = data{s,7};
%     alpha = data{s,8};
    V_mess = V_mess';
    I_mess = I_mess';
%         
    %% Número de celdas y temperaturas
    n = [1,  3, 3, 3,36,54,15,54, 3, 3, 4]; % Pindado 2016 %Numero de células para cada fabricante
    T = [33,28,28,28,45,25,20,25,25,28,23]; % En grados
    
    kB = 1.380649e-23; %J K-1
    qe = 1.6e-19; %C
    T = 273.15+T(s); %K
    global Vt; Vt = n(s)*kB*T/qe;
    
    %% Valores probados que sacan resultados 
    
    Rsh0 = [45.2093,227.152,343.6129,4.782956677572412e+03,687.55,127.659,774.9025,0.2042,6.6821e4,239.6333,6.2889e3];
    Rs0 = [0.09,0.258,0.2576,0.079356540822574,2.818,0.445,1.1,0.0310,0.2732,0.3238,2.0977];
    Rs_guess = [0.03139,0.2,0.09,0.09,1.01,0.2,0.2,0.02,0.2,0.2,0.9];
    a2= [2,2,2,2,2,2,2,1.8,2,2,1.24];
    
    if s==5
           metodo = 'fminsearch';
      elseif s==4
           metodo = 'fzero';
           [Rsh04, Rs04] = pendiente_2D2R(I_numerico, V_numerico,s);
           Rsh0(s)=Rsh04;
           Rs0(s) = Rs04;
       else
           metodo = 'fminsearch';
    end
    Rsh0 = Rsh0(s);
    Rs0 = Rs0(s);
    Rs_guess = Rs_guess(s);
    a2 = a2(s);

    %% Metodo analítico optimizando las pendientes
    
%     % Hallar el valor de la pendiente en el origen
%     [Rsh0, Rs0] = pendiente_2D2R(I_numerico, V_numerico,s);
%         
%     save('wksp.mat')
%     
%     R_guess = [Rsh0 Rs0];
%           
%     ub = [Rsh0*10 Rs0*5];
%     lb = [Rsh0*0.2 0];
%     metodo = 'particleswarm';
%     switch metodo
%         case 'fzero'
%             error = fzero(@(Rsh0,Rs0) analytic2d2r,R_guess);
%         case 'fmincon'
%             options= optimoptions('fmincon','Algorithm','interior-point','FunctionTolerance',1e-8);
%             error = fmincon(@(Rsh0,Rs0) analytic2d2r,2,[],[],[],[],lb,ub,[],options);
%         case 'gamultiobj'
%             options = optimoptions('gamultiobj','InitialPopulationMatrix', R_guess,'FunctionTolerance',1e-8);
%             error = gamultiobj(@(Rsh0,Rs0) analytic2d2r,2,[],[],[],[],lb,ub,options);
%         case 'particleswarm'
%             options = optimoptions('particleswarm','InitialSwarmMatrix', R_guess,'FunctionTolerance',1e-8);
%             error = particleswarm(@(Rsh0,Rs0) analytic2d2r,2,lb,ub,options);
%         case 'fminsearch'     
%            error =fminsearch(@(Rsh0,Rs0) analytic2d2r,R_guess);
%     end
%     
%     load('wksp.mat');


%% Método analitico

    % Metodo analítico ( Por si se quiere probar a calcular la pendiente
    % con los datos reales
    
        %I_numerico = I_mess;
        %V_numerico = V_mess;

    % Hallar el valor de la pendiente en el origen
    
%     [Rsh0, Rs0] = pendiente_2D2R(I_numerico, V_numerico,s);
    
    % Calcular el resto de parametros
%     a2=2;
    [Ipv,I01,I02,Rs,Rsh,a1] = param_2D2R(Isc,Voc,Imp,Vmp,a2,Rsh0, Rs0,Rs_guess,metodo);
    umin = [Ipv,I01,I02,Rs,Rsh,a1,a2];
      
    % Discretizacion de la solucion para representarla
    I_modelo2 = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo2(i) = Panel_Current_2D2R(umin,V_mess(i));
    end
    error = (sum((I_modelo2 - I_mess).^2))^0.5;
    error2 = (((I_modelo2 - I_mess).^2)).^0.5;
    
    rmse = RMSE(Isc, I_mess, I_modelo2, length(I_modelo2));
    
    %% Figuras
    
    % Ajuste
    figure(s);
    hold on
    plot(V_mess, I_mess, '-', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Experimental')
    plot(V_mess, I_modelo2, '-.', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', '2D2R')
    scatter([0 Vmp Voc], [Isc Imp 0], 50, 'k', 'filled','o', 'DisplayName', 'Puntos caracteristicos')
    hold off
    axis([0, V_mess(end), 0, I_mess(1)*1.05])
    box on; grid on
    xlabel('$V$ [V]','Interpreter','latex')
    ylabel({'$I$';'[A]'},'Interpreter','latex')
    legend('Interpreter', 'Latex', 'location', 'SouthWest')
    % Save_as_PDF(h_, ['Figures/2D2R', sheet{s}], 'horizontal');
    
    % Error
    figure(s+11);
    plot(V_mess,error2, '-', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Experimental')
    box on; grid on
    xlabel('$V$ [V]','Interpreter','latex')
    ylabel({'$Error$'},'Interpreter','latex')
    legend('Interpreter', 'Latex', 'location', 'SouthWest')
    
    %% Exportar resultados
    
    save = 'n';
    if save == 'y'
        
        save_filename = 'Fit_model_2D2R.xlsx';
        save_sheet = 'Analitico';
        
        % Name
        pos = strjoin({'A',num2str(s+1)},'');
        A = cellstr(sheet{s});
        xlswrite(save_filename,A,save_sheet,pos);
        % Ipv
        pos = strjoin({'B',num2str(s+1)},'');
        A = round(Ipv,3,'significant');
        xlswrite(save_filename,A,save_sheet,pos);
        % I01
        pos = strjoin({'C',num2str(s+1)},'');
        A = round(I01,3,'significant');
        xlswrite(save_filename,A,save_sheet,pos);
        % I02
        pos = strjoin({'D',num2str(s+1)},'');
        A = round(I02,3,'significant');
        xlswrite(save_filename,A,save_sheet,pos);
        % Rs
        pos = strjoin({'E',num2str(s+1)},'');
        A = round(Rs,3,'significant');
        xlswrite(save_filename,A,save_sheet,pos);
        % Rsh
        pos = strjoin({'F',num2str(s+1)},'');
        A = round(Rsh,3,'significant');
        xlswrite(save_filename,A,save_sheet,pos);
        % a1
        pos = strjoin({'G',num2str(s+1)},'');
        A = round(a1,3,'significant');
        xlswrite(save_filename,A,save_sheet,pos);
        % a2
        pos = strjoin({'H',num2str(s+1)},'');
        A = round(a2,3,'significant');
        xlswrite(save_filename,A,save_sheet,pos);     
        % Error
        pos = strjoin({'I',num2str(s+1)},'');
        A = round(rmse,3,'significant');
        xlswrite(save_filename,A,save_sheet,pos);
        
    end
    
end
