classdef solar_panel < handle  % Este < significa que hereda métodos y funciones de la otra clase
    
    %% Atributos
    properties (Access = public)
        % Eléctricas
        I;
        V;
        R;
        Vt;
        alpha;
        % De las células
        N_serie;
        N_paralelo;  
        Kelly_cosine_Limit;
        Modelo;                 % El modelo que las representa (name, parameters = [Isc Imp Vmp Voc], Tref, Gref)
        % Del entorno
        G;              %Irradiancia
        T;              %Temperatura
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
        
        % Corriente para theta,T y R dados
        function I = current(obj,T,G,theta, R)
                 
            %Asignar la resistencia
            obj.R = R;
            
            %Obtener el voltaje térmico
            obj.voltaje_termico(T);
            
            %Modificar según la irradiancia y la temperatura (de
            %momento esto es un pistazo por mi parte)
            
            delta_T = T-obj.Modelo.Tref;
            
            Gref = obj.Modelo.Gref;
            a    = obj.Modelo.a;
            Vt   = obj.Vt;
            
            %Puntos característicos teniendo en cuenta la temperatura
            %e irrandiancia
            Isc = G/Gref.*(obj.Modelo.parameters(1)*ones(size(T)) + delta_T*obj.alpha(1));
            Imp = G/Gref.*(obj.Modelo.parameters(2)*ones(size(T)) + delta_T*obj.alpha(2));            
            Vmp = obj.Modelo.parameters(3)*ones(size(T)) + delta_T.*obj.alpha(3) + a*Vt.*log(G./Gref);
            Voc = obj.Modelo.parameters(4)*ones(size(T)) + delta_T.*obj.alpha(4) + a*Vt.*log(G./Gref); 
            
            
            obj.parametros(1,:) = Isc;
            obj.parametros(2,:) = Imp;        %Estos son a los que acceden los modelos
            obj.parametros(3,:) = Vmp;
            obj.parametros(4,:) = Voc;    

            
            % Obtener la intensiad para la resistencia dada
            switch obj.Modelo.name
                case 'KyH'
                    current_kyh(obj);
                case '1d2r'
                    current_1d2r(obj);
            end 
            I = obj.I;
            
        end
    end
    methods (Access = private)
                
        % Corriente KyH
        function I = current_kyh(obj)
            
            % Puntos característicos 
            Isc = obj.parametros(1,:);
            Imp = obj.parametros(2,:);
            Vmp = obj.parametros(3,:);
            Voc = obj.parametros(4,:);    
            
            % Restricciones para la optimización
            A_V0 = zeros(length(Vmp),length(Vmp));
            b_V0 = zeros(1,length(Vmp));
            
            for i = 1:length(Vmp)
                if  abs(Vmp(i)) > 1e3
                    Isc(i) = 0;
                    Imp(i) = 0;
                    Vmp(i) = 1;
                    Voc(i) = 1;
                    
                    V0(i) = 0;
                    A_V0(i,i) = 1;
     
                    gamma(i) = 0;
                    m(i) = 0;
                    I(i) = 0;
                else      
                    alpha = Vmp(i)/Voc(i);
                    beta = Imp(i)/Isc(i);                 
                    % Ajuste analítico 
                    K = (1-beta-alpha)./(2*beta-1);
                    aux = -(1./alpha).^(1./K).*(1./K).*log(alpha);
                    m(i) = real((lambert(obj,aux)./log(alpha))+(1./K)+1);
                    gamma(i) = (2*beta-1)./((m(i)-1).*alpha.^m(i));
                    V0(i) = Vmp(i)*0.5;
                    
                     
                    r = obj.R/(Voc(i)/Isc(i));
                    
                    I(i) = (fzero(@(x) 1-(1-gamma(i)).*x*r-gamma(i).*(x*r).^m(i)-x, 1))*Isc(i);
                    
                end
                
                
            end


            % Intensidad 
            
            obj.I = I;
                 
        end
        
        % Corriente 1d2r
        function I = current_1d2r(obj)
            
            % Puntos característicos 
            Isc = obj.parametros(1,:);
            Imp = obj.parametros(2,:);
            Vmp = obj.parametros(3,:);
            Voc = obj.parametros(4,:);   
            
            % Restricciones para la optimización
            A_V0 = zeros(length(Vmp),length(Vmp));
            b_V0 = zeros(1,length(Vmp));
            
                   
            for i=1:length(Vmp)
                if abs(Vmp(i)) > 1e3 %i.e. cuando no hay irradiancia
                    Isc(i) = 0;
                    Imp(i) = 0;
                    Vmp(i) = 1;
                    Voc(i) = 1;
                    
                    A_V0(i,i) = 1;
                    V0(i) = 0;
     
                    Ipv(i) = 0;
                    I0(i) = 0;
                    Rs(i) = 0;
                    Rsh(i) = 1;
                    f(i) = 0;
                    I(i) = 0;
                else                   
                    % Ajuste analítico 
                    a = obj.Modelo.a;
                    Vt = obj.Vt(i);
                    
                    A=-(2*Vmp(i)-Voc(i))./(a.*Vt)+(Vmp(i).*Isc(i)-Voc(i).*Imp(i))./(Vmp(i).*Isc(i)+Voc(i).*(Imp(i)-Isc(i)));
                    B=-Vmp(i).*(2*Imp(i)-Isc(i))./(Vmp(i).*Isc(i)+Voc(i).*(Imp(i)-Isc(i)));
                    C=a.*Vt./Imp(i);
                    D=(Vmp(i)-Voc(i))./(a.*Vt);
                    %%%
                    M1=0.3361;
                    M2=-0.0042;
                    M3=-0.0201;
                    sigma = -1-log(-B)-A;
                    Wn =-1-sigma -2/M1* (1-1./(1+M1*sqrt(sigma/2)./(1+M2*sigma.*exp(M3*sqrt(sigma)))) );
                    %%%
                    Rs(i)=C.*(Wn-(D+A));
                    Rsh(i)=(Vmp(i)-Imp(i).*Rs(i)).*(Vmp(i)-Rs(i).*(Isc(i)-Imp(i))-a.*Vt)./((Vmp(i)-Imp(i).*Rs(i)).*(Isc(i)-Imp(i))-a.*Vt.*Imp(i));
                    Ipv(i)=(Rsh(i)+Rs(i))./Rsh(i).*Isc(i);
                    I0(i)=((Rsh(i)+Rs(i))./Rsh(i).*Isc(i)-Voc(i)./Rsh(i))./(exp((Voc(i))./(a.*Vt)));
                    
                    f(i) = 1;
                    V0(i) = Vmp(i)*0.01;
                    
                    
                    u = [Ipv(i);I0(i);Rs(i);Rsh(i);obj.Modelo.a];
                    
