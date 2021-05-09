clc
clear all
close all

%% Load data

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


%% Create E values for each phi (both are running while simulation, diodes cut current)

% % Discharge

p= modelos_descarga(6).modelo.Coefficients.Estimate;
pd=p;
%p(3) = 0.1378; % Rd
p(2) = -3.294182823595574e-06; % E0
V_des = modelos_descarga(6).modelo.Formula.ModelFun(p,MAT); 
 Rsd = p(3);
E_des = V_des - Rsd*MAT(:,1); 
%%

% Charge

p = modelos_carga(6).modelo.Coefficients.Estimate;
%p(3) = 0.0885;
V_car = modelos_carga(6).modelo.Formula.ModelFun(p,MAT);
Rsc = p(3);
E_car = V_car - Rsc*MAT(:,1);
td = Data.t;
%Condensadores
C1_i = C1;
C2 = 1000;


R_s1 = R1;
R_s2 = 0.01;

% Rint = Rsd-R_s1;

save('td_Ec_Ed.mat','td','E_des','E_car'); 
%% Get transitory curves

for t=1:length(Data.t)
    if Data.I(t) >= 0
        DeltaV(t) = Data.V(t) - V_des(t);
    else
        DeltaV(t) = Data.V(t) - V_car(t);
    end
    
end

%% Plot 
   

colors = [0, 0.4470, 0.7410;
          [220,20,6]/255;
          [255,140,0]/255;
          [139,0,139]/255;
          [50,205,50]/255];
      
% Voltaje
h = figure(1); %set(h, 'Visible', 'off')
   hold on
   plot(Data.t, Data.V, 'LineWidth', 1.5, 'Color', colors(1,:), 'DisplayName', 'Datos experimentales')     
   plot(Data.t, V_car, 'LineWidth', 1.5, 'Color', colors(2,:), 'DisplayName', "Modelo est\'atico (carga)")
   plot(Data.t, V_des,'LineWidth', 1.5, 'Color', colors(3,:), 'DisplayName', "Modelo est\'atico (descarga)")  
   xlim([0, Data.t(end)])
   grid on; box on;
   legend('Interpreter', 'Latex', 'Location', 'Best')
   xlabel('$t$ [s]','Interpreter','latex');
   ylabel({'$V$';'[V]'},'Interpreter','latex');
%    Save_as_PDF(h, ['Figures/','Extract_data'],'horizontal', 0, 0);
   %close

% Delta
h = figure(2); %set(h, 'Visible', 'off')
   hold on
   plot(Data.t, DeltaV, 'LineWidth', 1.5, 'Color', 'k')  
   xlim([0, Data.t(end)])
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


