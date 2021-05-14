clc
clear all
close all


load('HaCurvado2.mat')

C1_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(1, 1).Value; 
Rs1_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(2, 1).Value; 
Rsc_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(3, 1).Value; 
Rsd_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(4, 1).Value;

for i=1:4
parameters(i,1) = SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(i,1).Value;
end

save('C1_data/C1_parameters.mat','parameters');

Data_sim = load('C1_data/1C_data.mat');

try
    load('Data\Bateria_Dinamica_Experimental.mat')
catch
    disp('No se ha creado el archivo de datos')
    return
end


t_sim=Data_sim.Data_sim.time;
V_sim = Data_sim.Data_sim.Data;
% Error_sim = abs(Data.V-V_sim);
V_exp =Data.V;
t_exp =Data.t;

%Pintar Error
[val, pos] = intersect(t_sim, t_exp);
V = V_sim(pos);
dif_V = abs(V_exp - V);

rmse_1C_01 = RMSE(V_exp, V, length(V));

%%

colors = [0, 0.4470, 0.7410;
          [220,20,6]/255;
          [255,140,0]/255;
          [139,0,139]/255;
          [50,205,50]/255];
      
% Voltaje
h = figure(1); %set(h, 'Visible', 'off')
   hold on    
    plot(t_sim, V_sim, '--',...
     'LineWidth', 1.5, 'Color', colors(1,:), 'DisplayName', "Modelo din\'amico")
    plot(t_exp, V_exp, '-',...
     'LineWidth', 1.5, 'Color', colors(2,:), 'DisplayName', "Datos experimentales")
    xlim([0, t_sim(end)])
   ylim([22.9 24.2])
   grid on; box on;
   legend('Interpreter', 'Latex', 'Location', 'Best')
   xlabel('$t$ [s]','Interpreter','latex');
   ylabel({'$V$';'[V]'},'Interpreter','latex');
   Save_as_PDF(h, ['Figures/','resultado1C'],'horizontal', 2, 10);
   close

h = figure(2); %set(h, 'Visible', 'off')
   hold on    
    plot(t_exp,dif_V, '-',...
     'LineWidth', 0.8, 'Color', 'k')
    xlim([0, t_sim(end)])
   grid on; box on;
   xlabel('$t$ [s]','Interpreter','latex');
   ylabel({'$|V-V_{exp}|$';'[V]'},'Interpreter','latex');
   Save_as_PDF(h, ['Figures/','error1C'],'horizontal', 6, 10);
   close

clear all
   
   load('C2_data/2D_parameter_estimator2.mat')

C1_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(1, 1).Value;
C2_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(2, 1).Value; 
Rs1_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(3, 1).Value; 
Rs2_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(4, 1).Value; 
Rsc_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(5, 1).Value; 
Rsd_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(6, 1).Value;

for i=1:6
parameters(i,1) = SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(i,1).Value;
end

save('C2_data/C2_parameters.mat','parameters');

Data_sim = load('C2_data/2C_data.mat');

try
    load('Data\Bateria_Dinamica_Experimental.mat')
catch
    disp('No se ha creado el archivo de datos')
    return
end


t_sim=Data_sim.C_data.time;
V_sim = Data_sim.C_data.Data;
% Error_sim = abs(Data.V-V_sim);
V_exp =Data.V;
t_exp =Data.t;

%Pintar Error
[val, pos] = intersect(t_sim, t_exp);
V = V_sim(pos);
dif_V = abs(V_exp - V);

rmse_2C = RMSE(V_exp, V, length(V));

%%

colors = [0, 0.4470, 0.7410;
          [220,20,6]/255;
          [255,140,0]/255;
          [139,0,139]/255;
          [50,205,50]/255];

