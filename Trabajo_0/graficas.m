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
    title("\textit{\textbf{Prueba im\'agen}}",'Interpreter','latex')
    xlabel('$x$ [m]','Interpreter','latex')
    ylabel({'$y$';'[m]'},'Interpreter','latex')
    Save_as_PDF(h, 'test',0);    % Save_as_PDF(h, 'Figuras/test',0)