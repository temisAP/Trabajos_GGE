clc;
clear all;
close all;

%% Datos

%% Primera parte

Tref = 20 + 273.15; %K
Gref = 1367;        %W/m^2
load('Datos_experimentales/Cells_Data.mat');
% e-2 va como un tiro, SI O NO, SI O NO? ESTAMOS? VALE? ESTAMOS O NO?
alpha_Voc = -6e-3;
alpha_Isc = 0.32e-3;
alpha_Vmp = -6.1e-3;
alpha_Imp = 0.28e-3;

% KyH
KyH = struct();
KyH.name = 'KyH';
KyH.parameters = [Cells.Isc Cells.Imp Cells.Vmp Cells.Voc];
KyH.Tref = Tref;
KyH.Gref = Gref;
KyH.a = Cells.a;

%1d2r
m_1d2r = struct();
m_1d2r.name = '1d2r';
m_1d2r.parameters = [Cells.Isc Cells.Imp Cells.Vmp Cells.Voc];
m_1d2r.Tref = Tref;
m_1d2r.a = Cells.a;
m_1d2r.Gref = Gref;

%% Segunda parte 

%Crear panel
SP = solar_panel();
SP.N_serie = Cells.N_serie;
SP.N_paralelo = Cells.N_paralelo;
SP.Modelo = KyH;% m_1d2r;
SP.Kelly_cosine_Limit = 75;
SP.alpha = [alpha_Isc, alpha_Imp, alpha_Vmp, alpha_Voc];

%Crear entorno
Env = entorno();
Env.T_max = 80+273.15;      %K
Env.T_min = -20+273.15;      %K
Env.Go = Gref;            %W/m2

% Crear satélite 
R = [35, 37.5, 42];
t = linspace(0,120.83,1e3+1);

for r = 1:3
    Sat = Satelite(SP,Env,R(r));
    Sat.w = 0.052;
    Sat.desfase_P = -pi/2;
    Sat.desfase_T = Sat.w*15;

    % Extraer la intensidad a lo largo del tiempo t
    I(:,r) = Sat.get_current(t);
end

figure()
hold on
    plot(t,I/max(I));
    plot(t,Env.T/max(Env.T));
    plot(t,Env.G/max(Env.G));
    xlabel('t');
    legend('I','T','G');
    grid on, box on

%% Intensidad a lo largo del tiempo

lines = {'-','--',':'};
res = {'$35$', '$37,5$', '$42$'};
h = figure();
    hold on
    for r = 1:3
        plot(t, I(:,r), lines{r}, 'Color', 'k', 'LineWidth', 1.5, 'DisplayName', ...
            ['$R =$ ' res{r} ' $\Omega$'])
    end
    box on; grid on;
    legend('Interpreter', 'Latex')
    axis([0, max(t), 0, max(max(I))])
    xlabel('$t$ [s]', 'Interpreter', 'Latex')
    ylabel({'$I$'; '[A]'}, 'Interpreter', 'Latex')
    Save_as_PDF(h, 'Figuras/Intensidad_Resistencias_3', 'horizontal');

%% Potencia a lo largo del tiempo
    
lines = {'-','--',':'};
res = {'$35$', '$37,5$', '$42$'};
h = figure();
    hold on
    for r = 1:3
        P(:,r) = I(:,r).^2 .* R(r);
        P(isnan(P)) = 0;
        plot(t,P(:,r), lines{r}, 'Color', 'k', 'LineWidth', 1.5, 'DisplayName', ...
            ['$R =$ ' res{r} ' $\Omega$'])
    end
    box on; grid on;
    legend('Interpreter', 'Latex')
    axis([0, max(t), 0, max(max(I.^2 .* R))])
    xlabel('$t$ [s]', 'Interpreter', 'Latex')
    ylabel({'$P$'; '[W]'}, 'Interpreter', 'Latex')
    Save_as_PDF(h, 'Figuras/Potencia_Resistencias_3', 'horizontal');

Pm = mean(P,1);
    
%% Efecto de la temperatura    
    
T = flip([Env.T_min Tref Env.T_max]');
G = [Gref Gref Gref]';
V = linspace(0,20,100);

clear I 
for v = 1:length(V)
    val = SP.current(V(v),T,G,'V');
    I(:,v) = val(:);
end

lgds = flip({"$I(T_{\mathrm{min}})$","$I(T_{ref})$","$I(T_{\mathrm{max}})$"});
mrks = {'-','--',':'};
colr = {'#000000','#A9A9A9','#D3D3D3'};

h = figure();
hold on
    for i = 1:length(T)
        plot(V,I(i,:),...
            mrks{i}, 'LineWidth', 1.5, 'Color','k',...
            'DisplayName', [lgds{i}]);
    end
    ylim([0 0.6]);
    xlim([0 20]);
    legend('Interpreter', 'Latex','Location','Southwest');
    grid on, box on
    xlabel('$V$ [V]','Interpreter','latex');
    ylabel({'$I$';'[A]'},'Interpreter','latex');
    Save_as_PDF(h, ['Figuras/Temperaturas'],'horizontal');
   
    
 
%% Efecto de la irradiancia       
    
T = [Tref Tref Tref]';
G = flip([Gref*0.1 Gref*0.5 Gref]');

clear I 
for v = 1:length(V)
    val = SP.current(V(v),T,G,'V');
    I(:,v) = val(:);
end

lgds = flip({"$I(0,1 \: G_{ref})$","$I(0,5 \: G_{ref})$","$I(G_{ref})$"});
mrks = {'-','--',':'};
colr = {'#000000','#A9A9A9','#D3D3D3'};

h = figure();
hold on
    for i = 1:length(T)
        plot(V,I(i,:),...
            mrks{i}, 'LineWidth', 1.5, 'Color', 'k',...
            'DisplayName', [lgds{i}]);
    end
    ylim([0 0.6]);
    xlim([0 20]);
    legend('Interpreter', 'Latex','Location','west');
    grid on, box on
    xlabel('$V$ [V]','Interpreter','latex');
    ylabel({'$I$';'[A]'},'Interpreter','latex');
    Save_as_PDF(h, ['Figuras/Irradiancias'],'horizontal');
    
%% Cargas    
    
T = [Env.T_min Env.T_max]';
G = [Gref 0.5*Gref]';
V = linspace(0,20,100);

clear I 
for v = 1:length(V)
    val = SP.current(V(v),T,G,'V');
    I(:,v) = val(:);
end

% Intensidad para cada resistencia 
I_r = V'*ones(size(R))./R;

lgds = {"$I(T_{\mathrm{min}},G_{ref})$","$I(T_{\mathrm{max}},0,5\: G_{ref})$","$R = 35 \Omega$","$R = 37,5 \Omega$","$R = 42 \Omega$"};
mrks = {'-','--','-.'};
colr = {'#000000','#A9A9A9','#D3D3D3'};

h = figure();
hold on
    for i = 1:length(T)
        plot(V,I(i,:),...
            mrks{i}, 'LineWidth', 2, 'Color', '#A9A9A9',...
            'DisplayName', [lgds{i}]);
    end
    for j =1:length(R)
            plot(V,I_r(:,j),...
            mrks{j}, 'LineWidth', 1, 'Color', 'k',...
            'DisplayName', [lgds{i+j}]);
    end
    ylim([0 0.6]);
    xlim([0 20]);
    legend('Interpreter', 'Latex','Location','Best');
    grid on, box on
    xlabel('$V$ [V]','Interpreter','latex');
    ylabel({'$I$';'[A]'},'Interpreter','latex');
    Save_as_PDF(h, ['Figuras/Cargas'],'horizontal');
   