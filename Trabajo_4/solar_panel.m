classdef solar_panel < handle  % Este < significa que hereda métodos y funciones de la otra clase
    
    %% Atributos
    properties
        % Eléctricas
        I=1;
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
            
            %Asignar la resistencia
            obj.R = R;
            
            %Obtener el voltaje térmico
            voltaje_termico(obj,T);
            
            %Determinar la irradiancia
            % Aquí habrá que meter algo con theta supongo
            
            fmincon(@(V) my_current(obj,V),10);
            
            I = obj.I;
        end
    end
    methods (Access = private)
        % Corriente (para el optimizador)
        function val = my_current(obj,V)
            
            % Intensidad correspondiente al modelo
            switch obj.Modelo
                case 'KyH'
                    current_kyh(obj,V);
                case '1d2r'
                    current_1d2r(obj,V);
            end
            
            % Intensidad correspondiente a la resistencia
            I = V / obj.R; 
             
            % Tienen que coincidir
            val = I-obj.I;
        end
        
        % Coseno de kelly
        function kcos = Kelly_cos(obj,theta)
            limit = obj.Kelly_cosine_Limit;        
            cte = 90/limit;
            kcos = zeros(size(theta));
            kcos(theta >= 0 & theta < limit) = cos(theta(theta >= 0 & theta < limit)*cte);
        end
        
        % Corriente según modelo
        function current_kyh(obj,V)
            
            % Aquí hay que ajustar el modelo porque depende de la
            % temperatura, así que habrá que meter como atributo el struct
            % con los datos
            
            m = obj.Parametros(1);
            gamma = obj.Parametros(2);
            Voc = obj.Parametros(3);
            Isc = obj.Parametros(4);
            
            obj.I = (1-(1-gamma)*(V/Voc)-gamma*(V/Voc).^m)*Isc;
                
        end
        function current_1d2r(obj,V)
            
            % Aquí hay que ajustar el modelo porque depende de la
            % temperatura, así que habrá que meter como atributo el struct
            % con los datos
            
            u = obj.Parametros;        
            
            obj.I = fzero(@(I) u(1)-u(2)*(exp((V+u(3)*I)/(obj.Vt*u(5)))-1)-(V+u(3)*I)/u(4)-I, 0);   
        
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
