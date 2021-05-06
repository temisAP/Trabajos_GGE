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
    
    
%% SEPARAR CURVAS A ESTUDIAR

% Curvas de descarga
curva(1).Tipo = 'Descarga';
curva(1).V = Data.V(4586:5177);
curva(1).t = Data.t(4586:5177) - Data.t(4586);
curva(1).I = Data.I(4586);
curva(2).Tipo = 'Descarga';
curva(2).V = Data.V(6361:end);
curva(2).t = Data.t(6361:end) - Data.t(6361);
curva(2).I = Data.I(6361);

% Curvas de carga
curva(3).Tipo = 'Carga';
curva(3).V = Data.V(1627:3401);
curva(3).t = Data.t(1627:3401) - Data.t(1627);
curva(3).I = Data.I(1627);
curva(4).Tipo = 'Carga';
curva(4).V = Data.V(5178:6360);
curva(4).t = Data.t(5178:6360) - Data.t(5178);
curva(4).I = Data.I(6361);


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
    
    % Sacar la recta que ajusta al tramo lineal    
    lin_end = length(curva(c).V) - 5;
    lin_start = round(lin_end*.6);
    
    p = polyfit(curva(c).t(lin_start:lin_end), ...
                curva(c).V(lin_start:lin_end),1);
            
    curva(c).p = p;
    curva(c).recta = polyval(p,curva(c).t);
    
    % Plot curves
    figure()
        hold on
        plot(curva(c).t, curva(c).V, ...
                    'DisplayName', [curva(c).Tipo ', I = ' num2str(curva(c).I) '[A]'])
        plot(curva(c).t,  curva(c).recta, ...
                    'DisplayName', [curva(c).Tipo ', I = ' num2str(curva(c).I) '[A]'])
        grid on; box on
    
end

%{
%curva_filt = curva;   

close all
for c = 1:length(curva_filt)
    
    % Filtrado
%     for i = 2:length(curva(c).V)-3    
%         curva_filt(c).V(i) = ( curva_filt(c).V(i-1) + curva_filt(c).V(i)...
%                                + curva_filt(c).V(i+1) )/3;
%     end
%{
%     for i = 4:length(curva(c).V)-4    
%         curva_filt(c).V(i) = ( curva_filt(c).V(i-3) + curva_filt(c).V(i-2)...
%                                + curva_filt(c).V(i-1) + curva_filt(c).V(i)...
%                                + curva_filt(c).V(i+1) + curva_filt(c).V(i+2)...
%                                + curva_filt(c).V(i+3) )/7;
%     end
%}
    % Sacar la recta que ajusta a la ultima parte    
    lin_end = length(curva_filt(c).V) - 5;
    lin_start = round(lin_end*.6);
    
    p = polyfit(curva_filt(c).t(lin_start:lin_end), ...
                curva_filt(c).V(lin_start:lin_end),1);
            
    curva_filt(c).p = p;
    curva_filt(c).lin = polyval(p,curva_filt(c).t);
    
    % Plot curves
    figure()
        hold on
        plot(curva(c).t, curva(c).V, ...
                    'DisplayName', [curva(c).Tipo ', I = ' num2str(curva(c).I) '[A]'])
        plot(curva_filt(c).t, curva_filt(c).V, ...
                    'DisplayName', [curva_filt(c).Tipo ', I = ' num2str(curva_filt(c).I) '[A]'])
        plot(curva_filt(c).t,  curva_filt(c).lin, ...
                    'DisplayName', [curva_filt(c).Tipo ', I = ' num2str(curva_filt(c).I) '[A]'])
        grid on; box on
    
end

%}

%% LIMITE LINEAL

idx_sep = [255, 491, 570, 415];

curva_r = curva;

close all
for c = 1:length(curva_filt)
    
    curva_r(c).V = curva_filt(c).V - curva_filt(c).lin ;
    
    
    
    % Plot curves
    figure()
        hold on
        plot(curva_filt(c).t,  curva_r(c).V, ...
                    'DisplayName', [curva_filt(c).Tipo ', I = ' num2str(curva_filt(c).I) '[A]'])
        grid on; box on
    
end

