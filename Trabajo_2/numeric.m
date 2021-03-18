clear all;
close all;
clc;

% Nombre de las hojas del archivo excel
sheet = {'RTC France', 'TNJ', 'ZTJ', '3G30C','PWP201', 'KC200GT2', 'SPVSX5',...
         'PSC', 'CTJ30', 'ATJ'};

% Selección de hoja (s)
% 1 ---> RTC France
% 2 ---> TNJ
% 3 ---> ZTJ
% 4 ---> 3G30C
% 5 ---> PWP201
% 6 ---> KC200GT2
% 7 ---> SPVSX5
% 8 ---> PSC

% Digitalizadas por nosotros
% 9 ---> CTJ30
% 10 --> ATJ

% % Carga de valores experimentales y datos del fabricante
% for s = 1:10
%     data{s,1} = xlsread('IV_curves.xlsx', sheet{s}, 'A21:A1202');
%     data{s,2} = xlsread('IV_curves.xlsx', sheet{s}, 'B21:B1202');
%     data{s,3} = xlsread('IV_curves.xlsx', sheet{s}, 'B1');
%     data{s,4} = xlsread('IV_curves.xlsx', sheet{s}, 'B2');
%     data{s,5} = xlsread('IV_curves.xlsx', sheet{s}, 'B3');
%     data{s,6} = xlsread('IV_curves.xlsx', sheet{s}, 'B4');
%     data{s,7} = xlsread('IV_curves.xlsx', sheet{s}, 'B5');
%     data{s,8} = xlsread('IV_curves.xlsx', sheet{s}, 'B6');
% end

% Cargar datos de archivo .mat
load('data.mat');

for s = 1:10
    
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


    % Plot de valores experimentales
%     h_ = figure(1);
%         hold on
%         plot(V_mess, I_mess, '-.', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
%             ["Valores experimentales"])
%         plot([0 Vmp Voc], [Isc Imp 0], 'o', 'MarkerSize', 10, 'Color', 'k',...
%             'DisplayName', ["Datos fabricante"])
%         axis([0, V_mess(end)*1.1, 0, I_mess(1)*1.1])
%         box on; grid on
%         legend('Interpreter', 'Latex', 'location', 'SouthWest')
%         xlabel('$V$ [V]','Interpreter','latex');
%         ylabel({'$I$';'[A]'},'Interpreter','latex');
%         Save_as_PDF(h_, ['Figuras/valores_exp_', sheet{s}],'horizontal');
%         hold off

    %% Karmalkar & Haneefa numérico

    v_mess = V_mess/Voc;
    i_mess = I_mess/Isc;
    
    if (s == 1 | s == 6)
        beta0 = [9 1];
    elseif (s == 4)
        beta0 = [30 2];
    elseif (s == 9)
        beta0 = [1.5 1.5];
    else
        beta0 = [1 1];
    end

    for i = 1:5
        Kalmarkar_fun = @(p,v) 1-(1-p(1))*v - p(1)*v.^p(2);

        mdl_K = fitnlm(v_mess, i_mess, Kalmarkar_fun, beta0);

        gamma(i) = table2array(mdl_K.Coefficients(1,1));
        m(i) = table2array(mdl_K.Coefficients(2,1));
        Error_K(i) = mdl_K.RMSE;

        beta0 =[gamma(i) m(i)];

    end

    I_Ksol = (1-(1-gamma(end))*v_mess - gamma(end)*v_mess.^m(end))*Isc;

%     h_ = figure(2);
%         hold on
%         plot(V_mess, I_mess, '-.', 'LineWidth', 1.5, 'Color', 'k','DisplayName', ...
%             ["Valores experimentales"])
%         plot(V_mess, I_Ksol, '-', 'LineWidth', 1.5, 'Color', 'k','DisplayName', ...
%             ["Karmalkar \& Haneefa num\'erico"])
%         axis([0, V_mess(end)*1.1, 0, I_mess(1)*1.1])
%         box on; grid on
%         legend('Interpreter', 'Latex', 'location', 'SouthWest')
%         xlabel('$V$ [V]','Interpreter','latex');
%         ylabel({'$I$';'[A]'},'Interpreter','latex');
%         Save_as_PDF(h_, ['Figuras/1_Nu_KyH_', sheet{s}],'horizontal');
%         hold off
    
