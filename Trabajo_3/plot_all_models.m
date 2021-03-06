clc
clear all
close all

%% Cargar datos de celulas
% Cargar los datos, si no estan para
try
    load('Data/Cells_Data.mat')
    load('Data/analitico1D2R.mat')
    load('Data/numerico1D2R.mat')
    load('Data/analitico2D2R.mat')
    load('Data/numerico2D2R.mat')
    %load('Data/numerico_2D2R.mat')
    %load('Data/analitico_2D2R.mat')
    %load('Data/numerico_1D2R.mat')
    %load('Data/analitico_1D2R.mat')
catch
    return
end

save_error = 0;
save_filename = 'errores.xlsx';


for s = 1:length(Cells)
    %% Experimentales
    rmse(s).Name = Cells(s).Name;
    
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
%     umin = [analitico_1D2R(s).Ipv, analitico_1D2R(s).I0, ...
%             analitico_1D2R(s).Rs, analitico_1D2R(s).Rsh, ...
%             analitico_1D2R(s).a];
%     
%     I_modelo = zeros(size(V_mess,2),1)';
%     for i=1:size(V_mess,2)
%         I_modelo(i) = Panel_Current(umin,V_mess(i));
%     end
    I_modelo = Datos_analitico_1D2R(s).I_modelo2;
    error = (sum((I_modelo - I_mess).^2))^0.5;
    error2 = (((I_modelo - I_mess).^2)).^0.5;
       
    I(:,1) = I_modelo(:);
    E(:,1) = error2(:);
    
    rmse(s).an1D2R = RMSE(Isc, I_mess, I(:,1), length(I(:,1)));
    
    % Error
%     pos = strjoin({'A',num2str(s+1)},'');
%     A = round(rmse,3,'significant');
%     if save_error == 1
%         xlswrite(save_filename,A,'hoja1',pos);
%     end
    
    %% Modelo 1D2R numerico
%     umin = [numerico_1D2R(s).Ipv, numerico_1D2R(s).I0, ...
%             numerico_1D2R(s).Rs, numerico_1D2R(s).Rsh, ...
%             numerico_1D2R(s).a];
%     
%     I_modelo = zeros(size(V_mess,2),1)';
%     for i=1:size(V_mess,2)
%         I_modelo(i) = Panel_Current(umin,V_mess(i));
%     end
    I_modelo = Datos_numericos_1D2R(s).I_modelo2;
    error = (sum((I_modelo - I_mess).^2))^0.5;
    error2 = (((I_modelo - I_mess).^2)).^0.5;
    
    I(:,2) = I_modelo(:);
    E(:,2) = error2(:);
    
    rmse(s).num1D2R = RMSE(Isc, I_mess, I(:,2), length(I(:,2)));
    
    % Error
%     pos = strjoin({'B',num2str(s+1)},'');
%     A = round(rmse,3,'significant');
%     if save_error == 1
%         xlswrite(save_filename,A,'hoja1',pos);
%     end
    
    %% Modelo 2D2R analitico

%     umin = [analitico_2D2R(s).Ipv, analitico_2D2R(s).I01, analitico_2D2R(s).I02,...
%      analitico_2D2R(s).Rs, analitico_2D2R(s).Rsh, analitico_2D2R(s).a1,...
%      analitico_2D2R(s).a2];
%     
%     I_modelo2 = zeros(size(V_mess,2),1)';
%     for i=1:size(V_mess,2)
%         I_modelo2(i) = Panel_Current_2D2R(umin,V_mess(i));
%     end
%     if s == 8
%         load('Data/I_2D2R_A_8.mat');
%     end
    I_modelo2 = Datos_analitico_2D2R(s).I_modelo2;
    error = (sum((I_modelo2 - I_mess).^2))^0.5;
    error2 = (((I_modelo2 - I_mess).^2)).^0.5;
    
    I(:,3) = I_modelo2(:);
    E(:,3) = error2(:);
    
    rmse(s).an2D2R = RMSE(Isc, I_mess, I(:,3), length(I(:,3)));
    
    % Error
%     pos = strjoin({'C',num2str(s+1)},'');
%     A = round(rmse,3,'significant');
%     if save_error == 1
%         xlswrite(save_filename,A,'hoja1',pos);
%     end
    
    %% Modelo 2D2R numerico
%     umin = [numerico_2D2R(s).Ipv, numerico_2D2R(s).I01, numerico_2D2R(s).I02,...
%      numerico_2D2R(s).Rs, numerico_2D2R(s).Rsh, numerico_2D2R(s).a1,...
%      numerico_2D2R(s).a2];
    
    % Discretizacion de la solucion para representarla
%     I_modelo2 = zeros(size(V_mess,2),1)';
%     for i=1:size(V_mess,2)
%         I_modelo2(i) = Panel_Current_2D2R(umin,V_mess(i));
%     end

    I_modelo2 = Datos_numericos_2D2R(s).I_modelo2;
    error = (sum((I_modelo2 - I_mess).^2))^0.5;
    error2 = (((I_modelo2 - I_mess).^2)).^0.5;
    
    I(:,4) = I_modelo2(:);
    E(:,4) = error2(:);
    
    rmse(s).num2D2R = RMSE(Isc, I_mess, I(:,4), length(I(:,4)));
    
    % Error
%     pos = strjoin({'D',num2str(s+1)},'');
%     A = round(rmse,3,'significant');
%     if save_error == 1
%         xlswrite(save_filename,A,'hoja1',pos);
%     end
    
    %% PLOTS
       


    gray = [1,1,1]*0.65;
    % Modelos 
    h_ = figure();
    hold on   
