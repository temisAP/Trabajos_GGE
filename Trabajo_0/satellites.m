close all
format short
filename='satellites.ods';

%% Read data

data = xlsread(filename);
mass = data(2:end,1);
power = data(2:end,2);
capacity = data(2:end,4);

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

h1 = figure(1);
    hold on
    scatter(mass, power, 'k','DisplayName', 'Datos')
    plot(massq, powerq, '-', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
        ['P = ',num2str(power_coeff(1)),' m + ', num2str(power_coeff(2))])
    box on; grid on
    legend('Interpreter', 'Latex', 'location', 'NorthWest')
    %title("\textit{\textbf{Potencia vs masa}}",'Interpreter','latex')
    xlh = xlabel('$m$ [kg]','Interpreter','latex');
    xlh.Position(1) = xlh.Position(1) + abs(xlh.Position(1) * 0.75);
    ylh = ylabel({'$P$';'[W]'},'Interpreter','latex');
    ylh.Position(1) = ylh.Position(1) - abs(ylh.Position(1) * 0.7);
    ylh.Position(2) = ylh.Position(2) + abs(ylh.Position(2) * 0.45);
    Save_as_PDF(h1, 'Figures/mass_vs_power',0);  
    
h2 = figure(2);
    hold on
    scatter(mass, capacity, 'k','DisplayName', 'Datos')
    plot(massq, capacityq, '-', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
        ['C = ',num2str(capacity_coeff(1)),' m + ', num2str(capacity_coeff(2))])
    box on; grid on
    legend('Interpreter', 'Latex', 'location', 'NorthWest')
    %title("\textit{\textbf{Capacidad vs masa}}",'Interpreter','latex')
    xlh = xlabel('$m$ [kg]','Interpreter','latex');
    xlh.Position(1) = xlh.Position(1) + abs(xlh.Position(1) * 0.75);
    ylh = ylabel({'$C$';'[Ah]'},'Interpreter','latex');
    ylh.Position(1) = ylh.Position(1) - abs(ylh.Position(1) * 0.7);
    ylh.Position(2) = ylh.Position(2) + abs(ylh.Position(2) * 0.425);
    Save_as_PDF(h2, 'Figures/mass_vs_capacity',0);  
    
    