%     save_filename = 'numeric.xlsx';
%     save_sheet = 'KyH';
%     
%     % Name
%     pos = strjoin({'A',num2str(s+1)},'');
%     A = cellstr(sheet{s});
%     xlswrite(save_filename,A,save_sheet,pos);
%     % m
%     pos = strjoin({'B',num2str(s+1)},'');
%     A = round(m(i),3,'significant');
%     xlswrite(save_filename,A,save_sheet,pos);
%     % gamma
%     pos = strjoin({'C',num2str(s+1)},'');
%     A = round(gamma(i),3,'significant');
%     xlswrite(save_filename,A,save_sheet,pos);
%     % Error_K
%     pos = strjoin({'D',num2str(s+1)},'');
%     A = round(Error_K(i),3,'significant');
%     xlswrite(save_filename,A,save_sheet,pos);


    %% Das numérico

    beta0 = [1.5 1.5];

    for i = 1:5
        Das_fun = @(p,v) (1-v.^p(1))./(1+p(2)*v);

        mdl_D = fitnlm(v_mess, i_mess, Das_fun, beta0);

        k(i) = table2array(mdl_D.Coefficients(1,1));
        h(i) = table2array(mdl_D.Coefficients(2,1));
        Error_D(i) = mdl_D.RMSE;

        beta0 =[k(i) h(i)];

    end

    I_Dsol = (1-v_mess.^k(end))./(1+h(end)*v_mess)*Isc;

%     h_ = figure(3);
%         hold on
%         plot(V_mess, I_mess, '-.', 'LineWidth', 1.5, 'Color', 'k','DisplayName', ...
%             ["Valores experimentales"])
%         plot(V_mess, I_Dsol, '-', 'LineWidth', 1.5, 'Color', 'k','DisplayName', ...
%             ["Das num\'erico"])
%         axis([0, V_mess(end)*1.1, 0, I_mess(1)*1.1])
%         box on; grid on
%         legend('Interpreter', 'Latex', 'location', 'SouthWest')
%         xlabel('$V$ [V]','Interpreter','latex');
%         ylabel({'$I$';'[A]'},'Interpreter','latex');
%         Save_as_PDF(h_, ['Figuras/1_Nu_Das_', sheet{s}],'horizontal');
%         hold off
        
%     save_filename = 'numeric.xlsx';
%     save_sheet = 'Das';
%     
%     % Name
%     pos = strjoin({'A',num2str(s+1)},'');
%     A = cellstr(sheet{s});
%     xlswrite(save_filename,A,save_sheet,pos);
%     % k_Das
%     pos = strjoin({'B',num2str(s+1)},'');
%     A = round(k(i),3,'significant');
%     xlswrite(save_filename,A,save_sheet,pos);
%     % h
%     pos = strjoin({'C',num2str(s+1)},'');
%     A = round(h(i),3,'significant');
%     xlswrite(save_filename,A,save_sheet,pos);
%     % Error_D
%     pos = strjoin({'D',num2str(s+1)},'');
%     A = round(Error_D(i),3,'significant');
%     xlswrite(save_filename,A,save_sheet,pos);

    %% Pindado & Cubas numérico

    beta0 = 1;

    % Al ser una función definida a trozos, se define el vector V_mess_tramo2 el
    % cual contiene únicamente valores de V >= Vmp
    V_mess_tramo1 = V_mess(V_mess < Vmp);
    V_mess_tramo2 = V_mess(V_mess >= Vmp);
    I_mess_tramo2 = I_mess((length(V_mess) - length(V_mess_tramo2) + 1):end);

    for i = 1:5

        PC_fun = @(p,V) Imp*(Vmp./V).*(1-((V-Vmp)/(Voc-Vmp)).^p);

        mdl_PC = fitnlm(V_mess_tramo2, I_mess_tramo2, PC_fun, beta0);

        phi(i) = table2array(mdl_PC.Coefficients(1,1));
        Error_PC(i) = mdl_PC.RMSE;

        beta0 = phi(i);

    end

    I_tramo1 = Isc*(1-(1-Imp/Isc)*(V_mess_tramo1/Vmp).^(Imp/(Isc-Imp)));
    I_tramo2 = Imp*(Vmp./V_mess_tramo2).*(1-((V_mess_tramo2-Vmp)/(Voc-Vmp)).^phi(end));

    I_PCsol = [I_tramo1' I_tramo2'];

    