% Voltaje
h = figure(3); %set(h, 'Visible', 'off')
   hold on    
    plot(t_sim, V_sim, '--',...
     'LineWidth', 1.5, 'Color', colors(1,:), 'DisplayName', "Modelo din\'amico")
    plot(t_exp, V_exp, '-',...
     'LineWidth', 1.5, 'Color', colors(2,:), 'DisplayName', "Datos experimentales")
    xlim([0, t_sim(end)])
   ylim([22.9 24.2])
   grid on; box on;
   legend('Interpreter', 'Latex', 'Location', 'Best')
   xlabel('$t$ [s]','Interpreter','latex');
   ylabel({'$V$';'[V]'},'Interpreter','latex');
   Save_as_PDF(h, ['Figures/','resultado2C'],'horizontal', 2, 10);
   close

h = figure(4); %set(h, 'Visible', 'off')
   hold on    
    plot(t_exp,dif_V, '-',...
     'LineWidth', 0.8, 'Color', 'k')
    xlim([0, t_sim(end)])
   grid on; box on;
   xlabel('$t$ [s]','Interpreter','latex');
   ylabel({'$|V-V_{exp}|$';'[V]'},'Interpreter','latex');
   Save_as_PDF(h, ['Figures/','error2C'],'horizontal', 6, 10);
   close
%%

clear all
   
   load('C1_data/1C_data_02_session.mat')

C1_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(1, 1).Value; 
Rs1_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(2, 1).Value; 
Rsc_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(3, 1).Value; 
Rsd_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(4, 1).Value;

for i=1:4
parameters(i,1) = SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(i,1).Value;
end

save('C1_data/C1_02_parameters.mat','parameters');

Data_sim = load('C1_data/1C_data_02.mat');

try
    load('Data\Bateria_Dinamica_Experimental.mat')
catch
    disp('No se ha creado el archivo de datos')
    return
end


t_sim = Data_sim.data.time;
V_sim = Data_sim.data.Data;
% Error_sim = abs(Data.V-V_sim);
V_exp = Data.V;
t_exp = Data.t;

%Pintar Error
[val, pos] = intersect(t_sim, t_exp);
V = V_sim(pos);
dif_V = abs(V_exp - V);

rmse_1C_02 = RMSE(V_exp, V, length(V));

%%

colors = [0, 0.4470, 0.7410;
          [220,20,6]/255;
          [255,140,0]/255;
          [139,0,139]/255;
          [50,205,50]/255];

% Voltaje
h = figure(5); %set(h, 'Visible', 'off')
   hold on    
    plot(t_sim, V_sim, '--',...
     'LineWidth', 1.5, 'Color', colors(1,:), 'DisplayName', "Modelo din\'amico")
    plot(t_exp, V_exp, '-',...
     'LineWidth', 1.5, 'Color', colors(2,:), 'DisplayName', "Datos experimentales")
    xlim([0, t_sim(end)])
   ylim([22.9 24.2])
   grid on; box on;
   legend('Interpreter', 'Latex', 'Location', 'Best')
   xlabel('$t$ [s]','Interpreter','latex');
   ylabel({'$V$'; '[V]'},'Interpreter','latex');
   Save_as_PDF(h, ['Figures/','resultado1C_02'],'horizontal', 2, 10);
   close

h = figure(6); %set(h, 'Visible', 'off')
   hold on    
    plot(t_exp,dif_V, '-',...
     'LineWidth', 0.8, 'Color', 'k')
   xlim([0, t_sim(end)])
   grid on; box on;
   xlabel('$t$ [s]','Interpreter','latex');
   ylabel({'$|V-V_{exp}|$';'[V]'},'Interpreter','latex');
   Save_as_PDF(h, ['Figures/','error1C_02'],'horizontal', 7, 10);
   close
   
%%

clear all
   
   load('C1_data/1C_data_03_session.mat')

C1_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(1, 1).Value; 
Rs1_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(2, 1).Value; 
Rsc_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(3, 1).Value; 
Rsd_sim =SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(4, 1).Value;

for i=1:4
parameters(i,1) = SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters(i,1).Value;
end

save('C1_data/C1_03_parameters.mat','parameters');

Data_sim = load('C1_data/1C_data_03.mat');

try
    load('Data\Bateria_Dinamica_Experimental.mat')
catch
    disp('No se ha creado el archivo de datos')
    return
end


