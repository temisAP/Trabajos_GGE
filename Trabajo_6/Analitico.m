clc
clear
close all

%% LOAD DATA

load('Data/Bateria_Dinamica_Experimental.mat')


h = figure();
    subplot(2,1,1)
    plot(Data.t, Data.V, 'k', 'LineWidth', 1.5)
    xlim([0, Data.t(end)])
    xlabel('t [s]', 'Interpreter', 'Latex')
    ylabel({'V'; '[V]'}, 'Interpreter', 'Latex')
    grid on; box on
    Save_as_PDF(h, 'Figures/V_vs_t', 'horizontal');
    subplot(2,1,2)
    hold on
    plot(Data.I, 'k', 'LineWidth', 1.5)
    xlim([0, Data.t(end)])
    ylim([-5, 1.5])
    xlabel('t [s]', 'Interpreter', 'Latex')
    ylabel({'I'; '[A]'}, 'Interpreter', 'Latex')
    grid on; box on
  
    Save_as_PDF(h, 'Figures/V_vs_t', 'horizontal');
    
%% SEPARAR CURVAS A ESTUDIAR

% Curvas de descarga
curva(1).Tipo = 'Descarga';
curva(1).V = Data.V(3:1500);
curva(1).t = Data.t(3:1500) - Data.t(3);
curva(1).I = Data.I(3);
curva(1).difI = Data.I(3) - 0;

curva(2).Tipo = 'Descarga';
curva(2).V = Data.V(6510:end);
curva(2).t = Data.t(6510:end) - Data.t(6510);
curva(2).I = Data.I(6510);
curva(2).difI = Data.I(6510) - Data.I(6509);

% Curvas de carga
curva(3).Tipo = 'Carga';
curva(3).V = Data.V(1776:3550);
curva(3).t = Data.t(1776:3550) - Data.t(1776);
curva(3).I = Data.I(1776);
curva(3).difI = Data.I(1776) - Data.I(1775);
curva(4).Tipo = 'Carga';
curva(4).V = Data.V(5327:6509);
curva(4).t = Data.t(5327:6509) - Data.t(5327);
curva(4).I = Data.I(5327);
curva(4).difI = Data.I(5327) - Data.I(5326);


% Representacion todas curvas
colors = [0, 0.4470, 0.7410;
          [220,20,6]/255;
          [255,140,0]/255;
          [139,0,139]/255;
          [50,205,50]/255];

h = figure();
    hold on
    for c = 1:length(curva)
        plot(curva(c).t, curva(c).V, 'Linewidth', 1.5, 'Color', colors(c,:),...
            'DisplayName', [curva(c).Tipo ' a I = ' num2str(abs(round(curva(c).I,1))) ' [A]'])
    end
    xlim([1, 1773])
    grid on; box on;
    legend('Location', 'Best', 'Interpreter', 'Latex')
    xlabel('t [s]', 'Interpreter', 'Latex')
    ylabel({'V'; '[V]'}, 'Interpreter', 'Latex') 
    Save_as_PDF(h, 'Figures/Curvas_Individuales', 'horizontal');
    
    

%% SUAVIZADO 

close all

for c = 1:length(curva)
    curva(c).smooth = curva(c).V;
    for j = 1:20
        for t = 2:length(curva(c).smooth)-1
            curva(c).smooth(t) = (curva(c).smooth(t-1) +...
                                  curva(c).smooth(t) +...
                                  curva(c).smooth(t+1))/3;
        end        
    end
    h = figure();
        hold on
        plot(curva(c).t, curva(c).V, 'Color', colors(1,:), 'Linewidth', 1.5, 'DisplayName', 'Datos experimentales')
        plot(curva(c).t, curva(c).smooth, 'Color', colors(2,:), 'Linewidth', 1.5, 'DisplayName', 'Datos suavizados')
        xlim([0, curva(c).t(end)])
        grid on; box on;
        legend('Location', 'SouthEast', 'Interpreter', 'Latex')
        xlabel('t [s]', 'Interpreter', 'Latex')
        ylabel({'V'; '[V]'}, 'Interpreter', 'Latex') 