%     h_ = figure(4);
%         hold on
%         plot(V_mess, I_mess, '-.', 'LineWidth', 1.5, 'Color', 'k','DisplayName', ...
%             ["Valores experimentales"])
%         plot(V_mess, I_PCsol, '-', 'LineWidth', 1.5, 'Color', 'k','DisplayName', ...
%             ["Pindado \& Cubas num\'erico"])
%         axis([0, V_mess(end)*1.1, 0, I_mess(1)*1.1])
%         box on; grid on
%         legend('Interpreter', 'Latex', 'location', 'SouthWest')
%         xlabel('$V$ [V]','Interpreter','latex');
%         ylabel({'$I$';'[A]'},'Interpreter','latex');
%         Save_as_PDF(h_, ['Figuras/1_Nu_PyC_', sheet{s}],'horizontal');
%         hold off
        
%     save_filename = 'numeric.xlsx';
%     save_sheet = 'PyC';
%     
%     % Name
%     pos = strjoin({'A',num2str(s+1)},'');
%     A = cellstr(sheet{s});
%     xlswrite(save_filename,A,save_sheet,pos);
%     % phi
%     pos = strjoin({'B',num2str(s+1)},'');
%     A = round(phi(i),3,'significant');
%     xlswrite(save_filename,A,save_sheet,pos);
%     % Error_PC
%     pos = strjoin({'C',num2str(s+1)},'');
%     A = round(Error_PC(i),3,'significant');
%     xlswrite(save_filename,A,save_sheet,pos);

    %% Plot final

    h_ = figure(s);
        hold on
        % Plotear solo ciertos puntos
        if (s == 4 | s == 7)
            plot(V_mess(1:10:end)', I_mess(1:10:end)', '-o', 'LineWidth', 1,...
            'Color', 'k','DisplayName', ["Valores experimentales"])
        else
            plot(V_mess, I_mess, '-o', 'LineWidth', 1, 'Color', 'k','DisplayName', ...
                ["Valores experimentales"])
        end
        plot(V_mess, I_Ksol, '-', 'LineWidth', 1, 'Color', 'r','DisplayName', ...
            ["Karmalkar \& Haneefa num\'erico"])
        plot(V_mess, I_Dsol, '-', 'LineWidth', 1, 'Color', 'b','DisplayName', ...
            ["Das num\'erico"])
        plot(V_mess, I_PCsol, '-', 'LineWidth', 1, 'Color', 'g','DisplayName', ...
            ["Pindado \& Cubas num\'erico"])
        axis([0, V_mess(end)*1.1, 0, I_mess(1)*1.1])
        box on; grid on
        legend('Interpreter', 'Latex', 'location', 'SouthWest')
        xlabel('$V$ [V]','Interpreter','latex');
        ylabel({'$I$';'[A]'},'Interpreter','latex');
        %Save_as_PDF(h_, ['Figuras/1_Nu_', sheet{s}],'horizontal');
        hold off

end

%% DHV
clear all;
close all;
clc;

% Carga de valores experimentales y datos del fabricante
sheet_DHV = {'4S1P', '4S4P', '7S1P', '8S5P'};

for s = 1:2
    data_DHV{s,1} = xlsread('curvas_DHV.xlsx', sheet_DHV{s}, 'A5:A25');
    data_DHV{s,2} = xlsread('curvas_DHV.xlsx', sheet_DHV{s}, 'B5:B25');
end


