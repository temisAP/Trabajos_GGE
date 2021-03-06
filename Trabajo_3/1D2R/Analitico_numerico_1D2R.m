%%%% Matriz de puntos caracteristicos de cada IV curve
clear all
clc
%%
% Nombre de las hojas del archivo excel
read_filename = '../IV_curves.xlsx';
sheet = {'RTC France', 'TNJ', 'ZTJ', '3G30C','PWP201', 'KC200GT2', 'SPVSX5', 'PSC', 'CTJ30','ATJ','4S1P'};

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

for s = 1:11
    
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
    n = [1,  3, 3, 3,36,54,15,3, 3, 3, 4]; % Pindado 2016 %Numero de células para cada fabricante
    T = [33,28,28,28,45,25,20,25,25,28,23]; % En grados
    
    a = [1.48, 1.01, 1.07,0.9,1.25,1,1.15,0.82,1.15,0.7,1.35];
    
    % Temperatura
    global Vt
    kB = 1.380649e-23; %J K-1
    qe = 1.6e-19; %C
    T = 273.15+T(s); %K
    
    Vt = n(s)*kB*T/qe;  % n número de células
    
    %% Parte analitica
    
    % Parameter calculations
    
    [Ipv,I0,Rs,Rsh] = param_1D_2R_Lap(Isc,Voc,Imp,Vmp,a(s));
    umin = [Ipv,I0,Rs,Rsh,a(s)];
    
    % For ploting results
    
    I_modelo = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo(i) = Panel_Current(umin,V_mess(i));
    end
    
    u_search = zeros(size(umin,2),1)';
    eps=0.001;
    for i=1:size(umin,2)
        u_search(i) = (1+eps)*umin(i);
    end
    error_analitico = (sum((I_modelo - I_mess).^2))^0.5;
    error2_analitico = (((I_modelo - I_mess).^2)).^0.5;
    
    rmse_analitico = RMSE(Isc, I_mess, I_modelo, length(I_modelo));
    
    %% Parte numerica
    
    [umin2,fval]=fminsearch(@(u)RECT(u,V_mess,I_mess),u_search);
    
    % Results: parameters of equivalent circuit
    
    Ipv2=umin2(1);
    I02=umin2(2);
    Rs2=umin2(3);
    Rsh2=umin2(4);
    a2=umin2(5);
    
    % plot results
    
    I_modelo2 = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo2(i) = Panel_Current(umin2,V_mess(i));
    end
    error_numerico = (sum((I_modelo - I_mess).^2))^0.5;
    error2_numerico = (((I_modelo - I_mess).^2)).^0.5;
    
    rmse_numerico = RMSE(Isc, I_mess, I_modelo2, length(I_modelo2));
    
    %% Figuras
    h_ = figure(s);
    hold on
    plot(V_mess, I_mess, '-', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Experimental')
    plot(V_mess, I_modelo, '-.', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', '1D2R Analitico')
    plot(V_mess, I_modelo2, '-o', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', '1D2R Numerico')
    scatter([0 Vmp Voc], [Isc Imp 0], 50, 'k', 'filled','o', 'DisplayName', 'Puntos caracteristicos')
    hold off
    axis([0, V_mess(end), 0, I_mess(1)*1.05])
    box on; grid on
    xlabel('$V$ [V]','Interpreter','latex')
    ylabel({'$I$';'[A]'},'Interpreter','latex')
    legend('Interpreter', 'Latex', 'location', 'SouthWest')
    %         Save_as_PDF(h_, ['Figures/2D2R', sheet{s}], 'horizontal');
    h_ = figure(5);
    plot(V_mess,error2_analitico, '-', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Experimental')
    box on; grid on
    xlabel('$V$ [V]','Interpreter','latex')
    ylabel({'$Error$'},'Interpreter','latex')
    legend('Interpreter', 'Latex', 'location', 'SouthWest')
    
    %% Valores
    Val_Ipv(s) = umin2(1);
    Val_I(s) = umin2(2);
    Val_Rs(s) = umin2(3);
    Val_Rsh(s) = umin2(4);
    Val_a(s) = umin2(5);
    
    %% Exportar resultados
    
    save_filename = 'Fit_model_1D2R.xlsx';
    save_sheet = 'Analitico';
    
    % Name
    pos = strjoin({'A',num2str(s+1)},'');
    A = cellstr(sheet{s});
    xlswrite(save_filename,A,save_sheet,pos);
    % Ipv
    pos = strjoin({'B',num2str(s+1)},'');
    A = round(Ipv,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % I0
    pos = strjoin({'C',num2str(s+1)},'');
    A = round(I0,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % Rs
    pos = strjoin({'D',num2str(s+1)},'');
    A = round(Rs,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % Rsh
    pos = strjoin({'E',num2str(s+1)},'');
    A = round(Rsh,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % a
    pos = strjoin({'F',num2str(s+1)},'');
    A = round(a(s),3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % Error
    pos = strjoin({'G',num2str(s+1)},'');
    A = round(rmse_analitico,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    
    save_sheet = 'Numerico';
    
    % Name
    pos = strjoin({'A',num2str(s+1)},'');
    A = cellstr(sheet{s});
    xlswrite(save_filename,A,save_sheet,pos);
    % Ipv
    pos = strjoin({'B',num2str(s+1)},'');
    A = round(Ipv2,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % I0
    pos = strjoin({'C',num2str(s+1)},'');
    A = round(I02,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % Rs
    pos = strjoin({'D',num2str(s+1)},'');
    A = round(Rs2,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % Rsh
    pos = strjoin({'E',num2str(s+1)},'');
    A = round(Rsh2,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % a
    pos = strjoin({'F',num2str(s+1)},'');
    A = round(a2,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % Error
    pos = strjoin({'G',num2str(s+1)},'');
    A = round(rmse_numerico,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    
    
end
