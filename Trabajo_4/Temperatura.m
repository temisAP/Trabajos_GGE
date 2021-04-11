clc
close all
clear all

Tm = -20+273; Tx = 80+273;
theta_sol = linspace(0,pi/2,101); theta_som = linspace(pi/2,2*pi ,101);
thetai = pi/2; thetaf = 2*pi;

Tsol = Tm*exp( log(Tx/Tm)*theta_sol/thetai );
Tsom = Tx*exp( log(Tm/Tx)*(theta_som-thetai)/(thetaf-thetai) );

h = figure();
    hold on
    plot(theta_som, Tsom, 'LineWidth', 1.5, 'Color', 'k', 'LineWidth', 1.5)
    plot(theta_sol, Tsol, 'LineWidth', 1.5, 'Color', 'k', 'LineWidth', 1.5)
    grid on; box on;
    xlabel('$\theta$ [rad]', 'Interpreter', 'Latex')
    ylabel({'T'; '[K]'}, 'Interpreter', 'Latex')
    axis([0, 2*pi, Tm, Tx])
    Save_as_PDF(h, 'Figuras/Temperatura', 'horizontal');
    
    
    
ent = entorno();
theta_plot = linspace(0, 2*pi,1001);
theta = theta_plot - pi/2;
theta_p = abs(asin(sin(theta)));
cosK = ent.Kelly_cos(theta_p, 75);
G = zeros(size(theta));
G(theta_plot >= 0 & theta_plot <= pi) = cosK((theta_plot >= 0 & theta_plot <= pi));

lines = {':','--','-'};
h = figure();
    hold on
    plot(theta_plot, theta_p/(pi/2), lines{1}, 'Color', 'k', 'LineWidth', 1.5, 'DisplayName', '$\theta_p/(\pi/2)$')
    plot(theta_plot, cosK, lines{2}, 'Color', 'k', 'LineWidth', 1.5,'DisplayName', 'cosK($\theta_p$)')
    plot(theta_plot, G, lines{3}, 'Color', 'k', 'LineWidth', 1.5, 'DisplayName', '$G/G_{ref}$')
    axis([theta_plot(1), theta_plot(end), 0, 1])
    grid on; box on;
    legend('Interpreter', 'Latex', 'Location', 'Best')
    xlabel('$\theta$ [rad]', 'Interpreter', 'Latex')
    %ylabel({'I'; '[A]'}, 'Interpreter', 'Latex')
    Save_as_PDF(h, 'Figuras/Irradiancia', 'horizontal');

    
    