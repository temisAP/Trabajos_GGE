function val = analytic2d2r(Rsh0, Rs0)

    load('wksp.mat');
    
    disp('***')
    Rsh0
    Rs0
    disp('***')
    
    try 
        % Calcular el resto de parametros
        a2=2;
        [Ipv,I01,I02,Rs,Rsh,a1] = param_2D2R(Isc,Voc,Imp,Vmp,a2,Rsh0, Rs0);
        umin = [Ipv,I01,I02,Rs,Rsh,a1,a2];

        % Discretizacion de la solucion para representarla
        I_modelo2 = zeros(size(V_mess,2),1)';
        for i=1:size(V_mess,2)
            I_modelo2(i) = Panel_Current_2D2R(umin,V_mess(i));
        end
        error = (sum((I_modelo2 - I_mess).^2))^0.5;
        error2 = (((I_modelo2 - I_mess).^2)).^0.5;

        val = error;
    
        save('wksp.mat');
    catch
        val = 1e6;
    end
        
    
end