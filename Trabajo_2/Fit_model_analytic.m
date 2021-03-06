%%%%% Matriz de puntos caracteristicos de cada IV curve 
clear all
clc
close all

plot_final = 2;

% % Nombre de las hojas del archivo excel
% read_filename = 'IV_curves.xlsx';
sheet = {'RTC France', 'TNJ', 'ZTJ', '3G30C','PWP201', 'KC200GT2', 'SPVSX5',...
         'PSC', 'CTJ30', 'ATJ' '4S1P'};
% % Selección de hoja (s)
% % 1 ---> RTC France
% % 2 ---> TNJ
% % 3 ---> ZTJ
% % 4 ---> 3G30C
% % 5 ---> PWP201
% % 6 ---> KC200GT2
% % 7 ---> SPVSX5
% % 8 ---> PSC
% % 9 ---> CTJ30
% % 10 --> ATJ
% % 11 --> 4S1P 
%1
% %s = 7;
% 
% % Bucle para acceder a cada hoja del excel
% for s = 1:8
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

% Cargar datos de archivo .mat
load('data.mat');

%%
for s = 1:11
    
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

    %% Karmalkar & Haneefa’s model

    K = (1-betha-alpha)/(2*betha-1);
    aux = -(1/alpha)^(1/K)*(1/K)*log(alpha);
    %m = real((lambertw(-1,aux)/log(alpha))+(1/K)+1);
    m = real((lambert(aux)/log(alpha))+(1/K)+1);
    gamma = (2*betha-1)/((m-1)*alpha^m);

    I_Karmalkar_analytic = (1-(1-gamma)*(V_mess/Voc)-gamma*(V_mess/Voc).^m)*Isc;
    
    rmse(1,s) = RMSE(Isc, I_mess, I_Karmalkar_analytic, length(I_Karmalkar_analytic));
    
    save_filename = 'Fit_model_analytic.xlsx';
    save_sheet = 'KyH';
    
    % Name
    pos = strjoin({'A',num2str(s+1)},'');
    A = cellstr(sheet{s});
    % xlswrite(save_filename,A,save_sheet,pos);
    % m
    pos = strjoin({'B',num2str(s+1)},'');
    A = round(m,3,'significant');
    % xlswrite(save_filename,A,save_sheet,pos);
    % gamma
    pos = strjoin({'C',num2str(s+1)},'');
    A = round(gamma,3,'significant');
    % xlswrite(save_filename,A,save_sheet,pos);


    %% Das' model

    aux2 = betha*log(alpha);
    k_Das = lambert(aux2)/log(alpha);
    h = (1/alpha)*((1/betha)-1/k_Das-1);

    I_Das_analytic = ((1-(V_mess./Voc).^k_Das)./(1+h.*(V_mess./Voc))).*Isc;
    
    rmse(2,s) = RMSE(Isc, I_mess, I_Das_analytic, length(I_Das_analytic));
    
    save_filename = 'Fit_model_analytic.xlsx';
    save_sheet = 'Das';
    
    % Name
    pos = strjoin({'A',num2str(s+1)},'');
    A = cellstr(sheet{s});
    % xlswrite(save_filename,A,save_sheet,pos);
    % k_Das
    pos = strjoin({'B',num2str(s+1)},'');
    A = round(k_Das,3,'significant');
    % xlswrite(save_filename,A,save_sheet,pos);
    % h
    pos = strjoin({'C',num2str(s+1)},'');
    A = round(h,3,'significant');
    % xlswrite(save_filename,A,save_sheet,pos);
    
    %% Pindado  & Cubas
    
     % Al ser una función definida a trozos, se define el vector V_mess_tramo2 el
    % cual contiene únicamente valores de V >= Vmp
    V_mess_tramo1 = V_mess(V_mess < Vmp);
    V_mess_tramo2 = V_mess(V_mess >= Vmp);
    I_mess_tramo2 = I_mess((length(V_mess) - length(V_mess_tramo2) + 1):end);
    
    I_tramo1 = Isc*(1-(1-Imp/Isc)*(V_mess_tramo1/Vmp).^(Imp/(Isc-Imp)));
    eta = (Isc/Imp)*(Isc/(Isc-Imp))*((Voc-Vmp)/Voc);
    I_tramo2 = Imp*(Vmp./V_mess_tramo2).*(1-((V_mess_tramo2-Vmp)/(Voc-Vmp)).^eta);
    
    eta_2(s) = (log(Vmp*Imp-V_mess(end-3)*I_mess(end-3))-log(Vmp*Imp))/...
            (log(V_mess(end-3)-Vmp)-log(Voc-Vmp));
        
    if s == 4
        eta_2(s) = (log(Vmp*Imp-V_mess(end-70)*I_mess(end-70))-log(Vmp*Imp))/...
            (log(V_mess(end-70)-Vmp)-log(Voc-Vmp));
    elseif s == 7
        eta_2(s) = (log(Vmp*Imp-V_mess(end-50)*I_mess(end-50))-log(Vmp*Imp))/...
            (log(V_mess(end-50)-Vmp)-log(Voc-Vmp));
    elseif s == 9
        eta_2(s) = (log(Vmp*Imp-V_mess(end-15)*I_mess(end-15))-log(Vmp*Imp))/...
            (log(V_mess(end-15)-Vmp)-log(Voc-Vmp));
    end
        
    I_tramo2_2 = Imp*(Vmp./V_mess_tramo2).*(1-((V_mess_tramo2-Vmp)/(Voc-Vmp)).^eta_2(s));

    I_PC_analytic = [I_tramo1' I_tramo2'];
    I_PC_analytic_2 = [I_tramo1' I_tramo2_2'];
    
    rmse(3,s) = RMSE(Isc, I_mess, I_PC_analytic, length(I_PC_analytic));
    rmse(4,s) = RMSE(Isc, I_mess, I_PC_analytic_2, length(I_PC_analytic_2));
    save_filename = 'Fit_model_analytic.xlsx';
    save_sheet = 'PyC';
    
    % Name
    pos = strjoin({'A',num2str(s+1)},'');
    A = cellstr(sheet{s});
    % xlswrite(save_filename,A,save_sheet,pos);
    % eta
    pos = strjoin({'B',num2str(s+1)},'');
    A = round(eta,3,'significant');
    % xlswrite(save_filename,A,save_sheet,pos);
    % eta2
    pos = strjoin({'C',num2str(s+1)},'');
    A = round(eta_2,3,'significant');
    % xlswrite(save_filename,A,save_sheet,pos);
    
    %% Figura final
        % Plot de valores experimentales, Karmalkar y Das analytic
    switch plot_final
        
        case 1
            h_ = figure(2);
            hold on
            % Plotear solo ciertos puntos
            if (s == 4 | s == 7)
                plot(V_mess(1:10:end)', I_mess(1:10:end)', 'o', 'LineWidth', 1,...
                'Color', 'k','DisplayName', ["Valores experimentales"])
            else
                plot(V_mess, I_mess, 'o', 'LineWidth', 1, 'Color', 'k','DisplayName', ...
                    ["Valores experimentales"])
            end
