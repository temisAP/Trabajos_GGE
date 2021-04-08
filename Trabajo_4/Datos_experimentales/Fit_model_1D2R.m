%%%%%%%%%%%%%%%%%%%%%%%%% 1D2R %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
clc

load('Cells_Data.mat');
V_mess = Cells.V_mess;
I_mess = Cells.I_mess;

%% PUNTOS EXPERIMENTALES

% Datos
Vmp = Cells.Vmp;
Imp = Cells.Imp;
Isc = Cells.Isc;
Voc = Cells.Voc;

a = 1.5; % inventada
n = 6; % inventada

kB = 1.380649e-23; %J K-1
qe = 1.6e-19; %C
T = 273.15 + 20; %K 
Vt = n*kB*T/qe;  % n número de células

% Parameter calculations

[Ipv,I0,Rs,Rsh] = param_1D_2R_Lap(Isc,Voc,Imp,Vmp,a, Vt);
umin = [Ipv,I0,Rs,Rsh,a];

% For ploting results

I_modelo = zeros(size(V_mess,2),1)';
for i=1:size(V_mess,2)
    I_modelo(i) = Panel_Current(umin,V_mess(i), Vt);
end

h_ = figure();
hold on
plot(V_mess, I_modelo, '-', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
    ["1D2R anal\'itico con puntos experimentales"])
plot(V_mess, I_mess, '--', 'LineWidth', 2, 'Color', 'k','DisplayName', ...
    ["Puntos experimentales"])
box on; grid on
legend('Interpreter', 'Latex', 'location', 'NorthWest')
xlabel('$V$ [V]','Interpreter','latex');
ylabel({'$I$';'[A]'},'Interpreter','latex');
%                Save_as_PDF(h_, ['Figuras/1_An_dif_', sheet{s}],'horizontal', 7.5, 10);
