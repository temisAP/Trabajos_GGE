%% EXAMPLE PROGRAM
clc;
clear all;
close all;

%% APARTADO A: TRANSFERENCIA ORBITAL

% Datos
mu = 3.98e14;               % m^3/s^2
R_T = 6371e3;               % m

R_LEO = 200e3 + R_T;        % m
R_GEO = 42157e3;            % m


% Velocidades orbitales
v_LEO = sqrt(mu/R_LEO);     % m/s
v_GEO = sqrt(mu/R_GEO);     % m/s

% Transferencia de Hoffman

delta_v1 = sqrt( 2*mu/R_LEO * R_GEO/(R_LEO + R_GEO) ) - sqrt(mu/R_LEO);
va = sqrt( 2*mu/R_GEO * R_LEO/(R_LEO + R_GEO) );
delta_v2 = sqrt( va^2 + v_GEO^2 - 2*va*v_GEO*cos(deg2rad(30)) );
delta_v = delta_v1 + delta_v2;

% Tabla
varNames = {'$\Delta v_T$ [m/s]', '$\Delta v_1$ [m/s]', '$\Delta v_2$ [m/s]'};
apartado_a = table(delta_v, delta_v1, delta_v2);

% Redondear resultados al decimal fijado
for i = 1:size(apartado_a,2)
    apartado_a{1,i} = round(apartado_a{1,i},1);
end

apartado_a.Properties.VariableNames = varNames;

% Guardar tabla en la carpeta Resultados
table2latex(apartado_a, 'Resultados/Apartado_a',...
    'Incrementos de velocidad necesarios para la transferencia orbital',...
    'apartado_a')

%% APARTADO B: coste lanzamiento

Mcp = 100; Mso = 20; Mppo = 1;              % kg
d = 0.03; app = 20e-3; am = 4e-3;           % kg/W
el = 100*1.6e-19;                           % eV
eta_o = 0.75;
N_av = 6.022e23;                            % atomos/mol
qi = 1.6e-19;                               % C
eps_o = 8.85e-12;                           % C^2/Nm^2

delta_v = 1.1*apartado_a{1,1};

% Coste por kg
cpkg_a = 50000;                             % $/kg
cpkg_b = 9000;  
% $/kg
%Requisitos diseño
Isp = linspace(1000,3000,100).*9.81;        % m/s
It = 9e5;                                   % Ns                           


% Definicion proppulsantes
Ce = Propulsante('Cesio', 132.9);
Xe = Propulsante('Xenon', 131.3);
Hg = Propulsante('Mercurio', 200.6);

propulsantes = [Ce, Xe, Hg];


% Inventario de masas
Moa = Mcp + Mso + Mppo;
Coste_a = Moa*cpkg_a;


% Isp optimo en función de Mo
Mp = It./Isp;
Mo = Mp./(1 - exp(-delta_v./Isp));

% Guardar figura en carpeta Figuras
h = figure();
    plot(Isp, Mo, 'LineWidth', 1.5)
    box on
    grid on
    xlabel('$I_{sp}$ [m/s]','Interpreter','latex')
    ylabel({'$M_0$';'[kg]'},'Interpreter','latex')
    title('\textbf{MASA INICIAL vs } \boldmath{$I_{sp}$}',...
        'Interpreter','latex', 'FontSize', 14)
    Save_as_PDF(h, 'Figuras/Mo_Horizontal','horizontal')
    
h = figure();
    plot(Isp, Mo, 'LineWidth', 1.5)
    box on
    grid on
    xlabel('$I_{sp}$ [m/s]','Interpreter','latex')
    ylabel({'$M_0$';'[kg]'},'Interpreter','latex')
    title('\textbf{MASA INICIAL vs } \boldmath{$I_{sp}$}',...
        'Interpreter','latex', 'FontSize', 14)
    Save_as_PDF(h, 'Figuras/Mo_Vertical','vertical')
    
    
    
%% CLASS DEFINITION
classdef Propulsante < handle
    % Objeto bomba
    
    properties (Access = public)
        nombre
        M                  % Masa molecular [g/mol]
        m                  % masa atomica kg
    end
    
    methods
        
        function obj = Propulsante(nombre, M) % CONSTRUCTOR
            obj.nombre = nombre;
            obj.M = M;
            obj.m = M/(6.022e23)*1e-3;
        end
        
    end
end