%             plot(V_mess, I_Karmalkar_analytic, '-', 'LineWidth', 2, 'Color', [0.8500, 0.3250, 0.0980], 'DisplayName', "Karmalkar \& Haneefa anal\'itico")
%             plot(V_mess, I_Das_analytic, '-', 'LineWidth', 2, 'Color', [0.4660, 0.6740, 0.1880], 'DisplayName', "Das anal\'itico")
%             plot(V_mess, I_PC_analytic, '-', 'LineWidth', 2, 'Color', [0.3010, 0.7450, 0.9330],'DisplayName', ...
%                 ["Pindado \& Cubas anal\'itico"])
            plot(V_mess, I_Karmalkar_analytic, '-', 'LineWidth', 2, 'Color', [0, 0.4470, 0.7410], 'DisplayName', "Karmalkar \& Haneefa anal\'itico")
            plot(V_mess, I_Das_analytic, '-', 'LineWidth', 2, 'Color', [0.8500, 0.3250, 0.0980], 'DisplayName', "Das anal\'itico")
            plot(V_mess, I_PC_analytic, '-', 'LineWidth', 2, 'Color', [0.4660, 0.6740, 0.1880],'DisplayName', ...
                ["Pindado \& Cubas anal\'itico"])

            %scatter([0 Vmp Voc], [Isc Imp 0], 50, 'k', 'filled','o', 'DisplayName', 'Puntos caracteristicos')
            axis([0, V_mess(end)*1.1, 0, I_mess(1)*1.1])
            hold off
            box on; grid on
            xlabel('$V$ [V]','Interpreter','latex')
            ylabel({'$I$';'[A]'},'Interpreter','latex')
            legend('Interpreter', 'Latex', 'location', 'SouthWest')
