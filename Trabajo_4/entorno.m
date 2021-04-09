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

            G = obj.Go*obj.Inclinacion_Sol_Panel_ft(w, t, desfase_P, cos_K_lim);
            obj.G = G;
            
            T = obj.Temperatura_ft(w, t, desfase_T, obj.T_min, obj.T_max);
            obj.T = T;
            
            %T = obj.Temperatura_Panel_ft(w, t, desfase_P, desfase_T, obj.T_max, obj.T_min);
            %obj.T = T;
            
        end

        
        % Funciones que se usan para calcular la simulacion
        % Coseno de Kelly
        function kcos = Kelly_cos(obj, theta, cos_limit)

            cte = 90/cos_limit;
%             cte=1;
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
        function T = Temperatura_ft(obj, w, t, desfase_T, Tm, Tx)
            
            T = zeros(size(t));
            
            theta = w*t - desfase_T;
            theta = wrapTo2Pi(theta);
            
            thetai = pi/2; 
            thetaf = 2*pi;
            
            T(theta >= 0 & theta < pi/2) = ...
                Tm*exp( log(Tx/Tm)*theta(theta >= 0 & theta < pi/2)/thetai );
            
            T(theta > pi/2 & theta < 2*pi) = ...
                Tx*exp( log(Tm/Tx)*(theta(theta > pi/2 & theta < 2*pi)-thetai)/(thetaf-thetai) );
            

        end
        
        
        % Temperatura con desfase respecto panel
        function temp = Temperatura_Panel_ft(obj, w, t, desfase_P, desfase_T, T_max, T_min)
            
            
            [angulo, senal] = obj.Normal_Sol_Panel(w, t, desfase_P-desfase_T);
            temp = (T_max+T_min)/2 + (T_max-T_min)/2*cos(angulo);

        end
        
        
        % Temperatura al solecico
        function [T] = T_sol(theta, thetai, Tx, Tm)
            
            T = Tm*exp( log(Tx/Tm)*theta/thetai );

        end

        % Temperatura a la sombrica
        function [T] = T_sombra(theta, thetai, thetaf, Tx, Tm)
            
            T = Tx*exp( log(Tm/Tx)*(theta-thetai)/(thetaf-thetai) );

        end


        
      
    end
end
