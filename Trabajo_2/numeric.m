clear all;
close all;
clc;

for s = 1:8
    % Nombre de las hojas del archivo excel
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
    
    % Carga de valores experimentales
    V_mess = xlsread('IV_curves.xlsx', sheet{s}, 'A21:A1202');
    I_mess = xlsread('IV_curves.xlsx', sheet{s}, 'B21:B1202');

    % Carga de datos del fabricante
    Isc = xlsread('IV_curves.xlsx', sheet{s}, 'B1');
    Imp = xlsread('IV_curves.xlsx', sheet{s}, 'B2');
    Vmp = xlsread('IV_curves.xlsx', sheet{s}, 'B3');
    Voc = xlsread('IV_curves.xlsx', sheet{s}, 'B4');
    betha = xlsread('IV_curves.xlsx', sheet{s}, 'B5');
    alpha = xlsread('IV_curves.xlsx', sheet{s}, 'B6');


    % Plot de valores experimentales
    h_ = figure(1);
        hold on
        plot(V_mess, I_mess, '-.', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
            ["Valores experimentales"])
        plot([0 Vmp Voc], [Isc Imp 0], 'o', 'MarkerSize', 10, 'Color', 'k',...
            'DisplayName', ["Datos fabricante"])
        axis([0, V_mess(end)*1.1, 0, I_mess(1)*1.1])
        box on; grid on
        legend('Interpreter', 'Latex', 'location', 'Best')
        xlabel('$V$ [V]','Interpreter','latex');
        ylabel({'$I$';'[A]'},'Interpreter','latex');
        Save_as_PDF(h_, ['Figuras/valores_exp_', sheet{s}],'horizontal');
        hold off

    %% Karmalkar & Haneefa numérico

    v_mess = V_mess/Voc;
    i_mess = I_mess/Isc;

    beta0 = [1 1];

    for i = 1:5
        Kalmarkar_fun = @(p,v) 1-(1-p(1))*v - p(1)*v.^p(2);

        mdl_K = fitnlm(v_mess, i_mess, Kalmarkar_fun, beta0);

        gamma(i) = table2array(mdl_K.Coefficients(1,1));
        m(i) = table2array(mdl_K.Coefficients(2,1));
        Error_K(i) = mdl_K.RMSE;

        beta0 =[gamma(i) m(i)];

    end

    I_Ksol = (1-(1-gamma(end))*v_mess - gamma(end)*v_mess.^m(end))*Isc;

    h_ = figure(2);
        hold on
        plot(V_mess, I_mess, '-.', 'LineWidth', 1.5, 'Color', 'k','DisplayName', ...
            ["Valores experimentales"])
        plot(V_mess, I_Ksol, '-', 'LineWidth', 1.5, 'Color', 'k','DisplayName', ...
            ["Karmalkar \& Haneefa num\'erico"])
        axis([0, V_mess(end)*1.1, 0, I_mess(1)*1.1])
        box on; grid on
        legend('Interpreter', 'Latex', 'location', 'Best')
        xlabel('$V$ [V]','Interpreter','latex');
        ylabel({'$I$';'[A]'},'Interpreter','latex');
        Save_as_PDF(h_, ['Figuras/1_Nu_KyH_', sheet{s}],...
            'horizontal');
        hold off
    
    save_filename = 'numeric.xlsx';
    save_sheet = 'KyH';
    
    % Name
    pos = strjoin({'A',num2str(s+1)},'');
    A = cellstr(sheet{s});
    xlswrite(save_filename,A,save_sheet,pos);
    % m
    pos = strjoin({'B',num2str(s+1)},'');
    A = round(m(i),3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % gamma
    pos = strjoin({'C',num2str(s+1)},'');
    A = round(gamma(i),3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % Error_K
    pos = strjoin({'D',num2str(s+1)},'');
    A = round(Error_K(i),3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);


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

    h_ = figure(3);
        hold on
        plot(V_mess, I_mess, '-.', 'LineWidth', 1.5, 'Color', 'k','DisplayName', ...
            ["Valores experimentales"])
        plot(V_mess, I_Dsol, '-', 'LineWidth', 1.5, 'Color', 'k','DisplayName', ...
            ["Das num\'erico"])
        axis([0, V_mess(end)*1.1, 0, I_mess(1)*1.1])
        box on; grid on
        legend('Interpreter', 'Latex', 'location', 'Best')
        xlabel('$V$ [V]','Interpreter','latex');
        ylabel({'$I$';'[A]'},'Interpreter','latex');
        Save_as_PDF(h_, ['Figuras/1_Nu_Das_', sheet{s}],'horizontal');
        hold off
        
    save_filename = 'numeric.xlsx';
    save_sheet = 'Das';
    
    % Name
    pos = strjoin({'A',num2str(s+1)},'');
    A = cellstr(sheet{s});
    xlswrite(save_filename,A,save_sheet,pos);
    % k_Das
    pos = strjoin({'B',num2str(s+1)},'');
    A = round(k(i),3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % h
    pos = strjoin({'C',num2str(s+1)},'');
    A = round(h(i),3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % Error_D
    pos = strjoin({'D',num2str(s+1)},'');
    A = round(Error_D(i),3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);

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

    h_ = figure(4);
        hold on
        plot(V_mess, I_mess, '-.', 'LineWidth', 1.5, 'Color', 'k','DisplayName', ...
            ["Valores experimentales"])
        plot(V_mess, I_PCsol, '-', 'LineWidth', 1.5, 'Color', 'k','DisplayName', ...
            ["Pindado \& Cubas num\'erico"])
        axis([0, V_mess(end)*1.1, 0, I_mess(1)*1.1])
        box on; grid on
        legend('Interpreter', 'Latex', 'location', 'Best')
        xlabel('$V$ [V]','Interpreter','latex');
        ylabel({'$I$';'[A]'},'Interpreter','latex');
        Save_as_PDF(h_, ['Figuras/1_Nu_PyC_', sheet{s}],'horizontal');
        hold off
%         
    save_filename = 'numeric.xlsx';
    save_sheet = 'PyC';
    
    % Name
    pos = strjoin({'A',num2str(s+1)},'');
    A = cellstr(sheet{s});
    xlswrite(save_filename,A,save_sheet,pos);
    % phi
    pos = strjoin({'B',num2str(s+1)},'');
    A = round(phi(i),3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % Error_PC
    pos = strjoin({'C',num2str(s+1)},'');
    A = round(Error_PC(i),3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);

     
    if s ~= 8
        clear all;
        close all;
    end

end