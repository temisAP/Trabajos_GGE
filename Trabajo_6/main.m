clc
clear all
close all

%% Load data

% Load experimental data

try
    load('Data\DATOS_EXPERIMENTALES.mat')
catch
    disp('No se ha creado el archivo de datos')
    return
end

[MAT, V] = matrix(Data);

% Load static behaviour data 

try
    load('Data\Modelos.mat')
catch
    disp('No se ha incluido el archivo de modelos')
    return
end

%% Create E values for each phi (both are running while simulation, diodes cut current)

% Discharge

p = modelos_descarga(9).modelo.Coefficients.Estimate;
V_des = modelos_descarga(9).modelo.Formula.ModelFun(p,MAT); 
E_des = V_des - p(3)*MAT(:,1); 

% Charge

p = modelos_carga(6).modelo.Coefficients.Estimate;
V_car = modelos_carga(6).modelo.Formula.ModelFun(p,MAT);
E_car = V_des - p(3)*MAT(:,1);


%% Get transitory curves

for t=1:length(Data.t)
    if Data.I(t) >= 0
        DeltaV(t) = Data.V(t) - V_des(t);
    else
        DeltaV(t) = Data.V(t) - V_car(t);
    end
    
end

%% Plot 

figure()
hold on
   plot(Data.t, Data.V)
   plot(Data.t, V_car)
   plot(Data.t, V_des)
   legend('Experimentales','Vcar','Vdes')
   
figure()
hold on
   plot(Data.t, DeltaV)
   legend('DeltaV')
      


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
