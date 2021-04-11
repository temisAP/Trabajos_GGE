classdef Satelite < handle
    
    %% Atributos
    properties
        solar_panel;    %El panel solar del satélite (objeto)   -> I
        enviroment;     %El entorno del satélite (objeto)       -> theta, T
        R;
        w   % rad/s
        desfase_P = -pi/2
        desfase_T
    end
    
    %% Métodos
    methods (Access = public)
        % Constructor
        function obj = Satelite(solar_panel,enviroment,R)
            if nargin > 0
                obj.solar_panel = solar_panel;
                obj.enviroment = enviroment;
                obj.R = R;
            end
        end
        
        function I = get_current(obj,time)
            
            [theta, G, T] = obj.enviroment.simulacion(...
                            time, obj.w, obj.solar_panel.Kelly_cosine_Limit,...
                            obj.desfase_P, obj.desfase_T);
                                        
            I = obj.solar_panel.current(obj.R,T,G,'R');
            
        end
        
        

    end
end

