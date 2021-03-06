function [I_modelo] = Panel_Current_2D2R(umin,V_mess)
  
  global Vt
  
  Ipv = umin(1);
  I01 = umin(2);
  I02 = umin(3);
  Rs = umin(4);
  Rsh = umin(5);
  a1 = umin(6);
  a2 = umin(7);
  
    for i=1:size(V_mess,2)
            I_modelo(i) = fzero(@(I) Ipv - I01*(exp((V_mess(1,i)+I*Rs)/(a1*Vt))-1) - I02*(exp((V_mess(1,i)+I*Rs)/(a2*Vt))-1) - (V_mess(1,i)+I*Rs)/Rsh - I, 0);
    end
end