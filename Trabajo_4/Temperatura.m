clc
close all
clear all

Tm = -20+273; Tx = 80+273;
theta_sol = linspace(0,pi/2,101); theta_som = linspace(pi/2,2*pi ,101);
thetai = pi/2; thetaf = 2*pi;

Tsol = Tm*exp( log(Tx/Tm)*theta_sol/thetai );
Tsom = Tx*exp( log(Tm/Tx)*(theta_som-thetai)/(thetaf-thetai) );

figure()
    hold on
    plot(theta_som, Tsom, 'LineWidth', 2)
    plot(theta_sol, Tsol, 'LineWidth', 2)
    grid on; box on;
    xlabel('\theta [rad]')
    ylabel('T [K]')
    axis([0, 2*pi, Tm, Tx])
    
    
    
   