clc
clear all
close all


%% LEER DATOS

filename = 'medidas_bateria.xlsx';

%% DESCARGA

sheets = [1];
names = {'medidas_bateria'};

Data = struct();

for s = 1:length(sheets)
    
    % Read xls sheet
    data = xlsread(filename,sheets(s));

    % Assign struct fields
    Data(s).Name = names{s};
    Data(s).t = data(:,1);
    Data(s).V = data(:,2);
    Data(s).I = data(:,3);

    Data(s).It = Data(s).I.*Data(s).t/3600;
    Data(s).phi1 = zeros(size(Data(s).t));
    Data(s).phi2 = zeros(size(Data(s).t));
    
    % Internal energy
    for t = 2:length(Data(s).t)
        Dt = Data(s).t(t)-Data(s).t(t-1);
        Data(s).phi1(t) = Data(s).phi1(t-1) + Data(s).I(t)*(Data(s).V(t)+Data(s).V(t-1))/2 * Dt;
        Data(s).phi2(t) = Data(s).phi2(t-1) + Data(s).I(t)^2;
    end

    % Initial plot
    figure(1)
        subplot(2,1,1)
        hold on
        plot(Data(s).t, Data(s).V, ':', 'LineWidth', 2)
        title('V')
        grid on
        subplot(2,1,2)
        hold on
        plot(Data(s).t, Data(s).I, ':', 'LineWidth', 2)
        title('I')
        grid on
        
    % Criterio de signos: descarga negativa
    Data(s).I = -Data(s).I; 

    % Clear data    
    fields = fieldnames(Data);
    if s == 1 
        for f = 2:length(fields)
            Data(s).(fields{f})(1,:) = [];
        end
    else         
    end

    figure(1)
        subplot(2,1,1)
        plot(Data(s).t, Data(s).V, '--', 'LineWidth', 2)
        title('V')
        grid on; box on
        subplot(2,1,2)
        plot(Data(s).t, Data(s).I, '--', 'LineWidth', 2)
        title('I')
        grid on; box on



    figure()
        hold on
        plot(Data(s).t, Data(s).phi1, 'LineWidth', 2, 'DisplayName', '$\phi_1$')
        plot(Data(s).t, Data(s).phi2, 'LineWidth', 2, 'DisplayName', '$\phi_2$')
        grid on; box on;
        legend('Interpreter', 'Latex', 'Location', 'Best')
        
end


%% GUARDAR DATOS

save('Bateria_Dinamica_Experimental.mat', 'Data')
