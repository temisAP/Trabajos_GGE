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

Data_sim = load('C1_estatico.mat');

try
    load('Data\Bateria_Dinamica_Experimental.mat')
catch
    disp('No se ha creado el archivo de datos')
    return
end


t_sim=Data_sim.data.time;
V_sim = Data_sim.data.Data;
% Error_sim = abs(Data.V-V_sim);
V_exp =Data.V;
t_exp =Data.t;

%Pintar Error
[val, pos] = intersect(t_sim, t_exp);
V = V_sim(pos);
dif_V = abs(V_exp - V);

%%
% Voltaje
h = figure(1); %set(h, 'Visible', 'off')
   hold on    
    plot(t_sim, V_sim, '--',...
     'LineWidth', 1.5, 'Color', 'k', 'DisplayName', "Modelo din\'amico")
    plot(t_exp, V_exp, '-',...
     'LineWidth', 1.5, 'Color', 'k', 'DisplayName', "Datos Experimentales")
   grid on; box on;
   legend('Interpreter', 'Latex', 'Location', 'Best')
   xlabel('$t$ [s]','Interpreter','latex');
   ylabel({'$|V|$';'[V]'},'Interpreter','latex');
   %Save_as_PDF(h, ['Figures/','Extract_data'],'horizontal', 0, 0);
   %close

h = figure(2); %set(h, 'Visible', 'off')
   hold on    
    plot(dif_V, '-',...
     'LineWidth', 0.8, 'Color', 'k', 'DisplayName', "Modelo din\'amico")
   grid on; box on;
   legend('Interpreter', 'Latex', 'Location', 'Best')
   xlabel('$t$ [s]','Interpreter','latex');
   ylabel({'$|V|$';'[V]'},'Interpreter','latex');
   %Save_as_PDF(h, ['Figures/','Extract_data'],'horizontal', 0, 0);
   %close

   