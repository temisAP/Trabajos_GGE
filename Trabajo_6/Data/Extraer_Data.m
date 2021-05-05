clc
clear all
close all


%% LEER DATOS

filename = 'medidas_bateria.xlsx';

%% DESCARGA

sheets = [1];
names = {'medidas_bateria_'};

Data = struct();
for s = 1:length(sheets)
    data = xlsread(filename,sheets(s));
    
    Data(s).Name = names{s};
    Data(s).t = data(:,1);
    Data(s).V = data(:,2);
    Data(s).I = data(:,3);
    
    Data(s).It = Data(s).I.*Data(s).t/3600;
    
    Data(s).phi1 = zeros(size(Data(s).t));
    Data(s).phi2 = zeros(size(Data(s).t));

    for t = 2:length(Data(s).t)
        Dt = Data(s).t(t)-Data(s).t(t-1);
        Data(s).phi1(t) = Data(s).phi1(t-1) + Data(s).I(t)*(Data(s).V(t)+Data(s).V(t-1))/2 * Dt;
        Data(s).phi2(t) = Data(s).phi2(t-1) + Data(s).I(t)^2;
    end
    
    figure(s)
        hold on
        plot(Data(s).It, Data(s).V)
        title(Data(s).Name)
           
    Data(s).I = -Data(s).I; %% La descarga es con intensidad negativa
    
    fields = fieldnames(Data);
    if s == 1 
        for f = 2:length(fields)
            Data(s).(fields{f})(1:2,:) = [];
        end
    elseif s == 2
        for f = 2:length(fields)
            Data(s).(fields{f})(1,:) = [];
            Data(s).(fields{f})(end,:) = [];
        end
    else         
    end
    
    figure(s)
        plot(Data(s).It, Data(s).V)
      
end




%% GUARDAR DATOS

save('DATOS_EXPERIMENTALES.mat', 'Data')
