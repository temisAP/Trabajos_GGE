classdef Satelite
    
    %% Atributos
    properties
        solar_panel; %El panel solar del satélite (objeto)
        T;
        theta;
    end
    
    %% Métodos
    methods
        % Constructor
        function obj = Satelite(solar_panel)
            obj.solar_panel = solar_panel;
        end
        
        function incidencia = Inclinacion_Sol_Panel_ft(w, t)
            
            desfase = -pi/2;
            [angulo, senal] = Normal_Sol_Panel(w, t, desfase);
            
            incidencia = senal.*Kelly_cos(angulo);
            
        end
        
        function temp = Temperatura_Panel_ft(w, t, desfase_T, T_max, T_min)
            
            desfase_P = -pi/2;
            [angulo, senal] = Normal_Sol_Panel(w, t, desfase_P-desfase_T);
            
            temp = (T_max+T_min)/2 + (T_max-T_min)/2*cos(angulo);
            
        end
        
        
    end
end