%                     V_sol(i) = fzero(@(V) (u(1)-u(2).*(exp((V+u(3).*V/obj.R)./(Vt .*u(5)))-1)-(V+u(3).*V/obj.R)./u(4)) - V / obj.R , Voc(i));
                    
                    I(i) = fzero(@(I) u(1)-u(2)*(exp((obj.R*I+u(3)*I)/(Vt*u(5)))-1)-(obj.R*I+u(3)*I)/u(4)-I, 0);
                                  
                    
                    
                end
            end
  
%             u = [Ipv;I0;Rs;Rsh;obj.Modelo.a*ones(size(obj.Vt))];
                
            % Intensidad
%             obj.V = fmincon(@(V) ...
%                 abs(sum((u(1,:)-u(2,:).*(exp((V+u(3,:).*V/obj.R)./(obj.Vt .*u(5,:)))-1)-(V+u(3,:).*V/obj.R)./u(4,:)).*f- V / obj.R))...
%                 ,V0,[],[],A_V0,b_V0);
%             
%              obj.I = V_sol/ obj.R;
            obj.I = I;
        
        end
        
        % Voltaje térmico
        function voltaje_termico(obj,T)
           kB = 1.380649e-23; %J K-1
           qe = 1.6e-19; %C
           n = obj.N_paralelo;
                
           obj.T = T;
           obj.Vt = n*kB*T/qe;
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
            f_sigma = (0.23766*sqrt(sigma))./(1-0.0042*sigma.*exp(-0.0201*sqrt(sigma)));
            W = -1 - sigma - 5.95061*(1-1./(1+f_sigma));
        end 
        
        
    end
end
