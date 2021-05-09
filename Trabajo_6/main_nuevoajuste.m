clc
clear all
close all

    % Load experimental data


try
    load('Data\Bateria_Dinamica_Experimental.mat')
catch
    disp('No se ha creado el archivo de datos')
    return
end

[MAT, V] = matrix(Data);

%MAT(:,2) = - MAT(:,2);

% Load static behaviour data 

try
    load('Data\Modelos.mat')
catch
    disp('No se ha incluido el archivo de modelos')
    return
end
%Analitico

load('C1_data/C1.mat');
load ('R1.mat');
C2 = 1000;


R_s1 = R1;
R_s2 = 0.01;

%% Valores de los trabajos anteriores

 pc_check =[24.159028155390455;-3.294182823595574e-06;0.137687348168866;3.496647512653960e-12;-2.439240769984952e-05;-1.000000000000000e-05;-1.000000000000000e-05;-1.500000000000000e-16]
 pd_check =[24.160725029756357;-3.605015688912432e-06;0.128443935982512;-3.544595664378547e-11;2.020480643760769e-05;-1.000000000000000e-05;-1.000000000000000e-05;-3.053198017586264e-07];


%% AJUSTE MODELO DESCARGA

beta0d2 = [12.15 -1.4357e-05 0.059666 3.1792e-14 1.7216e-14 -2.9258e-13 -6.6763e-06 0.00018236];
 
 myfunction = @(p,MAT) (p(1) + p(2)*(MAT(:,2)+p(3)*MAT(:,3)))  + ...
        (p(4) + p(6)*MAT(:,1) + p(7).*(MAT(:,1).*MAT(:,1))).*exp((p(5) + p(8)*MAT(:,1)).*(MAT(:,2)+p(3)*MAT(:,3))) + p(3)*MAT(:,1) ;
    
 opts = statset('Display','off','TolFun',1e-16);
 val = fitnlm(MAT, V, myfunction, beta0d2,'Options',opts);
 beta0d2(:) = table2array(val.Coefficients(1:8,1));
 
 p=beta0d2;
% p(3)=0.128443935982512;
% p=pd_check;
 E_des = (p(1) + p(2)*(MAT(:,2)+p(3)*MAT(:,3)))  + ...
        (p(4) + p(6)*MAT(:,1) + p(7).*(MAT(:,1).*MAT(:,1))).*exp((p(5) + p(8)*MAT(:,1)).*(MAT(:,2)+p(3)*MAT(:,3))) ;
   
 V_des = E_des + p(3)*MAT(:,1);
    
DV_des = V_des +p(3)*MAT(:,1);
    
 Rsd = p(3);
%% AJUSTE MODELO CARGA
 
 beta0c =[p(1) p(2) 0.15];

 myfunction = @(pc,MAT) (pc(1) + pc(2).*(MAT(:,2)+pc(3).*MAT(:,3)) ) + pc(3).*MAT(:,1) ;

 val = fitnlm(MAT, V, myfunction, beta0c,'Options',opts);
     pc(:) = table2array(val.Coefficients(1:3,1));

 beta0c1 = [pc(1) pc(2) pc(3) -1e-14 2.6e-13];
 
%Exp


 myfunction = @(pc1,MAT) (pc1(1) + pc1(2).*(MAT(:,2)+pc1(3).*MAT(:,3)) ) + ...
                pc1(4).*exp(pc1(5).*(MAT(:,2)+pc1(3).*MAT(:,3))) + pc1(3).*MAT(:,1) ;
 val = fitnlm(MAT, V, myfunction, beta0c1,'Options',opts);
 
 pc2(:) = table2array(val.Coefficients(1:5,1));

 beta0c2 = [p(1) p(2) p(3) p(4) p(5) 8e-07];


%Exp-lineal

 myfunction = @(pc2,MAT) (pc2(1) + pc2(2).*(MAT(:,2)+pc2(3).*MAT(:,3)))  + ...
               (pc2(4)).*exp((pc2(5) + pc2(6).*MAT(:,1)).*(MAT(:,2)+pc2(3).*MAT(:,3))) + pc2(3).*MAT(:,1) ;

 val = fitnlm(MAT, V, myfunction, beta0c2,'Options',opts);
 pc3(:) = table2array(val.Coefficients(1:6,1));   

% pc3 =[24.504854148612687,-4.622806382560464e-06,0.0875,1.041085732423661,-0.908856458443049,0.126041193590313];
%  pc3(3)  =0.137687348168866;
%  pc3 = pc_check;

 E_car = (pc3(1) + pc3(2).*(MAT(:,2)+pc3(3).*MAT(:,3)))  + ...
         (pc3(4)).*exp((pc3(5) + pc3(6).*MAT(:,1)).*(MAT(:,2)+pc3(3).*MAT(:,3))) ;
     
   
 V_car = E_car + pc3(3).*MAT(:,1) ;
 
DV_car = V_car + +p(3)*MAT(:,1);
Rsc =  pc3(3);
td = Data.t;

   %% Get transitory curves

for t=1:length(Data.t)
    if Data.I(t) >= 0
        DeltaV(t) = Data.V(t) - V_des(t);
    else
        DeltaV(t) = Data.V(t) - V_car(t);
    end
    
end
     %%
 % Voltaje
h = figure(1); %set(h, 'Visible', 'off')
   hold on
   plot(Data.t, Data.V, '-',...
       'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Datos experimentales')     
    plot(Data.t, V_car, '--',...
     'LineWidth', 1.5, 'Color', 'k', 'DisplayName', "Modelo est\'atico (carga)")
   plot(Data.t, V_des, ':',...
       'LineWidth', 1.5, 'Color', 'k', 'DisplayName', "Modelo est\'atico (descarga)")  
   grid on; box on;
   legend('Interpreter', 'Latex', 'Location', 'Best')
   xlabel('$t$ [s]','Interpreter','latex');
   ylabel({'$|V|$';'[V]'},'Interpreter','latex');
   %Save_as_PDF(h, ['Figures/','Extract_data'],'horizontal', 0, 0);
   %close
   
   % Delta
h = figure(2); %set(h, 'Visible', 'off')
   hold on
   plot(Data.t, DeltaV, '-',...
       'LineWidth', 1.5, 'Color', 'k')       
   grid on; box on;
   xlabel('$t$ [s]','Interpreter','latex');
   ylabel({'$|\Delta V|$';'[V]'},'Interpreter','latex');
%    Save_as_PDF(h, ['Figures/','Delta_V'],'horizontal', 5, 7.5);
   %close   


%% Functions

% Para ordenar los datos experimentales para fitnlm
function [MAT, V] = matrix(data)
I     = [];
phi1  = [];
phi2  = [];
V     = [];
for d = 1:length(data)
    I     = [I ; data(d).I];
    phi1  = [phi1 ; data(d).phi1];
    phi2  = [phi2 ; data(d).phi2];
    V     = [V ; data(d).V];
end
MAT = [I,phi1,phi2];
end