clc
clear
close all


%% LOAD DATA

load('Data/Bateria_Dinamica_Experimental.mat')


h = figure();
    subplot(2,1,1)
    plot(Data.t, Data.V, 'k', 'LineWidth', 1.25)
    xlim([0, Data.t(end)])
    xlabel('$t$ [s]', 'Interpreter', 'Latex')
    ylabel({'$V$'; '[V]'}, 'Interpreter', 'Latex')
    grid on; box on
    Save_as_PDF(h, 'Figures/V_vs_t', 'horizontal');
    subplot(2,1,2)
    hold on
    plot(Data.I, 'k', 'LineWidth', 1.25)
    xlim([0, Data.t(end)])
    ylim([-5, 1.5])
    xlabel('$t$ [s]', 'Interpreter', 'Latex')
    ylabel({'$I$'; '[A]'}, 'Interpreter', 'Latex')
    grid on; box on
  
%    Save_as_PDF(h, 'Figures/V_vs_t', 'horizontal');
    
%% SEPARAR CURVAS A ESTUDIAR

inicio = Data.V(1:2);

% Curvas de descarga
curva(1).V = Data.V(3:1775);
curva(2).V = Data.V(1776:3550);
curva(3).V = Data.V(3551:4734);
curva(4).V = Data.V(4735:5326);
curva(5).V = Data.V(5327:6509);
curva(6).V = Data.V(6510:end);

% Representacion todas curvas
colors = [0, 0.4470, 0.7410;
          [220,20,6]/255;
          [255,140,0]/255;
          [139,0,139]/255;
          [50,205,50]/255;
          0, 0.4470, 0.7410;
          [220,20,6]/255];


%% SUAVIZADO 

close all

for c = 1:length(curva)
    curva(c).smooth = curva(c).V;
    for j = 1:400
        for t = 2:length(curva(c).smooth)-1
            curva(c).smooth(t) = (curva(c).smooth(t-1) +...
                                  curva(c).smooth(t) +...
                                  curva(c).smooth(t+1))/3;
        end        
    end
    h = figure();
        hold on
        plot(curva(c).V, 'Color', colors(1,:), 'Linewidth', 1.5, 'DisplayName', 'Datos experimentales')
        plot(curva(c).smooth, 'Color', colors(2,:), 'Linewidth', 1, 'DisplayName', 'Datos suavizados')
        grid on; box on;
        legend('Location', 'SouthEast', 'Interpreter', 'Latex')
        xlabel('$t$ [s]', 'Interpreter', 'Latex')
        ylabel({'$V$'; '[V]'}, 'Interpreter', 'Latex') 
end
%Save_as_PDF(h, 'Figures/Curva_Suavizada', 'horizontal');


Datos_Suavizados = [inicio];
for c = 1:length(curva)
    Datos_Suavizados = [Datos_Suavizados; curva(c).smooth];
end
    

%%
figure()
    plot(Datos_Suavizados)
    
    
save('Data/Datos_Suavizados.mat', 'Datos_Suavizados')
 