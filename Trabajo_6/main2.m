clc
clear all
close all

    % Load experimental data


try
    load('Data\Bateria_Dinamica_Experimental.mat')
    load('Data\Datos_Suavizados.mat')
catch
    disp('No se ha creado el archivo de datos')
    return
end

[MAT, V] = matrix(Data);

V = Datos_Suavizados;

%MAT(:,2) = - MAT(:,2);

% Load static behaviour data 

try
    load('Data\Modelos.mat')
catch
    disp('No se ha incluido el archivo de modelos')
    return
end
%Analitico

load('C1.mat');
load ('R1.mat');
C2 = 1000;


R_s1 = R1;
R_s2 = 0.01;



%% Modelo Descarga
% pd_check =[24.160725029756357;-3.605015688912432e-06;0.128443935982512;-3.544595664378547e-11;2.020480643760769e-05;-1.000000000000000e-05;-1.000000000000000e-05;-3.053198017586264e-07];

%Trabajo 5
p = [24.159028155390455;-3.294182823595574e-06;0.137687348168866;3.496647512653960e-12;-2.439240769984952e-05;-1.000000000000000e-05;-1.000000000000000e-05;-1.500000000000000e-16];

%Reajustado T6

p = [24.504854148626208,-4.622806382621923e-06,0.137809634587250,3.773216904982680,-0.404856007194418,-3.766309568515984,-1.169935068552460,0.011636147017692];
E_des = (p(1) + p(2)*(MAT(:,2)+p(3)*MAT(:,3)))  + ...
        (p(4) + p(6)*MAT(:,1) + p(7).*(MAT(:,1).*MAT(:,1))).*exp((p(5) + p(8)*MAT(:,1)).*(MAT(:,2)+p(3)*MAT(:,3)));
V_des = E_des + p(3)*MAT(:,1); 
Rsd = p(3);
%% Modelo Carga

pc_check =[24.159028155390455;-3.294182823595574e-06;0.137687348168866;3.496647512653960e-12;-2.439240769984952e-05;-1.000000000000000e-05;-1.000000000000000e-05;-1.500000000000000e-16];
%pc3 = [24.159028155390455;-3.294182823595574e-06;0.085;3.496647512653960e-12;-2.439240769984952e-05;-1.000000000000000e-05;-1.000000000000000e-05;-1.500000000000000e-16];
pc3 = [24.504854148612687,-4.622806382560464e-06,0.0855,1.041085732423661,-0.908856458443049,0.126041193590313];

E_car = (pc3(1) + pc3(2).*(MAT(:,2)+pc3(3).*MAT(:,3)))  + ...
         (pc3(4)).*exp((pc3(5) + pc3(6).*MAT(:,1)).*(MAT(:,2)+pc3(3).*MAT(:,3)));
     
   
 V_car = E_car + pc3(3).*MAT(:,1) ;
    
Rsc = pc3(3);   

td = Data.t;
%%
 % Voltaje
h = figure(1); %set(h, 'Visible', 'off')
   hold on
   plot(Data.t, V, '-',...
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
    
    
    
    