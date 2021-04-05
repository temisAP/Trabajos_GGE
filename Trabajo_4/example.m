clc
clear all
close all


%% Células
% Crea las células como objeto
C = solar_cell(288.15, 75);

% Distribuye las células en serie/paralelo
N_serie = 6;
N_paralelo = 3;

Cell_array = solar_cell.empty(N_serie,0);


for j=1:N_paralelo
   for i=1:N_serie
        Cell_array(i,j) = C; 
   end
end


%% Panel solar 
SP = solar_panel(C, N_serie, N_paralelo);