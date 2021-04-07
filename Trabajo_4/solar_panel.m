classdef solar_panel < handle  % Este < significa que hereda métodos y funciones de la otra clase
    
    %% Atributos
    properties (Access = public)
        % Eléctricas
        I;
        V;
        R;
        Vt;
        % De las células
        N_serie;
        N_paralelo;  
        Kelly_cosine_Limit;
        Modelo;                 % El modelo que las representa (name, parameters = [Isc Imp Vmp Voc], Tref)
        % Del entorno
        G;              %Irradiancia
        T;              %Temperatura
        theta;          %Ángulo de incidencia
    end
    properties (Access = private)
        parametros; % [Isc Imp Vmp Voc alpha beta]
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
            
            %Modificar según la irradiancia y la temperatura (de
            %momento esto es un pistazo por mi parte)
            
            Isc = obj.Modelo.parameters(1) * ones(size(T));
            Imp = obj.Modelo.parameters(2) * ones(size(T));
            Vmp = obj.Modelo.parameters(3) * ones(size(T));
            Voc = obj.Modelo.parameters(4) * ones(size(T));       
            alpha = Vmp/Voc;
            beta = Imp/Isc;
            
            obj.parametros(1,:) = Isc;
            obj.parametros(2,:) = Imp;        %Estos son a los que acceden los modelos
            obj.parametros(3,:) = Vmp;
            obj.parametros(4,:) = Voc;    
            obj.parametros(5,:) = alpha;
            obj.parametros(6,:) = beta;
            
            % Obtener la intensiad para la resistencia dada
            fmincon(@(V) my_current(obj,V),Vmp); 
            I = obj.I;
            
        end
    end
    methods (Access = private)
        % Corriente (para el optimizador)
        function val = my_current(obj,V)
            
            % Intensidad correspondiente al modelo
            switch obj.Modelo.name
                case 'KyH'
                    current_kyh(obj,V);
                case '1d2r'
                    current_1d2r(obj,V);
            end
            
            % Intensidad correspondiente a la resistencia
            I = V / obj.R; 
             
            % Tienen que coincidir
            val = sum(I-obj.I);
        end
                
        % Corriente KyH
        function current_kyh(obj,V)
            
            % Puntos característicos 
            Isc = obj.parametros(1);
            Imp = obj.parametros(2);
            Vmp = obj.parametros(3);
            Voc = obj.parametros(4);    
            alpha = obj.parametros(5);
            beta =  obj.parametros(6);
  
            % Ajuste analítico 
            K = (1-beta-alpha)/(2*beta-1);
            aux = -(1/alpha)^(1/K)*(1/K)*log(alpha);
            m = real((lambert(obj,aux)/log(alpha))+(1/K)+1);
            gamma = (2*beta-1)/((m-1)*alpha^m);

            % Intensidad 
            obj.I = (1-(1-gamma)*(V./Voc)-gamma*(V./Voc).^m).*Isc;
                
        end
        
        % Corriente 1d2r
        function current_1d2r(obj,V)
            
            % Puntos característicos 
            Isc = obj.parametros(1,:);
            Imp = obj.parametros(2,:);
            Vmp = obj.parametros(3,:);
            Voc = obj.parametros(4,:);    
            alpha = obj.parametros(5,:);
            beta =  obj.parametros(6,:);
  
            % Ajuste analítico 
            a = 1.3 * ones(size(obj.Vt));
            Vt = obj.Vt;
            %%%
            A=-(2*Vmp-Voc)./(a.*Vt)+(Vmp.*Isc-Voc.*Imp)./(Vmp.*Isc+Voc.*(Imp-Isc));
            B=-Vmp.*(2*Imp-Isc)./(Vmp.*Isc+Voc.*(Imp-Isc));
            C=a.*Vt./Imp;
            D=(Vmp-Voc)./(a.*Vt);
            %%%
            M1=0.3361;
            M2=-0.0042;
            M3=-0.0201;
            sigma = -1-log(-B)-A;
            Wn =-1-sigma -2/M1* (1-1./(1+M1*sqrt(sigma/2)./(1+M2*sigma.*exp(M3*sqrt(sigma)))) );
            %%%
            Rs=C.*(Wn-(D+A));
            Rsh=(Vmp-Imp.*Rs).*(Vmp-Rs.*(Isc-Imp)-a.*Vt)./((Vmp-Imp.*Rs).*(Isc-Imp)-a.*Vt.*Imp);
            Ipv=(Rsh+Rs)./Rsh.*Isc;
            I0=((Rsh+Rs)./Rsh.*Isc-Voc./Rsh)./(exp((Voc)./(a.*Vt)));
            %%%
            u = [Ipv;I0;Rs;Rsh;a];
                    
            % Intensidad
            obj.I = fmincon(@(I) sum(u(1,:)-u(2,:).*(exp((V+u(3,:).*I)./(obj.Vt .*u(5,:)))-1)-(V+u(3,:).*I)./u(4,:)-I),Imp);   
        
        end
        
        % Voltaje térmico
        function voltaje_termico(obj,T)
           kB = 1.380649e-23; %J K-1
           qe = 1.6e-19; %C
                
           obj.T = T;
           obj.Vt = kB*T/qe;
        end
        
        % Coseno de kelly
        function kcos = Kelly_cos(obj,theta)
            
            if isempty(obj.Kelly_cosine_Limit)
                kcos = cos(theta);
            else
                limit = obj.Kelly_cosine_Limit;        
                cte = 90/limit;
                kcos = zeros(size(theta));
                kcos(theta >= 0 & theta < limit) = cos(theta(theta >= 0 & theta < limit)*cte);
            end
            
        end
        
        % Función W de Lambert
        function W = lambert(obj,x)
            sigma = -1 - log(-x);
            f_sigma = (0.23766*sqrt(sigma))/(1-0.0042*sigma*exp(-0.0201*sqrt(sigma)));
            W = -1 - sigma - 5.95061*(1-1/(1+f_sigma));
        end 
        
        
    end
end
