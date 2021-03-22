clc
clear all
close all

%% Cargar datos de celulas
% Cargar los datos, si no estan para
try
    load('Data/Cells_Data.mat')
    load('Data/analitico_1D2R.mat')
    load('Data/numerico_1D2R.mat')
    load('Data/analitico_2D2R.mat')
    load('Data/numerico_2D2R.mat')
catch
    return
        % read_filename='IV_curves.xlsx';
        % read_sheet = {'RTC France', 'TNJ', 'ZTJ', '3G30C','PWP201', 'KC200GT2', 'SPVSX5', 'PSC','CTJ30','ATJ','4S1P'};
end

save_error = 0;
save_filename = 'errores.xlsx';


for s=1:7
    %% Experimentales
    
    clear V_mess I_mess Isc Imp Vmp Voc betha alpha I E
    
    % Carga de valores experimentales
    V_mess = Cells(s).V_mess;
    I_mess = Cells(s).I_mess;
    Isc = Cells(s).Isc;
    Imp = Cells(s).Imp;
    Vmp = Cells(s).Vmp;
    Voc = Cells(s).Voc;
    
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
    umin = [analitico_1D2R(s).Ipv, analitico_1D2R(s).I0, ...
            analitico_1D2R(s).Rs, analitico_1D2R(s).Rsh, ...
            analitico_1D2R(s).a];
    
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
    if save_error == 1
        xlswrite(save_filename,A,'hoja1',pos);
    end
    
    %% Modelo 1D2R numerico
    umin = [numerico_1D2R(s).Ipv, numerico_1D2R(s).I0, ...
            numerico_1D2R(s).Rs, numerico_1D2R(s).Rsh, ...
            numerico_1D2R(s).a];
    
    I_modelo = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo(i) = Panel_Current(umin,V_mess(i));
    end
   
    error = (sum((I_modelo - I_mess).^2))^0.5;
    error2 = (((I_modelo - I_mess).^2)).^0.5;
    
    I(:,2) = I_modelo(:);
    E(:,2) = error2(:);
    
    rmse = RMSE(Isc, I_mess, I(:,2), length(I(:,2)));
    
    % Error
    pos = strjoin({'B',num2str(s+1)},'');
    A = round(rmse,3,'significant');
    if save_error == 1
        xlswrite(save_filename,A,'hoja1',pos);
    end
    
    %% Modelo 2D2R analitico

    umin = [analitico_2D2R(s).Ipv, analitico_2D2R(s).I01, analitico_2D2R(s).I02,...
     analitico_2D2R(s).Rs, analitico_2D2R(s).Rsh, analitico_2D2R(s).a1,...
     analitico_2D2R(s).a2];
    
    I_modelo2 = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo2(i) = Panel_Current_2D2R(umin,V_mess(i));
    end
    error = (sum((I_modelo2 - I_mess).^2))^0.5;
    error2 = (((I_modelo2 - I_mess).^2)).^0.5;
    
    I(:,3) = I_modelo2(:);
    E(:,3) = error2(:);
    
    rmse = RMSE(Isc, I_mess, I(:,3), length(I(:,3)));
    
    % Error
    pos = strjoin({'C',num2str(s+1)},'');
    A = round(rmse,3,'significant');
    if save_error == 1
        xlswrite(save_filename,A,'hoja1',pos);
    end
    
    %% Modelo 2D2R numerico
    umin = [numerico_2D2R(s).Ipv, numerico_2D2R(s).I01, numerico_2D2R(s).I02,...
     numerico_2D2R(s).Rs, numerico_2D2R(s).Rsh, numerico_2D2R(s).a1,...
     numerico_2D2R(s).a2];
    
    % Discretizacion de la solucion para representarla
    I_modelo2 = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo2(i) = Panel_Current_2D2R(umin,V_mess(i));
    end
    error = (sum((I_modelo2 - I_mess).^2))^0.5;
    error2 = (((I_modelo2 - I_mess).^2)).^0.5;
    
    I(:,4) = I_modelo2(:);
    E(:,4) = error2(:);
    
    rmse = RMSE(Isc, I_mess, I(:,4), length(I(:,4)));
    
    % Error
    pos = strjoin({'D',num2str(s+1)},'');
    A = round(rmse,3,'significant');
    if save_error == 1
        xlswrite(save_filename,A,'hoja1',pos);
    end
    
    %% PLOTS
       
    gray = [1,1,1]*0.65;
    % Modelos 
    h_ = figure();
    hold on   
    plot(V_mess, I_mess, 'o', 'LineWidth', 1, 'Color', 'k','DisplayName', 'Experimental')
    plot(V_mess, I(:,1), '-', 'LineWidth', 1.5, 'Color', gray, 'DisplayName', '1D2R Analitico')
    plot(V_mess, I(:,2), '-.', 'LineWidth', 1.5, 'Color', gray, 'DisplayName', '1D2R Numerico')
    plot(V_mess, I(:,3), ':', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', '2D2R Analitico')
    plot(V_mess, I(:,4), '--', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', '2D2R Numerico')
    scatter([0 Vmp Voc], [Isc Imp 0], 50, 'k', 'filled','o', 'DisplayName', 'Puntos caracteristicos')
    hold off
    axis([0, V_mess(end)*1.1, 0, I_mess(1)*1.1])
    box on; grid on
    xlabel('$V$ [V]','Interpreter','latex')
    ylabel({'$I$';'[A]'},'Interpreter','latex')
    legend('Interpreter', 'Latex', 'location', 'SouthWest')
    Save_as_PDF(h_, ['Figuras/Comparacion_', Cells(s).Name], 'horizontal');

    % Errores
    
    h_ = figure();
    hold on
    plot(V_mess, E(:,1), '-', 'LineWidth', 1.5, 'Color', gray, 'DisplayName', '1D2R Analitico')
    plot(V_mess, E(:,2), '-.', 'LineWidth', 1.5, 'Color', gray, 'DisplayName', '1D2R Numerico')
    plot(V_mess, E(:,3), ':', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', '2D2R Analitico')
    plot(V_mess, E(:,4), '--', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', '2D2R Numerico')
    hold off
    axis([0, V_mess(end)*1, 0, max(max(E))*1])
    box on; grid on
    xlabel('$V$ [V]','Interpreter','latex')
    ylabel({'$I-I_{exp}$';'[A]'},'Interpreter','latex');
    legend('Interpreter', 'Latex', 'location', 'NorthWest')
    Save_as_PDF(h_, ['Figuras/Error_', Cells(s).Name],'horizontal', 7.5, 10);

    
end