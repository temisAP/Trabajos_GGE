%% Fit model 2D2R numeric

%%%%% Matriz de puntos caracteristicos de cada IV curve
clear all
clc

% Nombre de las hojas del archivo excel
% read_filename = '../IV_curves.xlsx';
 sheet = {'RTC France', 'TNJ', 'ZTJ', '3G30C','PWP201', 'KC200GT2', 'SPVSX5', 'PSC','CTJ30','ATJ','4S1P'};

% Selección de hoja (s)
% 1 ---> RTC France
% 2 ---> TNJ
% 3 ---> ZTJ
% 4 ---> 3G30C
% 5 ---> PWP201
% 6 ---> KC200GT2
% 7 ---> SPVSX5
% 8 ---> PSC

load('../data.mat');
% %% Bucle para cada hoja
 for s = 1:2
 
    clear V_mess I_mess Isc Imp Vmp Voc betha alpha u
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
    
    
   % Carga de valores experimentales
    V_mess = data{s,1};
    I_mess = data{s,2};

    % Carga de datos del fabricante
    Isc = data{s,3};
    Imp = data{s,4};
    Vmp = data{s,5};
    Voc = data{s,6};
%     V_mess = V_mess';
%     I_mess = I_mess';
    
    % Lee los ajustes del modelo 1D2R si los hubiera
% %     try
%         init_filename = '1D2R\Fit_model_1D2R.xlsx';
%         init_sheet = 'Numerico';
%         
%         % Ipv
%         pos = strjoin({'B',num2str(s+1)},'');
%         Ipv = xlsread(init_filename,init_sheet,pos);
%         % I0
%         pos = strjoin({'C',num2str(s+1)},'');
% %         A = round(I0,3,'significant');
%         I0 = xlswrite(init_filename,init_sheet,pos);
%         % Rs
%         pos = strjoin({'D',num2str(s+1)},'');
%         Rs = xlswrite(init_filename,init_sheet,pos);
%         % Rsh
%         pos = strjoin({'E',num2str(s+1)},'');
%         Rsh = xlswrite(init_filename,init_sheet,pos);
%         % a
%         pos = strjoin({'F',num2str(s+1)},'');
%         a = xlswrite(init_filename,init_sheet,pos);
    
    V_mess = V_mess';
    I_mess = I_mess';
    n = [1,  3, 3, 3,36,54,15,3, 3, 3, 4]; % Pindado 2016 %Numero de células para cada fabricante
    T = [33,28,28,28,45,25,20,25,25,28,23]; % En grados

    %Inicializar los valores para el fminsearch cogiendo los de 1D2R (
    %Tabla analitica)
 
%     a = [1.48, 1.01, 1.07,0.9,1.4,1,1.15,1,1.15,0.7,1.35];
%     Rs = [3.62e-2,5.51e-2,7.41e-2,7.95e-2,1.56,3.36e-1,2.40e-2];
%     Rsh = [5.20e1,2.08e2,2.73e2,2.62e3,3.55e3,1.59e2,9.69e3];
%     I0 = [3.2e-7,3.49e-15,2.78e-15,9.55e-18,1.28e-6,4.03e-10,1.48e-14];
%     Ipv = [7.61e-1,5.24e-1,4.63e-1,5.20e-1,1.03,8.23,5.03e-1];

    %Inicializar los valores para el fminsearch cogiendo los de 1D2R
    %numerico
    a2 =2;
    Rsh = [44.209,204.542,348.576,3290.67,683.197,124.072,1609.1180,0.2,2482.55,236.61,17017.45];
    Rs = [0.03697,0.11059,0.0778,0.0794,1.3122,0.2424,0.03746,0.001209,0.048735,0.1864,1.24427];
    I0= [2.746e-07,3.146e-15,1.2826e-14,2.4982e-18,1.732e-06,8.6177e-10,4.58e-16,3.41e-05,3.019e-13,7.82e-21,3.305e-37];
    Ipv = [0.7617,0.526,0.4649,0.5272,1.032,8.190,0.4992,7.679,0.47,0.434,0.4665];
    a = [1.46,1.015,1.121,0.871,1.27,1.03,1.034,0.83,1.210,0.733,1.28];
    u_ini = [Ipv(s),I0(s),I0(s),Rs(s),Rsh(s),a(s),2];
    u_sup = u_ini * 1.5;
    u_inf = u_ini * 0.5;


    global Vt
    kB = 1.380649e-23; %J K-1
    qe = 1.6e-19; %C
    T = 273.15+T(s); %K

    Vt = n(s)*kB*T/qe;  % n número de células

    % Minimize Least squares
