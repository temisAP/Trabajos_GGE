%%%%% Matriz de puntos caracteristicos de cada IV curve 

load('Puntos_caracteristicos.mat')
% Isc = M(1,:);
% Imp = M(2,:);
% Vmp = M(3,:);
% Voc = M(4,:);
% betha = M(5,:);
% alpha = M(6,:);
% k = M(7,:);

%% Karmalkar & Haneefa’s model

K = zeros(1,size(M,2));
for i = 1:size(M,1)
   K(i) = (1-(M(2,i)/M(1,i))-(M(3,i)/M(4,i)))/(2*(M(2,i)/M(1,i))-1);
   %m(i) = Buscar info de W-1
end
