clc
clear all
close all


%% Células
% Crea las células como objeto
C = solar_cell(288.15, 75);

% Distribuye las células en serie/paralelo
N_serie = 6;
N_paralelo = 3;

% Cell_array = solar_cell.empty();
% 
% for i=1:N_serie
%     Cell_array(i) = C; 
% end
% for j=1:N_paralelo-1
%     Cell_array = cat(1,Cell_array, Cell_array);
% end


%% Panel solar 
SP = solar_panel(C, N_serie, N_paralelo);