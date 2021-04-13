clc
clear all
close all


%% LEER DATOS

filename = 'ensayos_bateria.xlsx';
sheets = [1:6];
fields = {'D5A', 'C5A', 'D2d5A', 'C2d5A', 'D1d5A', 'C1d5A'};
xlRange = 'B2:C3';

Bateria = struct();
for f = 1:length(sheets)
    Bateria.(fields{f}) = xlsread(filename,sheets(f));
    
    figure(f)
        hold on
        plot(Bateria.(fields{f})(:,1), Bateria.(fields{f})(:,3))
        title(fields{f})
end



%% LIMPIAR DATOS

Bateria.D5A(1:2,:) = [];
Bateria.C2d5A(1,:) = [];
Bateria.D2d5A(1,:) = [];
Bateria.D2d5A(end,:) = [];
Bateria.C1d5A(1,:) = [];


%%
for f = 1:length(sheets)
    figure(f)
        plot(Bateria.(fields{f})(:,1), Bateria.(fields{f})(:,3))
        title(fields{f})
end


%% GUARDAR DATOS DE LA BATERIA CON CAMPOS

Ensayos_Bateria = struct();
ic = [5, 5, 2.5, 2.5, 1.5, 1.5];

for f = 1:length(sheets)
    Ensayos_Bateria.(fields{f}).t = Bateria.(fields{f})(:,1);
    Ensayos_Bateria.(fields{f}).I = Bateria.(fields{f})(:,2);
    Ensayos_Bateria.(fields{f}).It = Bateria.(fields{f})(:,1)*ic(f);
    Ensayos_Bateria.(fields{f}).V = Bateria.(fields{f})(:,3);
    
end




save('Data_Ensayos_Bateria.mat', 'Ensayos_Bateria', 'fields', 'ic');




