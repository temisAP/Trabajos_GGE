classdef solar_cell 
    %% Atributos
    properties
        % Aquí los atributos van sin obj. luego sí que hay que ponerlos
        Vt;
        T;
        V0 = 4.2; %V
        V_cell;
    end
    %% Métodos
    methods
         % Constructor (se llama como la clase)
        function obj = solar_cell(T)
            
            kB = 1.380649e-23; %J K-1
            qe = 1.6e-19; %C

            obj.T = T;
            obj.Vt = kB*T/qe;
        end
        % El resto de funciones tienen que llevar el obj como argumento o 
        % hacerlas estáticas (eso útlimo no sé muy bien como va)
        function I = current(obj,G,R)
            obj.V_cell = G * obj.V0; %Como si el voltaje fuese proporcional a la irradiancia por ejemplo 
            I = obj.V_cellS/R;
        end
    end
end