t_sim = Data_sim.data.time;
V_sim = Data_sim.data.Data;
% Error_sim = abs(Data.V-V_sim);
V_exp = Data.V;
t_exp = Data.t;

%Pintar Error
[val, pos] = intersect(t_sim, t_exp);
V = V_sim(pos);
dif_V = abs(V_exp - V);

rmse_1C_03 = RMSE(V_exp, V, length(V));

%%

colors = [0, 0.4470, 0.7410;
          [220,20,6]/255;
          [255,140,0]/255;
          [139,0,139]/255;
          [50,205,50]/255];

% Voltaje
h = figure(7); %set(h, 'Visible', 'off')
   hold on    
    plot(t_sim, V_sim, '--',...
     'LineWidth', 1.5, 'Color', colors(1,:), 'DisplayName', "Modelo din\'amico")
    plot(t_exp, V_exp, '-',...
     'LineWidth', 1.5, 'Color', colors(2,:), 'DisplayName', "Datos experimentales")
   xlim([0, t_sim(end)])
   ylim([22.9 24.2])
   grid on; box on;
   legend('Interpreter', 'Latex', 'Location', 'Best')
   xlabel('$t$ [s]','Interpreter','latex');
   ylabel({'$V$'; '[V]'},'Interpreter','latex');
   Save_as_PDF(h, ['Figures/','resultado1C_03'],'horizontal', 2, 10);
   close

h = figure(8); %set(h, 'Visible', 'off')
   hold on    
    plot(t_exp,dif_V, '-',...
     'LineWidth', 0.8, 'Color', 'k')
   xlim([0, t_sim(end)])
   grid on; box on;
   xlabel('$t$ [s]','Interpreter','latex');
   ylabel({'$|V-V_{exp}|$';'[V]'},'Interpreter','latex');
   Save_as_PDF(h, ['Figures/','error1C_03'],'horizontal', 7, 10);
   close
   
   
%% Fin 

clear all

Data_sim = load('C1_data/1C_data_03.mat');

try
    load('Estimacion_analitica.mat')
catch
    disp('No se ha creado el archivo de datos')
    return
end


try
    load('Data\Bateria_Dinamica_Experimental.mat')
catch
    disp('No se ha creado el archivo de datos')
    return
end


t_sim = Estimacion_analitica.time;
V_sim = Estimacion_analitica.Data;
% Error_sim = abs(Data.V-V_sim);
V_exp = Data.V;
t_exp = Data.t;

%Pintar Error
[val, pos] = intersect(t_sim, t_exp);
V = V_sim(pos);
dif_V = abs(V_exp - V);

rmse_1C_03 = RMSE(V_exp, V, length(V));

%%

colors = [0, 0.4470, 0.7410;
          [220,20,6]/255;
          [255,140,0]/255;
          [139,0,139]/255;
          [50,205,50]/255];

% Voltaje
h = figure(7); %set(h, 'Visible', 'off')
   hold on    
    plot(t_sim, V_sim, '--',...
     'LineWidth', 1.5, 'Color', colors(1,:), 'DisplayName', "Modelo din\'amico")
    plot(t_exp, V_exp, '-',...
     'LineWidth', 1.5, 'Color', colors(2,:), 'DisplayName', "Datos experimentales")
   xlim([0, t_sim(end)])
   ylim([22.9 24.2])
   grid on; box on;
   legend('Interpreter', 'Latex', 'Location', 'Best')
   xlabel('$t$ [s]','Interpreter','latex');
   ylabel({'$V$'; '[V]'},'Interpreter','latex');
   Save_as_PDF(h, ['Figures/','fin'],'horizontal', 2, 10);
   close

h = figure(8); %set(h, 'Visible', 'off')
   hold on    
    plot(t_exp,dif_V, '-',...
     'LineWidth', 0.8, 'Color', 'k')
   xlim([0, t_sim(end)])
   grid on; box on;
   xlabel('$t$ [s]','Interpreter','latex');
   ylabel({'$|V-V_{exp}|$';'[V]'},'Interpreter','latex');
   Save_as_PDF(h, ['Figures/','fin_error'],'horizontal', 7, 10);
   close