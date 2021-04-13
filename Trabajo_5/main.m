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
figure()
    hold on
for f = 1:2:length(fields)
    plot(Ensayos_Bateria.(fields{f}).It,...
         Ensayos_Bateria.(fields{f}).V, 'DisplayName', fields{f})
end
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