end
Save_as_PDF(h, 'Figures/Curva_Suavizada', 'horizontal');

h = figure();
    hold on
    plot(curva(c).t(375:650), curva(c).V(375:650), 'Color', colors(1,:), 'Linewidth', 1.5, 'DisplayName', 'Datos experimentales')
    plot(curva(c).t(375:650), curva(c).smooth(375:650), 'Color', colors(2,:), 'Linewidth', 1.5, 'DisplayName', 'Datos suavizados')
    axis([375, 650, 23.665, 23.705])
    grid on; box on;
    legend('Location', 'SouthEast', 'Interpreter', 'Latex')
    xlabel('t [s]', 'Interpreter', 'Latex')
    ylabel({'V'; '[V]'}, 'Interpreter', 'Latex')
    %Save_as_PDF(h, 'Figures/Curva_Suavizada_Detalle', 'horizontal', 0, 0);


    
%% FILTER DESIGN --> Savitzky-Golay
%{
close all

% Filter design
framelen = [21, 151, 301, 251];
order = [1, 3, 3, 4];  

for c = 1:length(curva)
    
    curva(c).SG = sgolayfilt(curva(c).smooth, order(c), framelen(c));  
    figure()
        plot(curva(c).smooth, 'LineWidth', 1.) 
        hold on 
        plot(curva(c).SG, 'LineWidth', 1.5) 
        legend('signal','sgolay', 'Location', 'Best')
        
end
%}

    
%% TRAMO LINEAL

close all

for c = 1:length(curva)
           
    % Tramos lineal -> ultima mitad
    percent = 0.5;
    % lin_end = length(curva(c).SG);
    lin_end = length(curva(c).smooth);
    lin_start = round(lin_end*percent);
    
    % Polinomio de primero orden
    p = polyfit(curva(c).t(lin_start:lin_end), ...
                curva(c).smooth(lin_start:lin_end),1);
            
    curva(c).p = p;
    curva(c).recta = polyval(p,curva(c).t);
    
    % Plot figuras
    h = figure();
        hold on
        plot(curva(c).t, curva(c).smooth, 'Color', colors(1,:), 'LineWidth', 1.25, 'DisplayName', ['V'])
        plot(curva(c).t, curva(c).recta, 'Color', colors(2,:), 'LineWidth', 1.25, 'DisplayName', ['Ejuste lineal'])        
        grid on; box on
        legend('Location', 'SouthEast', 'Interpreter', 'Latex')
        xlabel('t [s]', 'Interpreter', 'Latex')
        ylabel({'V'; '[V]'}, 'Interpreter', 'Latex')
end
Save_as_PDF(h, 'Figures/Zona_Lineal', 'horizontal', 0, 0);


%% AISLAR PARTE EXPONENCIAL

close all

% Filter design
framelen = [201, 301, 251, 201];
order = [3, 5, 3, 1];  

for c = 1:length(curva)
    
    % Restar la recta
    curva(c).exp = curva(c).smooth - curva(c).recta;
    curva(c).exp_smooth = curva(c).exp;
    
%{
    % Suavizar picos
%     for j = 1:10
%         for t = 3:length(curva(c).exp)-2
%             curva(c).exp_smooth(t) = (curva(c).exp(t-2) +...
%                                       curva(c).exp(t-1) +...
%                                       curva(c).exp(t) +...
%                                       curva(c).exp(t+1) +...
%                                       curva(c).exp(t-2))/5;
%         end        
%     end
   
    % Filtrado resta
%     curva(c).exp_SG = sgolayfilt(curva(c).exp, order(c), framelen(c));    
    if c == 1
        [envHigh, envLow] = envelope(curva(c).exp,91,'peak');
        curva(c).final = (envHigh+envLow)/2;
    else
        [envHigh, envLow] = envelope(curva(c).exp,20,'peak');
        curva(c).final = (envHigh+envLow)/2;
    end
%}
    
    % Plot curves
    h = figure();
        hold on
        plot(curva(c).t,  curva(c).exp,'Color', colors(1,:), 'LineWidth', 1.25)
        grid on; box on
        xlabel('t [s]', 'Interpreter', 'Latex')
        ylabel({'$\Delta$V'; '[V]'}, 'Interpreter', 'Latex')
