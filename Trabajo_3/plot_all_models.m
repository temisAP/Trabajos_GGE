close all
sheet = {'RTC France', 'TNJ', 'ZTJ', '3G30C','PWP201', 'KC200GT2', 'SPVSX5', 'PSC','CTJ30','ATJ','4S1P'};
read_filename='IV_curves.xlsx';
save_filename = 'errores.xlsx';


for s=1:7
    s
    %% Experimentales
    
    clear V_mess I_mess Isc Imp Vmp Voc betha alpha I E
    
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
    
    
    %% Modelo 1D2R analitico
    filename = '1D2R\Fit_model_1D2R.xlsx';
    sheet = 'Analitico';
    [Ipv,I0,Rs,Rsh,a] = read_1d2r(filename,sheet,s);
    umin = [Ipv,I0,Rs,Rsh,a];
    
    I_modelo = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo(i) = Panel_Current(umin,V_mess(i));
    end
    
    error = (sum((I_modelo - I_mess).^2))^0.5;
    error2 = (((I_modelo - I_mess).^2)).^0.5;
       
    I(:,1) = I_modelo(:);
    E(:,1) = error2(:);
    
    rmse = RMSE(Isc, I_mess, I(:,1), length(I(:,1)));
    
    % Error
    pos = strjoin({'A',num2str(s+1)},'');
    A = round(rmse,3,'significant');
    xlswrite(save_filename,A,'hoja1',pos);
    
    %% Modelo 1D2R numerico
    filename = '1D2R\Fit_model_1D2R.xlsx';
    sheet = 'Numerico';
    [Ipv,I0,Rs,Rsh,a] = read_1d2r(filename,sheet,s);
    umin = [Ipv,I0,Rs,Rsh,a];
    
    I_modelo = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo(i) = Panel_Current(umin,V_mess(i));
    end
   
    error = (sum((I_modelo - I_mess).^2))^0.5;
    error2 = (((I_modelo - I_mess).^2)).^0.5;
    
    I(:,2) = I_modelo(:);
    E(:,2) = error2(:);
    
    rmse = RMSE(Isc, I_mess, I(:,1), length(I(:,2)));
    
    % Error
    pos = strjoin({'B',num2str(s+1)},'');
    A = round(rmse,3,'significant');
    xlswrite(save_filename,A,'hoja1',pos);
    
    %% Modelo 2D2R analitico
    
    filename = '2D2R\Fit_model_2D2R.xlsx';
    sheet = 'Analitico';
    [Ipv,I01,I02,Rs,Rsh,a1,a2] = read_2d2r(filename,sheet,s);
    umin = [Ipv,I01,I02,Rs,Rsh,a1,a2];
    
    I_modelo2 = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo2(i) = Panel_Current_2D2R(umin,V_mess(i));
    end
    error = (sum((I_modelo2 - I_mess).^2))^0.5;
    error2 = (((I_modelo2 - I_mess).^2)).^0.5;
    
    I(:,3) = I_modelo2(:);
    E(:,3) = error2(:);
    
    rmse = RMSE(Isc, I_mess, I(:,1), length(I(:,3)));
    
    % Error
    pos = strjoin({'C',num2str(s+1)},'');
    A = round(rmse,3,'significant');
    xlswrite(save_filename,A,'hoja1',pos);
    
    %% Modelo 2D2R numerico
    filename = '2D2R\Fit_model_2D2R.xlsx';
    sheet = 'Numerico';
    [Ipv,I01,I02,Rs,Rsh,a1,a2] = read_2d2r(filename,sheet,s);
    umin = [Ipv,I01,I02,Rs,Rsh,a1,a2];
    
    % Discretizacion de la solucion para representarla
    I_modelo2 = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo2(i) = Panel_Current_2D2R(umin,V_mess(i));
    end
    error = (sum((I_modelo2 - I_mess).^2))^0.5;
    error2 = (((I_modelo2 - I_mess).^2)).^0.5;
    
    I(:,4) = I_modelo2(:);
    E(:,4) = error2(:);
    
    rmse = RMSE(Isc, I_mess, I(:,1), length(I(:,4)));
    
    % Error
    pos = strjoin({'D',num2str(s+1)},'');
    A = round(rmse,3,'significant');
    xlswrite(save_filename,A,'hoja1',pos);
    
    %% Plot
        
    % Modelos 
    h_ = figure();
    hold on   
    plot(V_mess, I_mess, '-', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Experimental')
    plot(V_mess, I(:,1), '-', 'LineWidth', 1.5, 'Color', 'r', 'DisplayName', '1D2R Analitico')
    plot(V_mess, I(:,2), '-', 'LineWidth', 1.5, 'Color', 'g', 'DisplayName', '1D2R Numerico')
    plot(V_mess, I(:,3), '-', 'LineWidth', 1.5, 'Color', 'b', 'DisplayName', '2D2R Analitico')
    plot(V_mess, I(:,4), '-', 'LineWidth', 1.5, 'Color', 'y', 'DisplayName', '2D2R Numerico')
    scatter([0 Vmp Voc], [Isc Imp 0], 50, 'k', 'filled','o', 'DisplayName', 'Puntos caracteristicos')
    hold off
    axis([0, V_mess(end), 0, I_mess(1)*1.05])
    box on; grid on
    xlabel('$V$ [V]','Interpreter','latex')
    ylabel({'$I$';'[A]'},'Interpreter','latex')
    legend('Interpreter', 'Latex', 'location', 'SouthWest')
    %Save_as_PDF(h_, ['Figures/', sheet{s}], 'horizontal');

    % Errores
    
    h_ = figure();
    hold on
    plot(V_mess, E(:,1), '-', 'LineWidth', 1.5, 'Color', 'r', 'DisplayName', '1D2R Analitico')
    plot(V_mess, E(:,2), '-', 'LineWidth', 1.5, 'Color', 'g', 'DisplayName', '1D2R Numerico')
    plot(V_mess, E(:,3), '-', 'LineWidth', 1.5, 'Color', 'b', 'DisplayName', '2D2R Analitico')
    plot(V_mess, E(:,4), '-', 'LineWidth', 1.5, 'Color', 'y', 'DisplayName', '2D2R Numerico')
    hold off
    box on; grid on
    xlabel('$V$ [V]','Interpreter','latex')
    ylabel({'$Error$'},'Interpreter','latex')
    legend('Interpreter', 'Latex', 'location', 'SouthWest')
    %Save_as_PDF(h_, ['Figures/error', sheet{s}], 'horizontal');

    
end

function [Ipv,I0,Rs,Rsh,a] = read_1d2r(filename,sheet,s)

try
    % Ipv
    pos = strjoin({'B',num2str(s+1)},'');
    Ipv = xlsread(filename,sheet,pos);
    % I0
    pos = strjoin({'C',num2str(s+1)},'');
    I0 = xlsread(filename,sheet,pos);
    % Rs
    pos = strjoin({'D',num2str(s+1)},'');
    Rs = xlsread(filename,sheet,pos);
    % Rsh
    pos = strjoin({'E',num2str(s+1)},'');
    Rsh = xlsread(filename,sheet,pos);
    % a
    pos = strjoin({'F',num2str(s+1)},'');
    a = xlsread(filename,sheet,pos);
catch
    disp('No data')
    Ipv = 1;
    I0 = 1;
    Rs =1;
    Rsh = 1;
    a = 1;
end
end

function [Ipv,I01,I02,Rs,Rsh,a1,a2] = read_2d2r(filename,sheet,s)

% try
    % Ipv
    pos = strjoin({'B',num2str(s+1)},'');
    Ipv = xlsread(filename,sheet,pos);
    % I01
    pos = strjoin({'C',num2str(s+1)},'');
    I01 = xlsread(filename,sheet,pos);
    % I02
    pos = strjoin({'D',num2str(s+1)},'');
    I02 = xlsread(filename,sheet,pos);
    % Rs
    pos = strjoin({'E',num2str(s+1)},'');
    Rs = xlsread(filename,sheet,pos);
    % Rsh
    pos = strjoin({'F',num2str(s+1)},'');
    Rsh = xlsread(filename,sheet,pos);
    % a1
    pos = strjoin({'G',num2str(s+1)},'');
    a1 = xlsread(filename,sheet,pos);
    % a2
    pos = strjoin({'H',num2str(s+1)},'');
    a2 = xlsread(filename,sheet,pos);
% catch
%     disp('No data')
%     Ipv = 0;
%     I01 = 0;
%     I02 = 0;
%     Rs =0;
%     Rsh = 0;
%     a1 = 0;
%     a2 = 0;
% end
end
