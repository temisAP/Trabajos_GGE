close all
format short
filename='satellites.xls';

%% Read data

data = xlsread(filename);
mass = data(2:end,1);
power = data(2:end,2);
capacity = data(2:end,3);

%% Interpolation

for i=2:length(mass)
    if mass(i) <= mass(i-1)
        mass(i) = mass(i-1)+1e-6; %To avoid non-unique values
    end
end
massq = linspace(0,max(mass)+10,100);

[powerfit, powergof] = fit(mass,power,'poly1');
power_coeff = coeffvalues(powerfit);
powerq = power_coeff(1)*massq + power_coeff(2);

[capacityfit, capacitygof] = fit(mass,capacity,'poly1');
capacity_coeff = coeffvalues(capacityfit);
capacityq = capacity_coeff(1)*massq + capacity_coeff(2);

%% Graphical representation

h = figure();
    hold on
    scatter(mass, power, 'k','DisplayName', 'Datos')
    plot(massq, powerq, '-', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
        ['P = ',num2str(power_coeff(1)),' m + ', num2str(power_coeff(2))])
    box on; grid on
    legend('Interpreter', 'Latex', 'location', 'best')
    title("\textit{\textbf{Potencia vs masa}}",'Interpreter','latex')
    xlabel('$m$ [kg]','Interpreter','latex')
    ylh = ylabel({'$P$';'[m]'},'Interpreter','latex');
    ylh.Position(1) = ylh.Position(1) - abs(ylh.Position(1) * 0.3);
    Save_as_PDF(h, 'Figures/mass_vs_power',0);  
    
h = figure();
    hold on
    scatter(mass, capacity, 'k','DisplayName', 'Datos')
    plot(massq, capacityq, '-', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
        ['C = ',num2str(capacity_coeff(1)),' m + ', num2str(capacity_coeff(2))])
    box on; grid on
    legend('Interpreter', 'Latex', 'location', 'best')
    title("\textit{\textbf{Capacidad vs masa}}",'Interpreter','latex')
    xlabel('$m$ [kg]','Interpreter','latex')
    ylh = ylabel({'$C$';'[m]'},'Interpreter','latex');
    ylh.Position(1) = ylh.Position(1) - abs(ylh.Position(1) * 0.3);
    Save_as_PDF(h, 'Figures/mass_vs_capacity',0);  
    
    