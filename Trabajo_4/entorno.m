classdef entorno < handle
    %% Atributos
    properties
        w;              %Velocidad angular
        desfase_P = 0;
        desfase_T = 0;
        T_max;
        T_min;
        
        % Atributos de "salida"
        theta; %rad
        T;
    end
    
    %% Métodos
    methods
        function obj = entorno(w,desfase_P,desfase_T,T_max,T_min)
            if nargin > 0
                obj.w = w;  
                obj.desfase_P = desfase_P; 
                obj.desfase_T = desfase_T; 
                obj.T_max = T_max;
                obj.T_min = T_min;
            end
        end
        % Ángulo de incidencia y temperatura en función del tiempo
        function [T, theta] = get_enviroment(obj,t,phi)    
            
            obj.theta = acos(cos(obj.w*t + phi));      %rad
            obj.T = (obj.T_max+obj.T_min)/2 + (obj.T_max-obj.T_min)/2*cos(obj.theta);
            
            if obj.theta > pi/2
                obj.theta = 0;      %Esto ya lo pones tú bonito @DelRio
            end
            
            T = obj.T;
            theta = obj.theta;
            
            
        end
        
        
    end
end
