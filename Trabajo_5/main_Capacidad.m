clc
clear all
close all


%% LOAD DATA

try
    load('Data\Descarga-Carga.mat')
catch
    disp('No se ha creado el archivo de datos')
    return
end


%% 
% k = [];
% for i = 1:length(Descarga)
%     k{i} = - ( log(Descarga(i).t) - log(-Descarga(i).It) )./log(Descarga(i).I);
% end

k = ( log(Descarga(2).t(end)/3600) - log(-Descarga(2).I(end)))/...
    ( log(Descarga(1).t(end)/3600) - log(-Descarga(1).I(end)) );   


N_Serie = round(Descarga(1).V(1)/4.);

figure()
    hold on
for i = 1:3
    plot(Descarga(i).t/3600, Descarga(i).It)    
end
    xlabel('t')
    ylabel('Ixt [Ah]')
    
    
figure()
    hold on
for i = 1:3
    plot(log(Descarga(i).It), log(Descarga(i).t/3600))    
end
    xlabel('t')
    ylabel('Ixt [Ah]')