clc;
clear all;
close all;

x = linspace(0,100,101);
y = x;

h = figure();
    hold on
    plot(x, y, '-', 'LineWidth', 2, 'Color', 'k', 'DisplayName', 'Curva 1')
    plot(x, 0.5*y, '--', 'LineWidth', 2, 'Color', 'k', 'DisplayName', 'Curva 2')
    plot(x, -0.5*y, '-.', 'LineWidth', 2, 'Color', 'k', 'DisplayName', 'Curva 3')
    plot(x, -y, ':', 'LineWidth', 2, 'Color', 'k', 'DisplayName', 'Curva 4')
    box on; grid on
    legend('Interpreter', 'Latex', 'location', 'best')    % location: NorthEast
    % title("\textit{\textbf{Prueba im\'agen}}",'Interpreter','latex')
    xlh = xlabel('$x$ [m]','Interpreter','latex')
    xlh.Position(1) = xlh.Position(1) + 42.5;
    ylh = ylabel({'$y$';'[m]'},'Interpreter','latex');
    ylh.Position(1) = ylh.Position(1) - 3;   % abs(ylh.Position(1) * 0.3)
    ylh.Position(2) = ylh.Position(2) + 75;
    Save_as_PDF(h, 'test',0);    % Save_as_PDF(h, 'Figuras/test',0)