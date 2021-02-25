close all
format short
filename='satellites.xls';

data = xlsread(filename);
mass = data(:,1);
for i=2:length(mass)
    if mass(i) <= mass(i-1)
        mass(i) = mass(i-1)+1e-6;
    end
end
massq = linspace(0,max(mass)+10,100);

power = data(:,2);
powerfit = fit(mass,power,'poly1');
power_coeff = coeffvalues(powerfit);
powerq = power_coeff(1)*massq + power_coeff(2);

capacity = data(:,3);
capacityfit = fit(mass,capacity,'poly1');
capacity_coeff = coeffvalues(capacityfit);
capacityq = capacity_coeff(1)*massq + capacity_coeff(2);

h = figure();
    hold on
    scatter(mass, power, 'k','DisplayName', 'Datos')
    plot(massq, powerq, '-', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
        ['P = ',num2str(power_coeff(1)),' m + ', num2str(power_coeff(2))])
    box on; grid on
    legend('Interpreter', 'Latex', 'location', 'best')
    title("\textit{\textbf{Potencia vs masa}}",'Interpreter','latex')
    xlabel('$Masa$ [kg]','Interpreter','latex')
    ylabel({'$Potencia$';'[W]'},'Interpreter','latex')
    Save_as_PDF(h, 'mass_vs_power',0);  
    
h = figure();
    hold on
    scatter(mass, capacity, 'k','DisplayName', 'Datos')
    plot(massq, capacityq, '-', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
        ['P = ',num2str(capacity_coeff(1)),' m + ', num2str(capacity_coeff(2))])
    box on; grid on
    legend('Interpreter', 'Latex', 'location', 'best')
    title("\textit{\textbf{Capacidad vs masa}}",'Interpreter','latex')
    xlabel('$Masa$ [kg]','Interpreter','latex')
    ylabel({'$Capacidad$';'[A·h]'},'Interpreter','latex')
    Save_as_PDF(h, 'mass_vs_capacity',0);  
    
    
h = figure();
    hold on
    scatter(mass, power, 'k','DisplayName', 'Datos')
    plot(massq, powerq, '-', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
        ['P = ',num2str(power_coeff(1)),' m + ', num2str(power_coeff(2))])
    box on; grid on
    legend('Interpreter', 'Latex', 'location', 'best')
    title("\textit{\textbf{Potencia vs masa}}",'Interpreter','latex')
    xlabel('$Masa$ [kg]','Interpreter','latex')
    ylabel({'$Potencia$';'[W]'},'Interpreter','latex')
    Save_as_PDF(h, 'mass_vs_power',0);  
    