end
Save_as_PDF(h, 'Figures/Transitorio', 'horizontal', 0, 0);


%% OBTENCION DE R1

for c = 1:length(curva)
    
    % Ecuacion en t0
    curva(c).R1 = -curva(c).exp(1)/curva(c).difI;
    curva(c).C1 = 0;

end



%% OBTENCION C1

close all

for c = 1:length(curva)
    
    curva(c).adim = abs( curva(c).exp/( curva(c).R1*curva(c).difI ) );    
    
    % AJUSTE EXPONENCIAL A LA CURVA ADIMENSIONALIZADA
    
    % Opciones de ajuste
    ft = fittype( 'exp(-a*x)', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.StartPoint = 0.01;

    % Ajuste de la curva a los datos
    [fitresult, gof] = fit( curva(c).t,  curva(c).adim, ft, opts );

    curva(c).coef = coeffvalues(fitresult);
    curva(c).gof = gof;
    curva(c).RMSE = gof.rmse;
    
    % Curva modelo exponencial
    curva(c).model_exp = exp(-curva(c).coef(1)*curva(c).t);    
    
    % Obtener el tiempo caracteristico
    [~, idx] = min( abs( curva(c).model_exp - exp(-1)) );
    curva(c).tc = curva(c).t(idx);
    
    % Puto condensador
    curva(c).C1 = curva(c).tc/curva(c).R1;
    
    curva(c).DV = -curva(c).difI*curva(c).R1*exp( -curva(c).t/( curva(c).R1*curva(c).C1 ) );
    
    % Plot curvas adimensionales
    h = figure();
        hold on
        plot(curva(c).t, curva(c).adim, 'Color', colors(1,:), 'LineWidth', 1.25, 'DisplayName', 'Adimensional')
        plot(curva(c).t, curva(c).model_exp, 'Color', colors(2,:), 'LineWidth', 1.25, 'DisplayName', 'Ajuste')
        plot([0,curva(c).t(end)], [exp(-1), exp(-1)], 'Color', 'k', 'LineWidth', 1.25, 'DisplayName', '$\exp(-1)$')
        xlim([0,curva(c).t(end)])
        grid on; box on;
        xlabel('t [s]', 'Interpreter', 'Latex')
        legend('Location', 'Best', 'Interpreter', 'Latex')
end
Save_as_PDF(h, 'Figures/Curvas_Modelo', 'horizontal');
        
    
%%

h = figure();
    hold on
    for c = 1:length(curva)
        plot(curva(c).t, curva(c).adim, 'Linewidth', 1.25, 'Color', colors(c,:),...
            'DisplayName', [curva(c).Tipo ' a I = ' num2str(abs(round(curva(c).I,1))) ' [A]'])
    end
    xlim([1, 1773])
    grid on; box on;
    legend('Location', 'Best', 'Interpreter', 'Latex')
    xlabel('t [s]', 'Interpreter', 'Latex')
    Save_as_PDF(h, 'Figures/Curvas_adimensionalizadas', 'horizontal');


%% RESULTADOS

R1 = mean([curva(:).R1]);
C1 = mean([curva(:).C1]);

save('Data/Modelo_Analitico_1C.mat', 'R1', 'C1')


%%

figure()
    title('Comparacion con modelo')
    hold on
for c = 1:length(curva)
        plot(curva(c).t, curva(c).final, 'LineWidth', 1.25, 'DisplayName', ['Datos'])
        plot(curva(c).t, curva(c).DV, ':', 'LineWidth', 1.25, 'DisplayName', ['Modelo'])        
end
    grid on; box on
    legend('Location', 'Best')



%% MODELO CUADRATICO --> No va

for c = 1:length(curva)
    
    ft = fittype( 'a*exp(-(b*x + c*x^2))', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.StartPoint = [-1, 0.1, .1];

    % Fit model to data.
    [fitresult, gof] = fit( curva(c).t,  curva(c).adim, ft, opts );

    curva(s).coef =coeffvalues(fitresult);
    curva(s).gof = gof;
    curva(s).RMSE = gof.rmse;

end