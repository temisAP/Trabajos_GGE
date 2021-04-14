clc
clear all
close all


%% LEER DATOS

filename = 'ensayos_bateria.xlsx';
sheets = [1:2:5, 2:2:6];
fields = {'D5A', 'D2d5A', 'D1d5A', 'C5A', 'C2d5A', 'C1d5A'};
xlRange = 'B2:C3';

Bateria = struct();
for s = 1:length(sheets)
    Bateria.(fields{s}) = xlsread(filename,sheets(s));
    
    figure(s)
        hold on
        plot(Bateria.(fields{s})(:,1), Bateria.(fields{s})(:,3))
        title(fields{s})
end



%% LIMPIAR DATOS

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