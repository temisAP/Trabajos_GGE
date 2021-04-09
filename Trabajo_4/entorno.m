classdef entorno < handle
    %% Atributos
    properties
        % Atributos del entorno
        T_max;          % K
        T_min;          % K
        Go;             % W/m^2

        % Atributos de "salida"
        G;              % W/m^2
        T;              % K
        theta;          % rad        
    end
    
    %% Métodos
    methods
        function obj = entorno(Go, T_max, T_min)
            if nargin > 0
                obj.Go = Go;
                obj.T_max = T_max;
                obj.T_min = T_min;
            end
        end
        
        % Angulo de incidencia y temperatura en función del tiempo
        function [theta, G, T] = simulacion(obj, t, w, cos_K_lim, desfase_P, desfase_T)    
            
            theta = w*t;
            obj.theta = theta;
            
            check2=obj.Inclinacion_Sol_Panel_ft(w, t, desfase_P, cos_K_lim);

            G = obj.Go*obj.Inclinacion_Sol_Panel_ft(w, t, desfase_P, cos_K_lim);
            obj.G = G;
             
            T = obj.Temperatura_Panel_ft(w, t, desfase_P, desfase_T, obj.T_max, obj.T_min);
            obj.T = T;
            
        end

        
        % Funciones que se usan para calcular la simulacion
        % Coseno de Kelly
        function kcos = Kelly_cos(obj, theta, cos_limit)

            cte = 90/cos_limit;
            limit = deg2rad(cos_limit);
            kcos = zeros(size(theta));
            kcos(theta >= 0 & theta < limit) = cos(theta(theta >= 0 & theta < limit)*cte);

        end
        
        % Normal Sol-Panel
        function [angulo, senal] = Normal_Sol_Panel(obj, w, t, desfase)

            angulo = acos(cos(w*t + desfase));      %rad
            senal = ones(size(angulo));
            senal(angulo>pi/2) = 0;
            
        end
        
        % Incidencia Panel
        function incidencia = Inclinacion_Sol_Panel_ft(obj, w, t, desfase_P, cos_limit)
            
            [angulo, senal] = obj.Normal_Sol_Panel(w, t, desfase_P);
            incidencia = senal.*obj.Kelly_cos(angulo, cos_limit);
            
        end

        % Temperatura con desfase respecto panel
        function temp = Temperatura_Panel_ft(obj, w, t, desfase_P, desfase_T, T_max, T_min)

            [angulo, senal] = obj.Normal_Sol_Panel(w, t, desfase_P-desfase_T);
            temp = (T_max+T_min)/2 + (T_max-T_min)/2*cos(angulo);

        end




        
      
    end
end
