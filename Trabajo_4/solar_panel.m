classdef solar_panel < handle  % Este < significa que hereda métodos y funciones de la otra clase
    
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
        Parametros;     % Los parámetros del modelo
        % Del entorno
        G;              %Irradiancia
        T;              %Temperatura
        theta;          %Ángulo de incidencia

    end
    %% Métodos
    methods (Access = public)
        
        % Constructor 
        function obj = solar_panel(N_serie, N_paralelo)
            if nargin > 0
                obj.N_serie = N_serie;  
                obj.N_paralelo = N_paralelo;   
            end
        end 
        
        % Correinte para theta,T y R dados
        function I = current(obj,theta,T,R)
            
            switch obj.Modelo
                case 'KyH'
                    I=0;
                    %current_kyh();
                case '1d2r'
                    current_1d2r();
            end
            
            I = 0;
        end
    end
    methods (Access = public)
        % Coseno de kelly
        function kcos = Kelly_cos(obj,theta)
            limit = obj.Kelly_cosine_Limit;        
            cte = 90/limit;
            kcos = zeros(size(theta));
            kcos(theta >= 0 & theta < limit) = cos(theta(theta >= 0 & theta < limit)*cte);
        end
        
        % Corriente según modelo
        function current_kyh(obj)
            obj.I = 0;
            % poner aquí la expresión
            
        end
        function current_1d2r(obj)
            obj.I = 0;
            % poner aquí la expresión      
        end
        
        % Voltaje térmico
        function voltaje_termico(obj,T)
           kB = 1.380649e-23; %J K-1
           qe = 1.6e-19; %C
                
           obj.T = T;
           obj.Vt = kB*T/qe;
        end
    end
end
