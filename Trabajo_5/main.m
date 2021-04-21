clc
clear all
close all

try
    load('Data\Descarga-Carga.mat')
catch
    disp('No se ha creado el archivo de datos')
    return
end


%% PLOTEAR CURVAS CARGA Y DESCARGA

% Descarga

simpleplot(Descarga)

% Carga

simpleplot(Carga)

%% CÁLCULO DE NSERIE Y NPARALELO

% Datasheet

C_cell = 2.750 * 0.97; %A·h
V_cell = 4.2 ; %V

% Celdas en serie

V = Descarga(1).V(1);
N_Serie = round(V/V_cell);

% Celdas en paralelo

[C,k] = getC(Descarga);
N_paralelo = round(C/C_cell);


%% AJUSTE DE MODELOS

% Cálculo de Rc y Rd para usarlos como iterantes iniciales

Rc = getR(Carga);
Rd = getR(Descarga);

% Ajuste de modelos de DESCARGA: (lineal, exponencial, exponencial (ind) y exponencial-lineal

modelos_descarga = modelos(Descarga,Rd);

% Cálculo de descarga inicial

i = 3; %La curva que da mayor phi
Descarga_inicial = Descarga(i).phi1(end) + Descarga(i).phi2(end) .* modelos_descarga(i).modelo.Coefficients.Estimate(3);
for s=1:length(Carga)
    Carga(s).phi1 = Descarga_inicial - Carga(s).phi1;
end

% Ajuste de modelos de CARGA: (lineal, exponencial, exponencial (ind) y exponencial-lineal

modelos_carga = modelos(Carga,Rc);

%% SACAR VALORES BIEN TABLA

%%CARGA

%Lineal
modelos_carga(1).iter(:,1:4) = [modelos_carga(1).iter(:,3), modelos_carga(1).iter(:,1), modelos_carga(1).iter(:,2)*3600, modelos_carga(1).iter(:,4)];

%Exp
for i=2:5
    modelos_carga(i).iter(:,1:6) = [modelos_carga(i).iter(:,3), modelos_carga(i).iter(:,1),...
        modelos_carga(i).iter(:,2)*3600, modelos_carga(i).iter(:,4), modelos_carga(i).iter(:,5)*3600,modelos_carga(i).iter(:,6)];
end

%Exp_lineal
modelos_carga(6).iter(:,1:9) = [modelos_carga(6).iter(:,3), modelos_carga(6).iter(:,1),...
    modelos_carga(6).iter(:,2)*3600, modelos_carga(6).iter(:,4),...
    modelos_carga(6).iter(:,6),modelos_carga(6).iter(:,7)*3600,...
    modelos_carga(6).iter(:,5)*3600,modelos_carga(6).iter(:,8)*3600,modelos_carga(6).iter(:,9)];
%%DESCARGA

%Lineal
modelos_descarga(1).iter(:,1:4) = [modelos_descarga(1).iter(:,3), modelos_descarga(1).iter(:,1), modelos_descarga(1).iter(:,2)*3600, modelos_descarga(1).iter(:,4)];

%Exp

for i=2:5
    modelos_descarga(i).iter(:,1:6) = [modelos_descarga(i).iter(:,3), modelos_descarga(i).iter(:,1),...
        modelos_descarga(i).iter(:,2)*3600, modelos_descarga(i).iter(:,4), modelos_descarga(i).iter(:,5)*3600,modelos_descarga(i).iter(:,6)];
end

%Exp_lineal

modelos_descarga(6).iter(:,1:9) = [modelos_descarga(6).iter(:,3), modelos_descarga(6).iter(:,1),...
    modelos_descarga(6).iter(:,2)*3600, modelos_descarga(6).iter(:,4),...
    modelos_descarga(6).iter(:,6),modelos_descarga(6).iter(:,7)*3600,...
    modelos_descarga(6).iter(:,5)*3600,modelos_descarga(6).iter(:,8)*3600,modelos_descarga(6).iter(:,9)];

%% %%% FUNCIONES %%%  %%

%% Cálculo de todos los modelos para ciertos datos

% En función de los datos de entrada y con la primera estimación de
% resistencia ejecuta todos los ajustes
function md = modelos(data,R)

cod = inputname(1);                                                         % Para leer el nombre de la variable de entrada para poner los títulos

md = struct('nombre',[],'modelo',[],'iter',[]);                             % Los modelos se guardan sucesivamente en un struct

% Modelo lineal
m = 1;
md(m).nombre = 'Lineal';
[md(m).modelo, md(m).iter] = linearbatt(data,R);
plotmodel(md(m).modelo,data,md(m).nombre,cod);

% Modelo exponencial
m = 2;
md(m).nombre = 'Exponencial';
[md(m).modelo, md(m).iter] = expbatt(data,md(1).modelo, [-8e-9 3e-5]);
plotmodel(md(m).modelo,data,md(m).nombre,cod);

% Modelo exponencial ajustado individualmente (para cada intensidad)
beta = {[-5e-16 3e-5],[-1e-15 3e-5],[-1e-15 3e-5]};
for s = 1:length(data)
    m=m+1;
    md(m).nombre = ['Exponencial' num2str(s)];
    [md(m).modelo, md(m).iter] = expbatt(data,md(1).modelo,beta{s});
    md_arr{s} = md(m).modelo;
end
plotmodel(md_arr, data, 'Exponencial (individual)',cod);

% Modelo exponencial-lineal
m = m+1;
md(m).nombre = 'Exponencial-Lineal';
[md(m).modelo, md(m).iter]= explinealbatt(data,md(2).modelo);
plotmodel(md(m).modelo,data,md(m).nombre,cod);

md;

end


%% Modelos

% Modelo lineal
function [val, check] = linearbatt(data,R)

[MAT, V] = matrix(data);

i = 0;
for d = 1:length(data)
    weights(1+i:i+length(data(d).V)) = 1-length(data(d).V)/length(V);
    i = i+length(data(d).V);
end

myfunction = @(p,MAT) (p(1) + p(2)*(MAT(:,2)+p(3)*MAT(:,3)) ) + p(3)*MAT(:,1) ;

beta0 = [max(V) -1.5e-5 R];
check = [];

for i = 1:5
    val = fitnlm(MAT, V, myfunction, beta0,'Weights',weights);
    check = [check; beta0 , val.RMSE];
    beta0(:) = table2array(val.Coefficients(1:3,1));
end

end


% Modelo exponencial
function [val, check] = expbatt(data, model, beta)

[MAT, V] = matrix(data);

i = 0;
if (length(data)>1)
    for d = 1:length(data)
        weights(1+i:i+length(data(d).V)) = 1-length(data(d).V)/length(V);
        i = i+length(data(d).V);
    end
else
    weights = ones(length(data.V),1);
end

myfunction = @(p,MAT) (p(1) + p(2)*(MAT(:,2)+p(3)*MAT(:,3)) ) + ...
    p(4)*exp(p(5)*(MAT(:,2)+p(3)*MAT(:,3))) + p(3)*MAT(:,1) ;

p = model.Coefficients.Estimate;
beta0 = [p(1) p(2) p(3) beta(1) beta(2)];
check = [];

for i = 1:15
    opts = statset('Display','off','TolFun',1e-16);
    val = fitnlm(MAT, V, myfunction, beta0,'Weights',weights,'Options',opts);
    check = [check; beta0, val.RMSE];
    beta0(:) = table2array(val.Coefficients(1:5,1));
end

end

% Modelo exponencial-lineal
function [val, check]= explinealbatt(data, model)

[MAT, V] = matrix(data);

i = 0;
for d = 1:length(data)
    weights(1+i:i+length(data(d).V)) = 1-length(data(d).V)/length(V);
    i = i+length(data(d).V);
end

% Expresión según carga o descarga
if sign(MAT(end,2)) == -1      % i.e. descarga
    myfunction = @(p,MAT) (p(1) + p(2)*(MAT(:,2)+p(3)*MAT(:,3)))  + ...
        (p(4) + p(6)*MAT(:,1) + p(7).*(MAT(:,1).*MAT(:,1))).*exp((p(5) + p(8)*MAT(:,1)).*(MAT(:,2)+p(3)*MAT(:,3))) + p(3)*MAT(:,1) ;
    
elseif sign(MAT(end,2)) == 1   % i.e. carga  
    myfunction = @(p,MAT) (p(1) + p(2)*(MAT(:,2)+p(3)*MAT(:,3)))  + ...
        (p(4)).*exp((p(5) + p(8)*MAT(:,1)).*(MAT(:,2)+p(3)*MAT(:,3))) + p(3)*MAT(:,1) ;
else 
    disp('Error in sign of I')
end

p = model.Coefficients.Estimate;
beta0 = [p(1) p(2) p(3) p(4) p(5) -1e-5 -1e-5 -1.5e-16];
check = [];

for i = 1:5
    val = fitnlm(MAT, V, myfunction, beta0,'Weights',weights);
    if sign(MAT(end,2)) == -1      % % la ñapa
        val.Coefficients(6,1) = 0;
        val.Coefficients(7.1) = 0;
    end
    check = [check; beta0, val.RMSE];
    beta0(:) = table2array(val.Coefficients(1:8,1));
end

end


%% Otras funciones

function [C,k] = getC(data)

for i=1:length(data)
    I(i) = data(i).I(end);
    t(i) = data(i).t(end)/3600;
end
x = log(I);
y = log(t);

p = polyfit(x,y,1);
k = -p(1);

for i=1:length(data)

    C(i) = abs(I(i))^k *t(i);
end
C = mean(C);
end

% Para la primera estimación de resistencias
function  R = getR(data)

It = [1, 2, 3]*1e4;
for t = 1:3

    i = 0;
    for f = 1:length(data)

        i = i + 1;

        [val,idx] = min(abs(data(f).It - It(t)));
        V(i) = data(f).V(idx);
        I(i) = abs(data(f).I(idx));

    end

    R(t) = mean( (V(3) - V(2))/(I(2) - I(3)) + (V(2) - V(1))/(I(1) - I(2)) );
end

R = abs(mean(R));

end

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

%% Plots

% Para plotear las curvas del principio
function simpleplot(data)

tit = inputname(1);
closee = 'y';

color = [0, 0.4470, 0.7410;
    0.8500, 0.3250, 0.0980;
    0.4940, 0.1840, 0.5560];

h = figure()
hold on
for f = 1:length(data)

    p = polyfit(data(f).It,data(f).V,1);
    data(f).Lineal = polyval(p,data(f).It);

    % Plots
    plot(data(f).It,...
        data(f).V, 'LineWidth', 1.5,...
        'Color', color(f,:), 'DisplayName', data(f).Name)
%    plot(data(f).It,...
%         data(f).Lineal, '--', 'LineWidth', 1.5,...
%         'Color', color(f,:), 'DisplayName', data(f).Name)
end
grid on; box on;
ylim([17 25])
legend('Interpreter', 'Latex', 'Location', 'Best')
xlabel('\textit{I$\cdot$t} [A$\cdot$h]','Interpreter','latex');
ylabel({'$V$';'[V]'},'Interpreter','latex');
Save_as_PDF(h, ['Figures/', tit, '_','datos'],'horizontal');
if closee == 'y'
      close
end


end


%Para plotear los modelos que entren (si entran varios a la vez se combinan
%las gráficas, tienen que ser un cell)
function plotmodel(modelos,datas,titulo,titulo2)

color = [0, 0.4470, 0.7410;
    0.8500, 0.3250, 0.0980;
    0.4940, 0.1840, 0.5560];

% Selector de gráficas que van a extraerse (esto ahorra tiempo que no veas)
vIT = 'n';
vIT_error = 'y';
vPHI = 'y';
vPHI_error = 'y';
closee = 'y';

if vIT == 'y'

    h = figure();
    hold on

    for MM=1:length(modelos)

        if length(modelos)>1
            model = modelos{MM};
            data = datas(MM);
        else
            model = modelos;
            data = datas;
        end

        p = model.Coefficients.Estimate;
        for d=1:length(data)
            colornum = d+MM-1;                                  %Por si hubiera más gráficas que colores que haga el ciclo
            MAT = matrix(data(d));
            V = model.Formula.ModelFun(p,MAT);
            It = data(d).It/3600;
            plot(It, V,'--', ...
                'LineWidth', 1.5, 'Color', color(colornum,:), 'DisplayName', [data(d).Name, ' ', titulo])
            plot(It, data(d).V,...
                'LineWidth', 1.5, 'Color', color(colornum,:), 'DisplayName', [data(d).Name, ' Experimental'])
        end
    end

    grid on; box on;
    ylim([17 25])
    legend('Interpreter', 'Latex', 'Location', 'Best')
    xlabel('\textit{I$\cdot$t} [A$\cdot$h]','Interpreter','latex');
    ylabel({'$V$';'[V]'},'Interpreter','latex');
    Save_as_PDF(h, ['Figures/', titulo2, '_', titulo, '_It'],'horizontal');
    if closee == 'y'
        close
    end
end

if vIT_error == 'y'

    h = figure();
    hold on

    for MM=1:length(modelos)

        if length(modelos)>1
            model = modelos{MM};
            data = datas(MM);
        else
            model = modelos;
            data = datas;
        end

        p = model.Coefficients.Estimate;
        for d=1:length(data)
            colornum = d+MM-1;                                  %Por si hubiera más gráficas que colores que haga el ciclo
            MAT = matrix(data(d));
            V = model.Formula.ModelFun(p,MAT);
            It = data(d).It/3600;
            plot(It, abs(data(d).V-V),'-', ...
                'LineWidth', 1.5, 'Color', color(colornum,:), 'DisplayName', [data(d).Name, ' ', titulo])
       end
    end

    grid on; box on;
    legend('Interpreter', 'Latex', 'Location', 'Best')
    xlabel('\textit{I$\cdot$t} [A$\cdot$h]','Interpreter','latex');
    ylabel({'$|V-V_{exp}|$';'[V]'},'Interpreter','latex');
    Save_as_PDF(h, ['Figures/', titulo2, '_', titulo, '_It(Error)'],'horizontal', 5, 8);
    if closee == 'y'
        close
    end
end

if vPHI == 'y'

    h = figure();
    hold on
    for MM=1:length(modelos)

        if length(modelos)>1
            model = modelos{MM};
            data = datas(MM);
        else
            model = modelos;
            data = datas;
        end

        p = model.Coefficients.Estimate;

        for d=1:length(data)
            colornum = d+MM-1;                                 %Por si hubiera más gráficas que colores que haga el ciclo
            MAT = matrix(data(d));
            V = model.Formula.ModelFun(p,MAT);
            phi = (MAT(:,2) + MAT(:,3) * p(3))/3600;

            plot(phi, V, '--',...
                'LineWidth', 1.5, 'Color', color(colornum,:), 'DisplayName', [data(d).Name, ' ', titulo])
            plot(phi, data(d).V,...
                'LineWidth', 1.5, 'Color', color(colornum,:), 'DisplayName', [data(d).Name, ' Experimental'])
        end

    end

    grid on; box on;
    ylim([17 25])
    legend('Interpreter', 'Latex', 'Location', 'Best')
    xlabel('$\phi$ [W$\cdot$h]','Interpreter','latex');
    ylabel({'$V$';'[V]'},'Interpreter','latex');
    Save_as_PDF(h, ['Figures/', titulo2, '_', titulo, '_phi'],'horizontal');
    if closee == 'y'
        close
    end

end

if vPHI_error == 'y'

    h = figure();
    hold on
    for MM=1:length(modelos)

        if length(modelos)>1
            model = modelos{MM};
            data = datas(MM);
        else
            model = modelos;
            data = datas;
        end

        p = model.Coefficients.Estimate;

        for d=1:length(data)
            colornum = d+MM-1;                                 %Por si hubiera más gráficas que colores que haga el ciclo
            MAT = matrix(data(d));
            V = model.Formula.ModelFun(p,MAT);
            phi = (MAT(:,2) + MAT(:,3) * p(3))/3600;

            plot(phi,abs(data(d).V - V), '-',...
                'LineWidth', 1.5, 'Color', color(colornum,:), 'DisplayName', [data(d).Name, ' ', titulo])
        end
    end

    grid on; box on;
    legend('Interpreter', 'Latex', 'Location', 'Best')
    xlabel('$\phi$ [W$\cdot$h]','Interpreter','latex');
    ylabel({'$|V-V_{exp}|$';'[V]'},'Interpreter','latex');
    Save_as_PDF(h, ['Figures/', titulo2, '_', titulo, '_phi(Error)'],'horizontal', 5, 8);
    if closee == 'y'
        close
    end

end

%   h = figure();
%     hold on
%     for d=1:length(data)
%       MAT = matrix(data(d));
%       V = model.Formula.ModelFun(p,MAT);
%       phi = MAT(:,2) + MAT(:,3) * p(3);
%
%       plot(data(d).t, phi, '--',...
%         'LineWidth', 1.5, 'Color', color(d,:), 'DisplayName', data(d).Name)
%     end
%     grid on; box on;
%     legend('Interpreter', 'Latex', 'Location', 'Best')
%     title(titulo)

end
