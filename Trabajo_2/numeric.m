clear all;
close all;
clc;

% Nombre de las hojas del archivo excel
sheet = {'RTC France', 'TNJ', 'ZTJ', '3G30C','PWP201', 'KC200GT2', 'SPVSX5',...
         'PSC', 'CTJ30', 'ATJ', '4S1P'};

plot_final = 2;

% sheet_DHV = {'4S1P', '4S4P', '7S1P', '8S5P'};

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
% 11 --> 4S1P

% % Carga de valores experimentales y datos del fabricante
% for s = 1:length(sheet)
%     data{s,1} = xlsread('IV_curves.xlsx', sheet{s}, 'A21:A1202');
%     data{s,2} = xlsread('IV_curves.xlsx', sheet{s}, 'B21:B1202');
%     data{s,3} = xlsread('IV_curves.xlsx', sheet{s}, 'B1');
%     data{s,4} = xlsread('IV_curves.xlsx', sheet{s}, 'B2');
%     data{s,5} = xlsread('IV_curves.xlsx', sheet{s}, 'B3');
%     data{s,6} = xlsread('IV_curves.xlsx', sheet{s}, 'B4');
%     data{s,7} = xlsread('IV_curves.xlsx', sheet{s}, 'B5');
%     data{s,8} = xlsread('IV_curves.xlsx', sheet{s}, 'B6');
% end

% for s = 1:4
%     data_DHV{s,1} = xlsread('curvas_DHV.xlsx', sheet_DHV{s}, 'A5:A25');
%     data_DHV{s,2} = xlsread('curvas_DHV.xlsx', sheet_DHV{s}, 'B5:B25');
%     data_DHV{s,3} = xlsread('curvas_DHV.xlsx', sheet_DHV{s}, 'A2');
%     data_DHV{s,4} = xlsread('curvas_DHV.xlsx', sheet_DHV{s}, 'B2');
% end

% Cargar datos de archivo .mat
load('data.mat');

for s = 1:length(sheet)
    
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

        gamma(s,i) = table2array(mdl_K.Coefficients(1,1));
        m(s,i) = table2array(mdl_K.Coefficients(2,1));
        Error_K(s,i) = mdl_K.RMSE;
        beta0 =[gamma(s,i) m(s,i)];
    end
    En_K(s,:) = round(Error_K(s,:)/Isc,4)*100;
    
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

        k(s,i) = table2array(mdl_D.Coefficients(1,1));
        h(s,i) = table2array(mdl_D.Coefficients(2,1));
        Error_D(s, i) = mdl_D.RMSE;
        beta0 =[k(s,i) h(s,i)];
    end
    En_D(s,:) = round(Error_D(s,:)/Isc,4)*100;

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

        phi(s,i) = table2array(mdl_PC.Coefficients(1,1));
        Error_PC(s,i) = mdl_PC.RMSE;
        beta0 = phi(s,i);

    end
    En_PC(s,:) = round(Error_PC(s,:)/Isc,4)*100;
    
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

    switch plot_final
        
        case 1
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
                plot(V_mess, I_Ksol, '-', 'LineWidth', 2, 'Color', [0.8500, 0.3250, 0.0980]	,'DisplayName', ...
                    ["Karmalkar \& Haneefa num\'erico"])
                plot(V_mess, I_Dsol, '-', 'LineWidth', 2, 'Color', [0.4660, 0.6740, 0.1880],'DisplayName', ...
                    ["Das num\'erico"])
                plot(V_mess, I_PCsol, '-', 'LineWidth', 2, 'Color', [0.3010, 0.7450, 0.9330],'DisplayName', ...
                    ["Pindado \& Cubas num\'erico"])
                axis([0, V_mess(end)*1.1, 0, I_mess(1)*1.1])
                box on; grid on
                legend('Interpreter', 'Latex', 'location', 'SouthWest')
                xlabel('$V$ [V]','Interpreter','latex');
                ylabel({'$I$';'[A]'},'Interpreter','latex');
                Save_as_PDF(h_, ['Figuras/1_Nu_', sheet{s}],'horizontal',1);
                hold off
                
        case 2
            h_ = figure(s);
                hold on
                plot(V_mess, I_Ksol - I_mess, '-', 'LineWidth', 2, 'Color', [0.8500, 0.3250, 0.0980],'DisplayName', ...
                    ["Karmalkar \& Haneefa num\'erico"])
                plot(V_mess, I_Dsol - I_mess, '-', 'LineWidth', 2, 'Color', [0.4660, 0.6740, 0.1880],'DisplayName', ...
                    ["Das num\'erico"])
                plot(V_mess, I_PCsol - I_mess', '-', 'LineWidth', 2, 'Color', [0.3010, 0.7450, 0.9330],'DisplayName', ...
                    ["Pindado \& Cubas num\'erico"])
                %axis([0, V_mess(end)*1.1, 0, I_mess(1)*1.1])
                box on; grid on
                legend('Interpreter', 'Latex', 'location', 'SouthWest')
                xlabel('$V$ [V]','Interpreter','latex');
                ylabel({'$I-I_{exp}$';'[A]'},'Interpreter','latex');
                Save_as_PDF(h_, ['Figuras/1_Nu_dif_', sheet{s}],'horizontal', 7.5, 10);
                hold off
                
        otherwise
            disp('Has puesto el plot_final mal.')
            
    end

