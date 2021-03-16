%% Fit model 2D2R

%%%%% Matriz de puntos caracteristicos de cada IV curve
clear all
clc

% Temperatura
kB = 1.380649e-23; %J K-1
qe = 1.6e-19; %C
T = 288.15; %K
Vt = kB*T/qe;

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

for s = 1:8
    
    clear V_mess I_mess Isc Imp Vmp Voc betha alpha
    
    % Carga de valores experimentales
    V_mess = xlsread(read_filename, sheet{s}, 'A21:A1202');
    I_mess = xlsread(read_filename, sheet{s}, 'B21:B1202');
    Isc = xlsread(read_filename, sheet{s}, 'B1');
    Imp = xlsread(read_filename, sheet{s}, 'B2');
    Vmp = xlsread(read_filename, sheet{s}, 'B3');
    Voc = xlsread(read_filename, sheet{s}, 'B4');
    betha = xlsread(read_filename, sheet{s}, 'B5'); % Imp/Isc
    alpha = xlsread(read_filename, sheet{s}, 'B6'); % Vmp/Voc
    
    V_mess = V_mess';
    I_mess = I_mess';
    
    %Cálculo de paramétro Referencia: 2015_MPE
    
    %Calculo pendiente:
    
    Rsh0 = -(I_mess(1,2)-I_mess(1,1))/(V_mess(1,2)-V_mess(1,1));
    Rs0 = -(I_mess(1,end)-I_mess(1,end-1))/(V_mess(1,end)-V_mess(1,end-1));
    
    %% Paso1 Estimar el parámetro a2
    a2 = 2;
    
    % A1 = Rsh0*(Isc-Imp)-Vmp-a2*Vt*((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs));
    % A2 = (Rsh0*Isc-Voc)-a2*Vt((Rsh0-Rs0)/(Rs0-Rs));
    % A3 = (Vmp+Imp*Rs-Voc)*(((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs))-((Rsh0-Rs0)/(Rs0-Rs))*exp((Vmp+Imp*Rs-Voc)/(a2*Vt)));
    % A4 = (Rsh0*(Isc-Imp)-Vmp)-(Rsh0*Isc-Voc)*exp((Vmp+Imp*Rs-Voc)/(a2*Vt));
    
    %% Paso2 despejar Rs
    
    Rs_guess =0.08;
    Rs_sol = fzero(@(Rs) log((Rsh0*(Isc-Imp)-Vmp-a2*Vt*((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs)))/((Rsh0*Isc-Voc)-a2*Vt((Rsh0-Rs0)/(Rs0-Rs)))) ...
        -(Vmp+Imp*Rs-Voc)*(((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs))-(((Rsh0-Rs0)/(Rs0-Rs))*exp((Vmp+Imp*Rs-Voc)/(a2*Vt))))/...
        ((Rsh0*(Isc-Imp)-Vmp)-(Rsh0*Isc-Voc)*exp((Vmp+Imp*Rs-Voc)/(a2*Vt))),Rs_guess);
    % syms Rs Rsh0 Rs0 Isc Voc Imp Vmp a2 Vt
    % eqn = (log((Rsh0*(Isc-Imp)-Vmp-a2*Vt*((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs)))/((Rsh0*Isc-Voc)-a2*Vt((Rsh0-Rs0)/(Rs0-Rs)))) ...
    %                        -(Vmp+Imp*Rs-Voc)*(((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs))-(((Rsh0-Rs0)/(Rs0-Rs))*exp((Vmp+Imp*Rs-Voc)/(a2*Vt))))/...
    %                        ((Rsh0*(Isc-Imp)-Vmp)-(Rsh0*Isc-Voc)*exp((Vmp+Imp*Rs-Voc)/(a2*Vt)))) == 0;
    % solve(eqn,Rs)
    Rs=0.0802;
    %% Paso 3 Obtener el parámetro a1
    
    B1 = ((Rsh0*(Isc-Imp)-Vmp)-(Rsh0*Isc-Voc)*exp((Vmp + Imp*Rs-Voc)/(a2*Vt)));
    B2 = ((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs)-((Rsh0-Rs0)/(Rs0-Rs))*exp((Vmp+Imp*Rs-Voc)/(a2*Vt)))^(-1);
    a1Vt = B1*B2;
    a1 = a1Vt/Vt;
    a1=0.9980;
    %% Paso 4 obtener I_01
    
    I_01 = a1/(a1-a2)*exp(-Voc/(a1*Vt))*(a2*Vt*(Rsh0-Rs0)-(Rs0-Rs)*(Rsh0*Isc-Voc))/((Rsh0-Rs)*(Rs0-Rs));
    I_01=2.4409*10^-16;
    
    %% Paso 5 obtener I_02
    
    I_02 = a2/(a1-a2)*exp(-Voc/(a2*Vt))*(a1*Vt*(Rsh0-Rs0)-(Rs0-Rs)*(Rsh0*Isc-Voc))/((Rsh0-Rs)*(Rs0-Rs));
    I_02=8.4461*10^-10;
    
    %% Paso 6 Obtener Rsh
    
    Rsh = Rsh0-Rs;
    Rsh=343.5357;
    
    %% Paso 7 Obtener Ipv
    
    Ipv = (Rsh+Rs)/Rsh*Isc;
    Ipv=0.4629;
    
    %% MODELO 2D2R
    I_modelo = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo(i) = fzero(@(I) Ipv - I_01*(exp((V_mess(1,i)+I*Rs)/(a1*Vt))-1) - I_02*(exp((V_mess(1,i)+I*Rs)/(a2*Vt))-1) - (V_mess(1,i)+I*Rs)/Rsh - I, 0);
    end
    error = (sum((I_modelo - I_mess).^2))^0.5;
    
    % I_modelo = fzero(@(I)Ipv - I_01*(exp((V+I*Rs)/(a1*Vt))-1) - I_02*(exp((V+I*Rs)/(a2*Vt))-1) - (V+I*Rs)/Rsh - I, 0);
    
    %% Figuras
    % h_ = figure(1);
    %     hold on
    %     plot(V_mess, I_mess, '-', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Experimental')
    %     plot(V_mess, I_modelo, '-.', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', '2D2R')
    %     scatter([0 Vmp Voc], [Isc Imp 0], 50, 'k', 'filled','o', 'DisplayName', 'Puntos caracteristicos')
    %     hold off
    %     axis([0, V_mess(end), 0, I_mess(1)*1.05])
    %     box on; grid on
    %     xlabel('$V$ [V]','Interpreter','latex')
    %     ylabel({'$I$';'[A]'},'Interpreter','latex')
    %     legend('Interpreter', 'Latex', 'location', 'SouthWest')
    %     Save_as_PDF(h_, ['Figures/2D2R', sheet{s}], 'horizontal');
    
    %% Exportar resultados
    
    save_filename = 'Fit_model_2D2R.xlsx';
    save_sheet = 'Hoja1';
    
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
    pos = strjoin({'G',num2str(s+1)},'');
    A = round(a2,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    

end