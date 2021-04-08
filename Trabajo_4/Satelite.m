classdef Satelite < handle
    
    %% Atributos
    properties
        solar_panel;    %El panel solar del satélite (objeto)   -> I
        enviroment;     %El entorno del satélite (objeto)       -> theta, T
        R;
    end
    
    %% Métodos
    methods (Access = public)
        % Constructor
        function obj = Satelite(solar_panel,enviroment,R)
            obj.solar_panel = solar_panel;
            obj.enviroment = enviroment;
            obj.R = R;
        end
        
        function I = get_current(obj,time,phi)
            [T, theta] = obj.enviroment.get_enviroment(time,phi);
            I = obj.solar_panel.current(T,theta,obj.R);
        end
        
        

    end
end

