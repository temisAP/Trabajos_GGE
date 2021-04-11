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
    properties (Access = public)
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
        function I = current(obj,VAR,T,G,var_name)
            
            %Asignar la resistencia o el voltaje
            switch var_name
                case 'R'
                    obj.R = VAR;
                case 'V'
                    obj.V = VAR;
            end
            
            %Obtener el voltaje térmico
            obj.voltaje_termico(T);
            
            %Modificar según la irradiancia y la temperatura
            obj.enviroment_influence(T,G)
            
            % Obtener la intensiad para la resistencia dada
            switch obj.Modelo.name
                case 'KyH'
                    current_kyh(obj,var_name);
                case '1d2r'
                    current_1d2r(obj,var_name);
            end
            I = obj.I;
            
        end
    end
    
    methods (Access = private)
        
        function enviroment_influence(obj,T,G)
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
            
            obj.parametros = zeros(4,length(T));
            obj.parametros(1,:) = Isc;
            obj.parametros(2,:) = Imp;        %Estos son a los que acceden los modelos
            obj.parametros(3,:) = Vmp;
            obj.parametros(4,:) = Voc;
        end
        
        % Corriente KyH
        function I = current_kyh(obj,var)
            
            % Puntos característicos
            Isc = obj.parametros(1,:);
            Imp = obj.parametros(2,:);
            Vmp = obj.parametros(3,:);
            Voc = obj.parametros(4,:);
            
            for i = 1:length(Vmp)
                if  abs(Vmp(i)) > 1e3
                    % Intensidad
                    I(i) = 0;
                else
                    alpha = Vmp(i)/Voc(i);
                    beta = Imp(i)/Isc(i);
                    % Ajuste analítico
                    K = (1-beta-alpha)./(2*beta-1);
                    aux = -(1./alpha).^(1./K).*(1./K).*log(alpha);
                    m = real((lambert(obj,aux)./log(alpha))+(1./K)+1);
                    gamma = (2*beta-1)./((m-1).*alpha.^m);
                    
                    switch var
                        case 'R'
                            % Resistencia adimensional
                            r = obj.R/(Voc(i)/Isc(i));
                            % Intensidad
                            I(i) = (fzero(@(x) 1-(1-gamma)*x*r-gamma*(x*r)^m-x,1))*Isc(i);
                        case 'V'
                            V = obj.V;
                            I(i) = (1-(1-gamma)*(V/Voc(i))-gamma*(V/Voc(i))^m)*Isc(i);
                    end
                end
            end
            
            % Intensidades
            obj.I = I;
            
        end
        
        % Corriente 1d2r
        function I = current_1d2r(obj,var)
            
            % Puntos característicos
            Isc = obj.parametros(1,:);
            Imp = obj.parametros(2,:);
            Vmp = obj.parametros(3,:);
            Voc = obj.parametros(4,:);
            
            for i=1:length(Vmp)
                if abs(Vmp(i)) > 1e3 %i.e. cuando no hay irradiancia
                    % Intensidad
                    I(i) = 0;
                else
                    a = obj.Modelo.a;
                    Vt = obj.Vt(i);
                    % Ajuste analítico
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
                    % Intensidad
                    u = [Ipv(i);I0(i);Rs(i);Rsh(i);obj.Modelo.a];
                    switch var
                        case 'R'
                            I(i) = fzero(@(I) u(1)-u(2)*(exp((obj.R*I+u(3)*I)/(Vt*u(5)))-1)-(obj.R*I+u(3)*I)/u(4)-I, 0);
                        case 'V'
                            I(i) = fzero(@(I) u(1)-u(2)*(exp((obj.V+u(3)*I)/(Vt*u(5)))-1)-(obj.V+u(3)*I)/u(4)-I, 0);
                    end                
                end
            end
            
            % Intensidades
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
