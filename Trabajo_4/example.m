%% Células
% Crea las células como objeto
C = solar_cell(288.15);

% Distribuye las células en serie/paralelo
N_serie = 6;
N_paralelo = 3;

Cell_array = solar_cell.empty(0,0);

for i=1:N_serie
    for j=1:N_paralelo
        Cell_array(i,j) = C; 
    end
end

%% Panel solar 
SP = solar_panel(Cell_array);