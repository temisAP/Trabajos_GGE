clc
clear all
close all

try
    load('Data\Data_Ensayos_Bateria.mat')
catch
    disp('No se ha creado el archivo de datos')
    return
end


%% PLOTEAR CURVAS CARGA Y DESCARGA

color = [0, 0.4470, 0.7410;
         0.8500, 0.3250, 0.0980;
         0.4940, 0.1840, 0.5560];
c = 0;

figure()
    hold on
for f = 1:2:length(fields)
    c = c+1;
    p = polyfit(Ensayos_Bateria.(fields{f}).It,Ensayos_Bateria.(fields{f}).V,1);
    Ensayos_Bateria.(fields{f}).Lineal = ...
        polyval(p,Ensayos_Bateria.(fields{f}).It);
    
    % Plots
    plot(Ensayos_Bateria.(fields{f}).It,...
         Ensayos_Bateria.(fields{f}).V, 'LineWidth', 1.5,...
         'Color', color(c,:), 'DisplayName', fields{f})
    plot(Ensayos_Bateria.(fields{f}).It,...
         Ensayos_Bateria.(fields{f}).Lineal, '--', 'LineWidth', 1.5,...
         'Color', color(c,:), 'DisplayName', fields{f})
end
    grid on; box on;
    legend('Interpreter', 'Latex', 'Location', 'Best')
    title('Descarga')
    
figure()
    hold on
for f = 2:2:length(fields)
    plot(Ensayos_Bateria.(fields{f}).It,...
         Ensayos_Bateria.(fields{f}).V, 'DisplayName', fields{f})
end
    legend('Interpreter', 'Latex', 'Location', 'Best')
    title('Descarga')
    
    
%% CALCULO DE Rc,d

It = [1, 2, 3]*1e4;
% Carga
for t = 1:3
    
    i = 0;
    for f = 1:2:length(fields)

        i = i + 1;

        [val,idx] = min(abs(Ensayos_Bateria.(fields{f}).It - It(t)));
        V(i) = Ensayos_Bateria.(fields{f}).V(idx);
        I(i) = ic(f);

    end
    
    Rc(t) = mean( (V(3) - V(2))/(I(2) - I(3)) + (V(2) - V(1))/(I(1) - I(2)) );
end

Rc = mean(Rc);

% Descarga
for t = 1:3
    
    i = 0;
    for f = 2:2:length(fields)

        i = i + 1;

        [val,idx] = min(abs(Ensayos_Bateria.(fields{f}).It - It(t)));
        V(i) = Ensayos_Bateria.(fields{f}).V(idx);
        I(i) = ic(f);

    end
    
    Rd(t) = mean( (V(2) - V(3))/(I(2) - I(3)) + (V(1) - V(2))/(I(1) - I(2)) );
end

Rd = mean(Rd);


%% PHI

figure()
    hold on
    c = 0;
for f = 1:2:length(fields)
    c = c + 1;
    Ensayos_Bateria.(fields{f}).phi = ...
        Ensayos_Bateria.(fields{f}).V.*ic(f)- Rc*ic(f)^2;
    
    plot(Ensayos_Bateria.(fields{f}).phi.*Ensayos_Bateria.(fields{f}).t,...
         Ensayos_Bateria.(fields{f}).V, 'LineWidth', 1.5,...
         'Color', color(c,:), 'DisplayName', fields{f})
end

for f = 2:2:length(fields)
    Ensayos_Bateria.(fields{f}).phi = ...
        Ensayos_Bateria.(fields{f}).V.*ic(f)- Rd*ic(f)^2;
end