%             Save_as_PDF(h_, ['Figuras/1_An_', sheet{s}], 'horizontal');
        
        case 2
            Ek = abs(I_Karmalkar_analytic - I_mess);
            Ed = abs(I_Das_analytic - I_mess);
            Ep = abs(I_PC_analytic - I_mess')'; 
           
           h_ = figure(s);
                hold on
%                 plot(V_mess, I_Karmalkar_analytic - I_mess, '-', 'LineWidth', 2, 'Color', [0.8500, 0.3250, 0.0980],'DisplayName', ...
%                     ["Karmalkar \& Haneefa num\'erico"])
%                 plot(V_mess, I_Das_analytic - I_mess, '-', 'LineWidth', 2, 'Color', [0.4660, 0.6740, 0.1880],'DisplayName', ...
%                     ["Das num\'erico"])
%                 plot(V_mess, I_PC_analytic - I_mess', '-', 'LineWidth', 2, 'Color', [0.3010, 0.7450, 0.9330],'DisplayName', ...
%                     ["Pindado \& Cubas num\'erico"])
                plot(V_mess, Ek, '-', 'LineWidth', 2, 'Color', [0, 0.4470, 0.7410],'DisplayName', ...
                    ["Karmalkar \& Haneefa num\'erico"])
                plot(V_mess, Ed, '-', 'LineWidth', 2, 'Color', [0.8500, 0.3250, 0.0980],'DisplayName', ...
                    ["Das num\'erico"])
                plot(V_mess, Ep, '-', 'LineWidth', 2, 'Color', [0.4660, 0.6740, 0.1880],'DisplayName', ...
                    ["Pindado \& Cubas num\'erico"])
                axis([0, V_mess(end), 0, max(max([Ek, Ed, Ep]))])
                box on; grid on
                legend('Interpreter', 'Latex', 'location', 'NorthWest')
                xlabel('$V$ [V]','Interpreter','latex');
                ylabel({'$I-I_{exp}$';'[A]'},'Interpreter','latex');
                Save_as_PDF(h_, ['Figuras/1_An_dif_', sheet{s}],'horizontal', 7.5, 10);
                hold off
                disp(sheet{s})
        otherwise
            disp('Has puesto el plot_final mal.')
            
    end
close all            
end

%%
modelos = {'K $\&$ H', 'Das', 'P $\&$ C', 'P $\&$ C*'};

f = figure(12);
    h_ = bar(rmse,'FaceColor','flat');
    set(gca,'xticklabel',modelos,'TickLabelInterpreter','latex');
    ylabel({'$\xi$';'[$\%$]'},'Interpreter','latex');
    legend(sheet, 'Interpreter', 'Latex', 'location', 'Eastoutside');
    
    cmap = colormap(jet);
    
    for k = 1:size(rmse,2)
        h_(k).FaceColor = cmap(23*k,:);
    end
    
    Save_as_PDF(f, ['Figuras/1_An_barplot'],'horizontal',-12.5,0);
    
    