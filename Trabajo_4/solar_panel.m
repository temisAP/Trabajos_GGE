classdef solar_panel < solar_cell   % Este < significa que hereda métodos y funciones de la otra clase
    
    %% Atributos
    properties
        I=0;
        V=0;
        N_serie;
        N_paralelo;
        G;
        R;
        cell_array; 
    end
    
    %% Métodos
    methods
        % Constructor 
        function obj = solar_panel(cell_array, N_serie, N_paralelo) % cell_array es un objeto que entra como argumento
            obj.cell_array = cell_array; % Viva el overloading
            obj.N_serie = N_serie;  
            obj.N_paralelo = N_paralelo;
            
        end 
        % Correinte para G,T y R dados
        function [I,V] = current(G,T,R)
            obj.cell_array(:).T = T;
            obj.R = R;
            for i = 1:obj.N_paralelo
                obj.I = obj.I + obj.cell_array(i,1).current(G,R);
            end
            for j = 1:obj.N_serie
                obj.V = obj.V + obj.cell_array(1,j).V
            end
        end
    end

end
