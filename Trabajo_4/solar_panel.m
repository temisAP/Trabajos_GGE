classdef solar_panel   % Este < significa que hereda métodos y funciones de la otra clase
    
    %% Atributos
    properties
        % Eléctricas
        I=0;
        V=0;
        R;
        Vt;
        % De las células
        N_serie;
        N_paralelo;  
        Kelly_cosine_Limit;
        Modelo;         % El modelo que las representa (string)
        Paramteros;     % Los parámetros del modelo
        % Del entorno
        G;              %Irradiancia
        T;              %Temperatura
        theta;          %Ángulo de incidencia

    end
    %% Métodos
    methods
        
        % Constructor 
        function obj = solar_panel(N_serie, N_paralelo)
            obj.N_serie = N_serie;  
            obj.N_paralelo = N_paralelo;       
        end 
        
        % Correinte para G,T y R dados
        function [I,V] = current(G,T,R)
            
            switch obj.Modelo
                case 'KyH'
                    kyh_current();
                case '1d2r'
                    1d2r_current();
            
            end
        
        % Coseno de kelly
        function kcos = Kelly_cos(obj,theta)
            limit = obj.Kelly_cosine_Limit;
            
            cte = 90/limit;
            kcos = zeros(size(theta));
            kcos(theta >= 0 & theta < limit) = cos(theta(theta >= 0 & theta < limit)*cte);
        end
        
        % Corriente según modelo
        function kyh_current(obj)
            obj.I = 0;
            % poner aquí la expresión
            
        end
        function I = 1d2r_current(obj)
            obj.I = 0;
            % poner aquí la expresión      
        end
        
        % Voltaje térmico
        function Vt = voltaje_termico(T)
           kB = 1.380649e-23; %J K-1
           qe = 1.6e-19; %C
                
           obj.T = T;
           obj.Vt = kB*T/qe;
        end
        
    end

end
