clc
clear all
close all

%% Load data

% Load experimental data

try
    load('Data\DCDC.mat')
catch
    disp('No se ha creado el archivo de datos')
    return
end

