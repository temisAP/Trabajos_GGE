clc
clear all
close all



%% LEER DATOS

filename = 'ensayos_bateria.xlsx';
xlRange = 'B2:C3';



%% DESCARGA

sheets = [1:2:5];
names = {'D-5A', 'D-2,5A', 'D-1,5A'};

Descarga = struct();
for s = 1:length(sheets)
    data = xlsread(filename,sheets(s));
    
    Descarga(s).Name = names{s};
    Descarga(s).t = data(:,1);
    Descarga(s).I = data(:,2);
    Descarga(s).It = Descarga(s).I.*Descarga(s).t;
    Descarga(s).V = data(:,3);
    Descarga(s).phi1 = zeros(size(Descarga(s).t));
    Descarga(s).phi2 = zeros(size(Descarga(s).t));

    for t = 2:length(Descarga(s).t)
        Dt = Descarga(s).t(t)-Descarga(s).t(t-1);
        Descarga(s).phi1(t) = Descarga(s).phi1(t-1) + Descarga(s).I(t)*(Descarga(s).V(t)+Descarga(s).V(t-1))/2 * Dt;
        Descarga(s).phi2(t) = Descarga(s).phi2(t-1) + Descarga(s).I(t)^2;
    end
    
    figure(s)
        hold on
        plot(Descarga(s).It, Descarga(s).V)
        title(Descarga(s).Name)
           
    Descarga(s).I = -Descarga(s).I;
    
    fields = fieldnames(Descarga);
    if s == 1   % Limpiar los datos de carga
        for f = 2:length(fields)
            Descarga(s).(fields{f})(1:2,:) = [];
        end
    elseif s == 2
        for f = 2:length(fields)
            Descarga(s).(fields{f})(1,:) = [];
            Descarga(s).(fields{f})(end,:) = [];
        end
    else         
    end
    
    figure(s)
        plot(Descarga(s).It, Descarga(s).V)

        
end



%% CARGA

sheets = [2:2:6];
names = {'C-5A', 'C-2,5A', 'C-1,5A'};
Carga = struct();

for s = 1:length(sheets)
    data = xlsread(filename,sheets(s));
    
    Carga(s).Name = names{s};
    Carga(s).t = data(:,1);
    Carga(s).I = data(:,2);
    Carga(s).It = Carga(s).I.*Carga(s).t;
    Carga(s).V = data(:,3);
    Carga(s).phi1 = zeros(size(Carga(s).t));
    Carga(s).phi2 = zeros(size(Carga(s).t));

    for t = 2:length(Carga(s).t)
        Dt = Carga(s).t(t)-Carga(s).t(t-1);
        Carga(s).phi1(t) = Carga(s).phi1(t-1) + Carga(s).I(t)*(Carga(s).V(t)+Carga(s).V(t-1))/2 * Dt;
        Carga(s).phi2(t) = Carga(s).phi2(t-1) + Carga(s).I(t)^2;
    end
    
    figure(s + 3)
        hold on
        plot(Carga(s).It, Carga(s).V)
        title(Carga(s).Name)
               
    fields = fieldnames(Carga);
    if s == 1   % Limpiar los datos de carga
        V = Carga(s).V;
        for f = 2:length(fields)
            Carga(s).(fields{f})(V>24.3) = [];
        end
    elseif s == 2
        V = Carga(s).V;
        for f = 2:length(fields)
            Carga(s).(fields{f})(V>24.3) = [];
            Carga(s).(fields{f})(1,:) = [];
        end
    else   
        V = Carga(s).V;
        for f = 2:length(fields)
            Carga(s).(fields{f})(V>24.3) = [];
            Carga(s).(fields{f})(1,:) = [];
        end
    end
    
    figure(s + 3)
        plot(Carga(s).It, Carga(s).V)

        
end


%% GUARDAR DATOS

save('Descarga-Carga.mat', 'Descarga', 'Carga')
