function [Ipv,I01,I02,Rs,Rsh,a1] = param_2D2R(Isc,Voc,Imp,Vmp,a2,Rsh0, Rs0)

global Vt
% Paso 1: se asume que a2 =2
    a2=a2;
% Paso2: despejar Rs
    %{
    Valores iniciales
    Para s=1,3,4 : Rs_guess = 0.09
    Para s=2     : Rs_guess = 0.2
    Para s=3     : Rs=0.0802 (segun paper)
    Para s=5,6,7 : Rs_guess = 0.09 (no he probado otro pero este va)
    %}
    Rs_guess = 0.09;
        
    metodo = 'fminsearch';
    lb = 0;                 %Valor minimo de Rs
    ub = 5;                 %Valor maximo de Rs, (para no acotar poner [])
    switch metodo
        case 'fzero'
            Rs = fzero(@(R)Rs41(R,Rs0,Rsh0,Isc,Imp,Voc,Vmp,a2,Vt),Rs_guess);
        case 'fmincon'
            options= optimoptions('fmincon','Algorithm','interior-point');
            Rs = fmincon(@(R)Rs41(R,Rs0,Rsh0,Isc,Imp,Voc,Vmp,a2,Vt),1,[],[],[],[],lb,ub,options);
        case 'gamultiobj'
            options = optimoptions('gamultiobj','InitialPopulationMatrix', Rs_guess);
            Rs = gamultiobj(@(R)Rs41(R,Rs0,Rsh0,Isc,Imp,Voc,Vmp,a2,Vt),1,[],[],[],[],lb,ub,options);
        case 'particleswarm'
            options = optimoptions('particleswarm','InitialSwarmMatrix', Rs_guess);
            Rs = particleswarm(@(R)Rs41(R,Rs0,Rsh0,Isc,Imp,Voc,Vmp,a2,Vt),1,lb,ub,options);
        case 'fminsearch'     
           Rs =fminsearch(@(R)Rs41(R,Rs0,Rsh0,Isc,Imp,Voc,Vmp,a2,Vt),Rs_guess);
    end
        
% Paso 4 
    B1 = ((Rsh0*(Isc-Imp)-Vmp)-(Rsh0*Isc-Voc)*exp((Vmp + Imp*Rs-Voc)/(a2*Vt)));% Paso 3 Obtener el parámetro a1
    B2 = ((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs)-((Rsh0-Rs0)/(Rs0-Rs))*exp((Vmp+Imp*Rs-Voc)/(a2*Vt)));
    a1Vt = B1/B2;
    a1 = a1Vt/Vt;
    % a1 = 0.9980

% Paso 5: se despejan I01 e I02
    I01 = a1/(a2-a1)*exp(-Voc/(a1*Vt))*(a2*Vt*(Rsh0-Rs0)-(Rs0-Rs)*(Rsh0*Isc-Voc))/((Rsh0-Rs)*(Rs0-Rs));% Paso 4 obtener I_01
    I02 = a2/(a1-a2)*exp(-Voc/(a2*Vt))*(a1*Vt*(Rsh0-Rs0)-(Rs0-Rs)*(Rsh0*Isc-Voc))/((Rsh0-Rs)*(Rs0-Rs)); % Paso 5 obtener I_02
% Paso 6 Obtener Rsh
    Rsh = Rsh0-Rs;
% Paso 7 Obtener Ipv
    Ipv = (Rsh+Rs)/Rsh*Isc; 
end