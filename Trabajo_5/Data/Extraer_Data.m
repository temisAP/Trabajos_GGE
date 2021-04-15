clc
clear all
close all


%% LEER DATOS

filename = 'ensayos_bateria.xlsx';
% sheets = [1:2:5, 2:2:6];
% fields = {'D5A', 'D2d5A', 'D1d5A', 'C5A', 'C2d5A', 'C1d5A'};
xlRange = 'B2:C3';

% Bateria = struct();
% for s = 1:length(sheets)
%     Bateria.(fields{s}) = xlsread(filename,sheets(s));
%     
%     figure(s)
%         hold on
%         plot(Bateria.(fields{s})(:,1), Bateria.(fields{s})(:,3))
%         title(fields{s})
% end


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
fields = {'C-5A', 'C-2,5A', 'C-1,5A'};
Carga = struct();



%% GUARDAR DATOS

save('Descarga-Carga.mat', 'Descarga', 'Carga')

%% LIMPIAR DATOS
%{
Bateria.D5A(1:2,:) = [];
Bateria.C2d5A(1,:) = [];
Bateria.D2d5A(1,:) = [];
Bateria.D2d5A(end,:) = [];
Bateria.C1d5A(1,:) = [];


%%
for s = 1:length(sheets)
    figure(s)
        plot(Bateria.(fields{s})(:,1), Bateria.(fields{s})(:,3))
        title(fields{s})
end


%% GUARDAR DATOS DE LA BATERIA CON CAMPOS

Ensayos_Bateria = struct();
ic = [5, 2.5, 1.5, 5, 2.5, 1.5];

for s = 1:length(sheets)
    Ensayos_Bateria.(fields{s}).t = Bateria.(fields{s})(:,1)/3600;
    Ensayos_Bateria.(fields{s}).I = Bateria.(fields{s})(:,2);
    Ensayos_Bateria.(fields{s}).It = Ensayos_Bateria.(fields{s}).t*ic(s);
    Ensayos_Bateria.(fields{s}).V = Bateria.(fields{s})(:,3);
    
end

save('Data_Ensayos_Bateria.mat', 'Ensayos_Bateria', 'fields', 'ic');

%}





%% FUNCIONES

