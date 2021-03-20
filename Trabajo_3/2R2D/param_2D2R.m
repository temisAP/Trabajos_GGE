
function [Ipv,I01,I02,Rs,Rsh,a1] = param_2D2R(Isc,Voc,Imp,Vmp,a2,Rsh0, Rs0)

    % Paso2 despejar Rs
    
    global Vt
     
      Rs_guess = 0.09; %s=3,s =1, s =4;
%     Rs_guess = 0.2; %s =2
      

     Rs = fzero(@(Rs) log((Rsh0*(Isc-Imp)-Vmp-a2*Vt*((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs)))/((Rsh0*Isc-Voc)-a2*Vt*((Rsh0-Rs0)/(Rs0-Rs)))) ...
         -(Vmp+Imp*Rs-Voc)*(((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs))-(((Rsh0-Rs0)/(Rs0-Rs))*exp((Vmp+Imp*Rs-Voc)/(a2*Vt))))/...
         ((Rsh0*(Isc-Imp)-Vmp)-(Rsh0*Isc-Voc)*exp((Vmp+Imp*Rs-Voc)/(a2*Vt))),Rs_guess);
%      Rs=0.0802 s=3 paper
    
   B1 = ((Rsh0*(Isc-Imp)-Vmp)-(Rsh0*Isc-Voc)*exp((Vmp + Imp*Rs-Voc)/(a2*Vt)));% Paso 3 Obtener el parámetro a1
   B2 = ((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs)-((Rsh0-Rs0)/(Rs0-Rs))*exp((Vmp+Imp*Rs-Voc)/(a2*Vt)));
   a1Vt = B1/B2;
   a1 = a1Vt/Vt;
%    a1 = 0.9980
   I01 = a1/(a2-a1)*exp(-Voc/(a1*Vt))*(a2*Vt*(Rsh0-Rs0)-(Rs0-Rs)*(Rsh0*Isc-Voc))/((Rsh0-Rs)*(Rs0-Rs));% Paso 4 obtener I_01
   
   I02 = a2/(a1-a2)*exp(-Voc/(a2*Vt))*(a1*Vt*(Rsh0-Rs0)-(Rs0-Rs)*(Rsh0*Isc-Voc))/((Rsh0-Rs)*(Rs0-Rs)); % Paso 5 obtener I_02 
   
   Rsh = Rsh0-Rs;% Paso 6 Obtener Rsh
   
   Ipv = (Rsh+Rs)/Rsh*Isc; % Paso 7 Obtener Ipv
end