%       options = optimset('MaxFunEvals',1000*7, 'MaxIter',500*7);
% 
%     u_ini = [1, 1e-6, 1e-6, 1, 10, 1,2];
    metodo = 'fminsearch';
    switch metodo
        case 'fmincon'
            options= optimoptions('fmincon','Algorithm','interior-point');
            [umin,fval,exitflag,output] = fmincon(@(u)RECT(u,V_mess,I_mess),u_ini,[],[],[],[],u_inf,u_sup,options);
        case 'gamultiobj'
            options = optimoptions('gamultiobj','InitialPopulationMatrix', u_ini);
            [umin,fval,exitflag,output] = gamultiobj(@(u)RECT(u,V_mess,I_mess),length(u_sup),[],[],[],[],u_inf,u_sup,options);
        case 'fminsearch'    
           [umin,fval,exitflag,output]=fminsearch(@(u)RECT(u,V_mess,I_mess),u_ini);
    end

    try
        
    catch
        disp('error while fminsearch')
        umin = zeros(7,1);
    end

    % Results: parameters of equivalent circuit

    Ipv=umin(1);
    I01=umin(2);
    I02=umin(3);
    Rs=umin(4);
    Rsh=umin(5);
    a1=umin(6);
    a2=umin(7);

    % Plot de valores experimentales y Karmalkar analytic

    I_modelo = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo(i) = Panel_Current(umin,V_mess(i));
    end

    %Guardar las pendientes
%     save(strjoin({'Pendientes/I',num2str(s),'.mat'},''),'I_modelo');
%     save(strjoin({'Pendientes/V',num2str(s),'.mat'},''),'V_mess');
    %% Reescribir el error igual que en trabajo 2
    error2 = ((I_modelo - I_mess).^2).^0.5;
    error = (sum((I_modelo - I_mess).^2))^0.5;
% 
    h_ = figure(s);
        hold on
        plot(V_mess, I_mess, '-', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Experimental')
        plot(V_mess, I_modelo, '-.', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', '2D2R')
        scatter([0 Vmp Voc], [Isc Imp 0], 50, 'k', 'filled','o', 'DisplayName', 'Puntos caracteristicos')
        hold off
        axis([0, V_mess(end), 0, I_mess(1)*1.05])
        box on; grid on
        xlabel('$V$ [V]','Interpreter','latex')
        ylabel({'$I$';'[A]'},'Interpreter','latex')
        legend('Interpreter', 'Latex', 'location', 'SouthWest')
%         Save_as_PDF(h_, ['Figures/2D2R_numeric', sheet{s}], 'horizontal');

h_ = figure(s+11);

        plot(V_mess,error2, '-', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Experimental')
        box on; grid on
        xlabel('$V$ [V]','Interpreter','latex')
        ylabel({'$Error$'},'Interpreter','latex')
        legend('Interpreter', 'Latex', 'location', 'SouthWest')
% 
%     save_filename = 'Fit_model_2D2R_numeric.xlsx';
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
%     % a2
%     pos = strjoin({'H',num2str(s+1)},'');
%     A = round(a2,3,'significant');
%     xlswrite(save_filename,A,save_sheet,pos);

end

%% Funciones

function I_modelo = Panel_Current(u, V_mesh)
global Vt

%Ipv=u(1); I01=u(2); I02=u(3); Rs=u(4); Rsh=u(5); a1=u(6); a2=u(7);
try
    I_modelo =fzero(@(I) u(1)-u(2)*(exp((V_mesh+u(4)*I)/(Vt*u(6)))-1)-u(3)*(exp((V_mesh+u(4)*I)/(Vt*u(7)))-1)-(V_mesh+u(4)*I)/u(5)-I, 0);
catch
    disp('error while fzero')
    I_modelo = 1e10;
end 

end

function error = RECT(u, V_mesh, I_exp)

for i=1:size(V_mesh,2)
    I_modelo(i) = Panel_Current(u,V_mesh(i));
end
error = (sum((I_modelo - I_exp).^2))^0.5;

end