%     plot(V_mess, I_mess, 'o', 'LineWidth', 1, 'Color', 'k','DisplayName', 'Experimental')
%     plot(V_mess, I(:,1), '-', 'LineWidth', 1.5, 'Color', gray, 'DisplayName', '1D2R Analitico')
%     plot(V_mess, I(:,2), '-.', 'LineWidth', 1.5, 'Color', gray, 'DisplayName', '1D2R Numerico')
%     plot(V_mess, I(:,3), ':', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', '2D2R Analitico')
%     plot(V_mess, I(:,4), '--', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', '2D2R Numerico')
%     scatter([0 Vmp Voc], [Isc Imp 0], 50, 'k', 'filled','o', 'DisplayName', 'Puntos caracteristicos')
    plot(V_mess, I_mess, '-', 'LineWidth', 1, 'Color', 'k','DisplayName', 'Experimental')
    plot(V_mess, I(:,1), '-', 'LineWidth', 1.5, 'Color', [0, 0.4470, 0.7410], 'DisplayName', '1D2R Analitico')
    plot(V_mess, I(:,2), '-', 'LineWidth', 1.5, 'Color', [0.8500, 0.3250, 0.0980], 'DisplayName', '1D2R Numerico')
    plot(V_mess, I(:,3), '-', 'LineWidth', 1.5, 'Color', [0.4660, 0.6740, 0.1880], 'DisplayName', '2D2R Analitico')
    plot(V_mess, I(:,4), '-', 'LineWidth', 1.5, 'Color', [0.75, 0, 0.75], 'DisplayName', '2D2R Numerico')
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
%     plot(V_mess, E(:,1), '-', 'LineWidth', 1.5, 'Color', gray, 'DisplayName', '1D2R Analitico')
%     plot(V_mess, E(:,2), '-.', 'LineWidth', 1.5, 'Color', gray, 'DisplayName', '1D2R Numerico')
%     plot(V_mess, E(:,3), ':', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', '2D2R Analitico')
%     plot(V_mess, E(:,4), '--', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', '2D2R Numerico')
    plot(V_mess, E(:,1), '-', 'LineWidth', 1.5, 'Color', [0, 0.4470, 0.7410], 'DisplayName', '1D2R Analitico')
    plot(V_mess, E(:,2), '-', 'LineWidth', 1.5, 'Color', [0.8500, 0.3250, 0.0980], 'DisplayName', '1D2R Numerico')
    plot(V_mess, E(:,3), '-', 'LineWidth', 1.5, 'Color', [0.4660, 0.6740, 0.1880], 'DisplayName', '2D2R Analitico')
    plot(V_mess, E(:,4), '-', 'LineWidth', 1.5, 'Color', [0.75, 0, 0.75], 'DisplayName', '2D2R Numerico')
    hold off
    axis([0, V_mess(end)*1, 0, max(max(E))*1])
    box on; grid on
    xlabel('$V$ [V]','Interpreter','latex')
    ylabel({'$I-I_{exp}$';'[A]'},'Interpreter','latex');
    if s == 10
        legend('Interpreter', 'Latex', 'location', 'West')
    else
        legend('Interpreter', 'Latex', 'location', 'NorthWest')
    end
    
    Save_as_PDF(h_, ['Figuras/Error_', Cells(s).Name],'horizontal', 7.5, 10);

    
end


%% SAVE DATA
fn = fieldnames(rmse);
for k=2:numel(fn)
    for s = 1:11
    rmse(s).(fn{k}) = round(rmse(s).(fn{k}),2);   
    end
end
save('Data/RMSE_3', 'rmse')


%% Histogramas
for s = 1:11
    RMSE(s,:) = [rmse(s).an1D2R, rmse(s).num1D2R, rmse(s).an2D2R, rmse(s).num2D2R];
end
modelos = {"A-1D2R", "N-1D2R", "A-2D2R", "N-2D2R"};

f = figure(12);
    h_ = bar(RMSE','FaceColor','flat');
    cmap = colormap(jet);     
    for k = 1:length(RMSE)
        h_(k).FaceColor = cmap(23*k,:);
    end
     set(gca,'xticklabel',modelos,'TickLabelInterpreter','latex');
     ylabel({'$\xi$';'[$\%$]'},'Interpreter','latex');
     ylim([0 7.5]);
     legend(rmse.Name, 'Interpreter', 'Latex', 'location', 'Eastoutside');   

    Save_as_PDF(f, ['Figuras/Barplot'],'horizontal',-15,0);
    
    
    
%% CURVA CON PUNTOS CARACTERISTICOS
close all

h = figure();
    subplot(2,1,1);
    hold on
    plot(Cells(2).V_mess, Cells(2).I_mess, '-', 'LineWidth', 2, 'Color', 'k','DisplayName', 'Curva $I-V$')
    scatter([0 Cells(2).Vmp Cells(2).Voc], [Cells(2).Isc Cells(2).Imp 0], 50, 'k', 'filled','o', 'DisplayName', 'Puntos caracteristicos')
    legend('Interpreter', 'Latex', 'location', 'SouthWest')
    xlabel('$V$ [V]','Interpreter','latex')
    ylabel({'$I$';'[A]'},'Interpreter','latex');
    Save_as_PDF(h, ['Figuras/Presentacion'],'horizontal');
    
    box on
    subplot(2,1,2); 
    plot(Cells(2).V_mess, Cells(2).I_mess.*Cells(2).V_mess, '-', 'LineWidth', 2, 'Color', 'k','DisplayName', 'Curva $P-V$')
    legend('Interpreter', 'Latex', 'location', 'South')
    xlabel('$V$ [V]','Interpreter','latex')
    ylabel({'$P$';'[W]'},'Interpreter','latex');
    box on
    Save_as_PDF(h, ['Figuras/Presentacion'],'horizontal');
    