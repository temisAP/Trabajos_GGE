function val = Rs41(Rs,Rs0,Rsh0,Isc,Imp,Voc,Vmp,a2,Vt)

    val = log((Rsh0*(Isc-Imp)-Vmp-a2*Vt*((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs)))/((Rsh0*Isc-Voc)-a2*Vt*((Rsh0-Rs0)/(Rs0-Rs)))) ...
        -(Vmp+Imp*Rs-Voc)*(((Rsh0-Vmp/Imp)/(Vmp/Imp-Rs))-(((Rsh0-Rs0)/(Rs0-Rs))*exp((Vmp+Imp*Rs-Voc)/(a2*Vt))))/...
        ((Rsh0*(Isc-Imp)-Vmp)-(Rsh0*Isc-Voc)*exp((Vmp+Imp*Rs-Voc)/(a2*Vt)));
    
    val = abs(val); %Para que busque el cero al minimizar
    
end