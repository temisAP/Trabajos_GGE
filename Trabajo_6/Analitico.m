clc
clear
close all

%% LOAD DATA

load('Data/Bateria_Dinamica_Experimental.mat')


figure()
    hold on
    plot(Data.V)
    xlabel('t [s]')
    ylabel('V [V]')
    grid on

figure()
    hold on
    plot(Data.I)
    xlabel('t [s]')
    ylabel('I [V]')
    grid on
    
    
%% SEPARAR CURVAS A ESTUDIAR

% Curvas de descarga
curva(1).Tipo = 'Descarga';
curva(1).V = Data.V(4:1776);
curva(1).t = Data.t(4:1776) - Data.t(4);
curva(1).I = Data.I(4);
curva(1).difI = Data.I(4) - 0;

% curva(2).Tipo = 'Descarga';
% curva(2).V = Data.V(3552:4735);
% curva(2).t = Data.t(3552:4735) - Data.t(3552);
% curva(2).I = Data.I(3552);
% curva(2).difI = Data.I(3552) - Data.I(3552-1);

curva(2).Tipo = 'Descarga';
curva(2).V = Data.V(6511:end);
curva(2).t = Data.t(6511:end) - Data.t(6511);
curva(2).I = Data.I(6511);
curva(2).difI = Data.I(6511) - Data.I(6510);

% Curvas de carga
curva(3).Tipo = 'Carga';
curva(3).V = Data.V(1777:3551);
curva(3).t = Data.t(1777:3551) - Data.t(1777);
curva(3).I = Data.I(1777);
curva(3).difI = Data.I(1777) - Data.I(1776);
curva(4).Tipo = 'Carga';
curva(4).V = Data.V(5328:6510);
curva(4).t = Data.t(5328:6510) - Data.t(5328);
curva(4).I = Data.I(5328);
curva(4).difI = Data.I(5328) - Data.I(5327);


% Representacion todas curvas
figure()
    hold on
    for c = 1:length(curva)
        plot(curva(c).t, curva(c).V, ...
            'DisplayName', [curva(c).Tipo ', I = ' num2str(curva(c).I) '[A]'])
    end
    legend('Location', 'Best')
    xlabel('t [s]')
    ylabel('V [V]')
    
    
    
%% PARTE LINEAL

close all

for c = 1:length(curva)
    
    % Filtrado
    if c == 2
        [envHigh, envLow] = envelope(flip(curva(c).V),100,'peak');
        curva(c).filt = flip((envHigh+envLow)/2);
        envHigh = flip(envHigh);
        envLow = flip(envLow);
    else
        [envHigh, envLow] = envelope(flip(curva(c).V),20,'peak');
        curva(c).filt = flip((envHigh+envLow)/2);
        envHigh = flip(envHigh);
        envLow = flip(envLow);
    end
        
    % Sacar la recta que ajusta al tramo lineal    
    lin_end = length(curva(c).V);
    lin_start = round(lin_end*.6);
    
    p = polyfit(curva(c).t(lin_start:lin_end), ...
                curva(c).filt(lin_start:lin_end),1);
            
    curva(c).p = p;
    curva(c).recta = polyval(p,curva(c).t);
    
    % Plot curves
    figure()
        hold on
        plot(curva(c).t, curva(c).V, 'LineWidth', 1.25, 'DisplayName', ['V'])
        plot(curva(c).t, envHigh, 'LineWidth', 1.25, 'DisplayName', ['Envelope H'])
        plot(curva(c).t, envLow, 'LineWidth', 1.25, 'DisplayName', ['Envelope L'])
        plot(curva(c).t, curva(c).filt, 'LineWidth', 1.25, 'DisplayName', ['Fit'])
        plot(curva(c).t, curva(c).recta, 'LineWidth', 1.25, 'DisplayName', ['Recta'])
        grid on; box on
        legend('Location', 'Best')
        title([curva(c).Tipo ', I = ' num2str(curva(c).I) ' [A]'])
end



%% LIMITE LINEAL

close all

for c = 1:length(curva)
    
    % Restar la recta
    curva(c).exp = curva(c).V - curva(c).recta;
        
    % Filtrado resta
    [envHigh, envLow] = envelope(curva(c).exp,20,'peak');
    curva(c).final = (envHigh+envLow)/2;
    
    % Plot curves
    figure()
        hold on
        plot(curva(c).t,  curva(c).exp, ...
                    'DisplayName', [curva(c).Tipo ', I = ' num2str(curva(c).I) ' [A]'])
        title([curva(c).Tipo ', I = ' num2str(curva(c).I) ' [A]'])
        plot(curva(c).t,  curva(c).final, ...
                    'DisplayName', [curva(c).Tipo ', I = ' num2str(curva(c).I) ' [A]'])
        title([curva(c).Tipo ', I = ' num2str(curva(c).I) ' [A]'])
        grid on; box on

end


%% OBTENCION PARAMETROS

figure()
    title('Curvas adimensionalizadas')
    hold on

for c = 1:length(curva)
    
    % Ecuacion en t0
    curva(c).R1 = -curva(c).final(1)/curva(c).difI;
    curva(c).adim = abs( curva(c).final/( curva(c).R1*curva(c).difI ) );    
    
    [~, idx] = min( abs( curva(c).adim - exp(-1)) );
    curva(c).tc = curva(c).t(idx);
    
    % Puto condensador
    curva(c).C1 = curva(c).tc/curva(c).R1;
    
    curva(c).DV = -curva(c).difI*curva(c).R1*exp( -curva(c).t/( curva(c).R1*curva(c).C1 ) );
    
    plot(abs(curva(c).adim), ...
                    'DisplayName', [curva(c).Tipo ', I = ' num2str(curva(c).I) ' [A]'])
        title([curva(c).Tipo ', I = ' num2str(curva(c).I) ' [A]'])

end
legend()


figure()
    title('COmparacion con modelo')
    hold on
for c = 1:length(curva)
        plot(curva(c).t, curva(c).final, 'LineWidth', 1.25, 'DisplayName', ['Datos'])
        plot(curva(c).t, curva(c).DV, 'LineWidth', 1.25, 'DisplayName', ['Modelo'])        
end
    grid on; box on
    legend('Location', 'Best')

    
%% RESULTADOS

R1 = mean([curva(:).R1]);
C1 = mean([curva(:).C1]);

save('Data/Modelo_Analitico_1C.mat', 'R1', 'C1')