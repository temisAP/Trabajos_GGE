clc;
clear all;
close all;

% Generar vectores
x = linspace(0,100,101);
y = x;

% Plotear y guardar
% https://es.mathworks.com/help/matlab/ref/linespec.html
h = figure();
    hold on
    plot(x, y, '-', 'LineWidth', 2, 'Color', 'k', 'DisplayName', 'Curva 1')
    plot(x, 0.5*y, '--', 'LineWidth', 2, 'Color', 'k', 'DisplayName', 'Curva 2')
    plot(x, -0.5*y, '-.', 'LineWidth', 2, 'Color', 'k', 'DisplayName', 'Curva 3')
    plot(x, -y, ':', 'LineWidth', 2, 'Color', 'k', 'DisplayName', 'Curva 4')
    box on; grid on
    legend('Interpreter', 'Latex', 'location', 'best')    % location: NorthEast
    title("\textit{\textbf{Prueba im\'agen}}",'Interpreter','latex')
    xlabel('$x$ [m]','Interpreter','latex')
    ylh = ylabel({'$P$';'[m]'},'Interpreter','latex');
    ylh.Position(1) = ylh.Position(1) - abs(ylh.Position(1) * 0.1);
    Save_as_PDF(h, 'test',0);    % Save_as_PDF(h, 'Figuras/test',0)