end

%% DHV

% % Carga de valores experimentales y datos del fabricante
% sheet_DHV = {'4S1P', '4S4P', '7S1P', '8S5P'};
% 
% % for s = 1:4
% %     data_DHV{s,1} = xlsread('curvas_DHV.xlsx', sheet_DHV{s}, 'A5:A25');
% %     data_DHV{s,2} = xlsread('curvas_DHV.xlsx', sheet_DHV{s}, 'B5:B25');
% %     data_DHV{s,3} = xlsread('curvas_DHV.xlsx', sheet_DHV{s}, 'A2');
% %     data_DHV{s,4} = xlsread('curvas_DHV.xlsx', sheet_DHV{s}, 'B2');
% % end
% 
% load('data_DHV');
% 
% for s = 1
%     
%     % Carga de valores experimentales
%     V_mess = data_DHV{s,1};
%     I_mess = data_DHV{s,2};
%     P_mess = V_mess.*I_mess;
%     
%     h_ = figure(12);
%         hold on
%         plot(V_mess, I_mess, '-', 'LineWidth', 1, 'Color', 'g','DisplayName', ...
%             ["data"])
%         axis([0, V_mess(end)*1.1, 0, I_mess(1)*1.1])
%         box on; grid on
%         legend('Interpreter', 'Latex', 'location', 'SouthWest')
%         xlabel('$V$ [V]','Interpreter','latex');
%         ylabel({'$I$';'[A]'},'Interpreter','latex');
%         %Save_as_PDF(h_, ['Figuras/1_Nu_', sheet{s}],'horizontal');
%         hold off
% end
% 
% 
% posx = V_mess(V_mess >= 8 &  V_mess <= 10.5);
% 
% [fit1, bondad] = fit(posx, P_mess(7:18), 'poly4');
% coeff = coeffvalues(fit1);
% 
% x = linspace(8, 10.5, 100);
% 
% for i = 1:100
%     P(i) = coeff(1)*x(i)^4 + coeff(2)*x(i)^3 + coeff(3)*x(i)^2 + coeff(4)*x(i) + coeff(5);
% end
% 
% [P_mp, pos_max] = max(P);
% V_mp = x(pos_max);
% pos_mp = 15;
% I_mp = I_mess(pos_mp);
% 
% 
% [fit2, bondad2] = fit(V_mess((end-5):end), I_mess((end-5):end), 'poly2');
% coeff2 = coeffvalues(fit2);
% 
% x2 = linspace(V_mess(end-5), V_mess(end), 100);
% 
% % for i =1:100
% %     I(i) = coeff2(1)*x(i)^2 + coeff2(2)*x(i) + coeff(3);
% % end
% V_oc = roots(coeff2');
% 
% [fit3, bondad3] = fit(V_mess(1:5), I_mess(1:5), 'poly1');
% coeff3 = coeffvalues(fit3);
% Isc = coeff3(2);