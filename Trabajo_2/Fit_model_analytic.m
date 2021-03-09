%%%%% Matriz de puntos caracteristicos de cada IV curve 
clear all
clc

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
m = zeros(1,size(M,2));
gamma = zeros(1,size(M,2));
for i = 1:size(M,1)
   K(i) = (1-(M(2,i)/M(1,i))-(M(3,i)/M(4,i)))/(2*(M(2,i)/M(1,i))-1);
   m(i) = (lambertw(-1,-(M(4,i)/M(3,i))^(1/K(i))*(1/K(i))*log(M(3,i)/M(4,i))))/(log(M(3,i)/M(4,i)))+(1/K(i))+1;
   gamma(i) = (2*M(2,i)/M(1,i)-1)/((m(i)-1)*(M(3,i)/M(4,i))^m(i));
   
end

%% Da's model

k_das = zeros(1,size(M,2));
h = zeros(1,size(M,2));

for i = 1:size(M,1)
    k_das(i)=lambertw(-1,M(2,i)/M(1,i)*log(M(3,i)/M(4,i)))/log(M(3,i)/M(4,i));
    h(i) = (M(4,i)/M(3,i))*(M(1,i)/M(2,i)-1/k_das(i)-1);
end