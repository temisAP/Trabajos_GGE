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

%CARGA

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
    0*modelos_descarga(6).iter(:,6),0*modelos_descarga(6).iter(:,7),...
    modelos_descarga(6).iter(:,5)*3600,modelos_descarga(6).iter(:,8)*3600,modelos_descarga(6).iter(:,9)];

%Eq.24 [E_0,E_1,E_2,X,X,E_30,E_31,Rd0,Rd1, RMSE]

modelos_descarga(7).iter(:,1:10) = [modelos_descarga(7).iter(:,1),...
    modelos_descarga(7).iter(:,2)*3600, modelos_descarga(7).iter(:,4),...
    0*modelos_descarga(7).iter(:,6),0*modelos_descarga(7).iter(:,7),...
    modelos_descarga(7).iter(:,5)*3600,modelos_descarga(7).iter(:,8)*3600,modelos_descarga(7).iter(:,3),...
    modelos_descarga(7).iter(:,9),modelos_descarga(7).iter(:,10)];

%Eq.25 [E_0,E_1,X,E_20,E_21,E_22,E_30,E_31,Rd0,Rd1,RMSE]

modelos_descarga(8).iter(:,1:11) = [modelos_descarga(8).iter(:,1),...
    modelos_descarga(8).iter(:,2)*3600,0*modelos_descarga(8).iter(:,10)*3600, modelos_descarga(8).iter(:,4),...
    modelos_descarga(8).iter(:,6),modelos_descarga(8).iter(:,7),...
    modelos_descarga(8).iter(:,5)*3600,modelos_descarga(8).iter(:,8)*3600,modelos_descarga(8).iter(:,3),...
    modelos_descarga(8).iter(:,9),modelos_descarga(8).iter(:,11)];


%Eq.26 [E_0,E_10,E_11,E_12,E_20,E_21,E_22,E_30,E_31,Rd0,Rd1,RMSE]

modelos_descarga(9).iter(:,1:12) = [modelos_descarga(9).iter(:,1),...
    modelos_descarga(9).iter(:,2)*3600,modelos_descarga(9).iter(:,10)*3600,modelos_descarga(9).iter(:,11)*3600,...
    modelos_descarga(9).iter(:,4),modelos_descarga(9).iter(:,6),modelos_descarga(9).iter(:,7),...
    modelos_descarga(9).iter(:,5)*3600,modelos_descarga(9).iter(:,8)*3600,modelos_descarga(9).iter(:,3),...
    modelos_descarga(9).iter(:,9),modelos_descarga(9).iter(:,12)];


%Eq.27 [E_0,E_10,E_11,E_12,E_20,E_21,E_22,E_30,E_31,E_41,E_42,Rd0,Rd1,RMSE]

modelos_descarga(10).iter(:,1:14) = [modelos_descarga(10).iter(:,1),...
    modelos_descarga(10).iter(:,2)*3600,modelos_descarga(10).iter(:,10)*3600,modelos_descarga(10).iter(:,11)*3600,...
    modelos_descarga(10).iter(:,4),modelos_descarga(10).iter(:,6),modelos_descarga(10).iter(:,7),...
    modelos_descarga(10).iter(:,5)*3600,modelos_descarga(10).iter(:,8)*3600,...
    modelos_descarga(10).iter(:,12),modelos_descarga(10).iter(:,13),modelos_descarga(10).iter(:,3),...
    modelos_descarga(10).iter(:,9),modelos_descarga(10).iter(:,14)];


%Eq.28 [E_0,E_10,E_11,E_12,E_20,E_21,E_22,E_30,E_31,E_41,E_42,Rd0,Rd1,RMSE]

modelos_descarga(11).iter(:,1:14) = [modelos_descarga(11).iter(:,1),...
    modelos_descarga(11).iter(:,2)*3600,modelos_descarga(11).iter(:,10)*3600,modelos_descarga(11).iter(:,11)*3600,...
    modelos_descarga(11).iter(:,4),modelos_descarga(11).iter(:,6),modelos_descarga(11).iter(:,7),...
    modelos_descarga(11).iter(:,5)*3600,modelos_descarga(11).iter(:,8)*3600,modelos_descarga(10).iter(:,12),...
    modelos_descarga(11).iter(:,13),modelos_descarga(11).iter(:,3),modelos_descarga(11).iter(:,9),modelos_descarga(11).iter(:,14)];


%Eq.cos1 [E_0,E_10,E_11,E_12,E_20,E_21,E_22,E_30,E_31,E_41,E_42,Rd0,Rd1,...,RMSE]

modelos_descarga(12).iter(:,1:17) = [modelos_descarga(12).iter(:,1),...
    modelos_descarga(12).iter(:,2)*3600,modelos_descarga(12).iter(:,10)*3600,modelos_descarga(12).iter(:,11)*3600,...
    modelos_descarga(12).iter(:,4),modelos_descarga(12).iter(:,6),modelos_descarga(12).iter(:,7),...
    modelos_descarga(12).iter(:,5)*3600,modelos_descarga(12).iter(:,8)*3600,modelos_descarga(10).iter(:,12),...
    modelos_descarga(12).iter(:,13),modelos_descarga(12).iter(:,3),modelos_descarga(12).iter(:,9), modelos_descarga(12).iter(:,14),modelos_descarga(12).iter(:,15)*3600,modelos_descarga(12).iter(:,16)*3600,...
    modelos_descarga(12).iter(:,17)];

%Eq.cos2 [E_0,E_10,E_11,E_12,E_20,E_21,E_22,E_30,E_31,E_41,E_42,Rd0,Rd1,..., RMSE]

modelos_descarga(13).iter(:,1:21) = [modelos_descarga(13).iter(:,1),...
    modelos_descarga(13).iter(:,2)*3600,modelos_descarga(13).iter(:,10)*3600,modelos_descarga(13).iter(:,11)*3600,...
    modelos_descarga(13).iter(:,4),modelos_descarga(13).iter(:,6),modelos_descarga(13).iter(:,7),...
    modelos_descarga(13).iter(:,5)*3600,modelos_descarga(13).iter(:,8)*3600,modelos_descarga(10).iter(:,12),...
    modelos_descarga(13).iter(:,13),modelos_descarga(13).iter(:,3),modelos_descarga(13).iter(:,9),...
    modelos_descarga(13).iter(:,14),modelos_descarga(13).iter(:,15)*3600,modelos_descarga(13).iter(:,16)*3600,...
    modelos_descarga(13).iter(:,17),modelos_descarga(13).iter(:,18)*3600,...
    modelos_descarga(13).iter(:,19),modelos_descarga(13).iter(:,20)*3600,...
    modelos_descarga(13).iter(:,21)];

%% Exportar modelos

save('Modelos.mat','modelos_descarga','modelos_carga');


%% Pintar RMSE

n_cl = length( modelos_carga(1).iter(:,4));
n_ce = length( modelos_descarga(2).iter(:,6));

n_de2 = length( modelos_descarga(3).iter(:,6));
RMSE_exp_d = [modelos_descarga(3).iter(n_de2,6),modelos_descarga(4).iter(n_de2,6),modelos_descarga(5).iter(n_de2,6)];

n_cel = length( modelos_carga(6).iter(:,4));

RMSE_carga = [modelos_carga(1).iter(n_cl,4),modelos_carga(2).iter(n_ce(1),6),modelos_carga(6).iter(n_cel,9)];

n_dl = length( modelos_descarga(1).iter(:,4));
n_de = length( modelos_descarga(2).iter(:,6));
n_del = length( modelos_descarga(6).iter(:,9));
n_de7 = length( modelos_descarga(7).iter(:,10));
n_de8 = length( modelos_descarga(8).iter(:,11));
n_de9 = length( modelos_descarga(9).iter(:,12));
n_de10 = length( modelos_descarga(10).iter(:,14));
n_de11 = length( modelos_descarga(11).iter(:,14));
n_de12 = length( modelos_descarga(12).iter(:,17));
n_de13 = length( modelos_descarga(13).iter(:,21));

RMSE_descarga = [modelos_descarga(1).iter(n_dl,4),modelos_descarga(2).iter(n_de,6),modelos_descarga(6).iter(n_del,9),...
                 modelos_descarga(7).iter(n_de7,10), modelos_descarga(8).iter(n_de8,11), modelos_descarga(9).iter(n_de9,12)...
                 modelos_descarga(10).iter(n_de10,14), modelos_descarga(11).iter(n_de11,14)];
             
%RMSE_descarga2 = [modelos_descarga(1).iter(n_dl,4),modelos_descarga(2).iter(n_de,6),modelos_descarga(6).iter(n_del,9)];

%RMSE = [ RMSE_descarga2; RMSE_carga];

f = figure(13);
b = bar(RMSE_descarga');
b.FaceColor = 'flat';
cmap = colormap(jet);

for k = 1:size(RMSE_descarga,2)
         b.CData(k,:) = cmap(27*k,:);
end
set(gca,'xticklabel',{'(17)','(20)','(21)','(22)','(23)','(24)','(25)','(26)'})
ylabel({'RMSE';'[V]'},'Interpreter','latex');

Save_as_PDF(f, ['Figures/barplot_presentacion_peque'],'horizontal', 9,7.5);


% f = figure(12);
%     h_ = bar(RMSE,'FaceColor','flat');
%     cmap = colormap(gray);
%     
%     for k = 1:size(RMSE,2)
%         h_(k).FaceColor = cmap(80*k,:);
%     end
%     tipo = {'Descarga','Carga'};
%     set(gca,'xticklabel',tipo,'TickLabelInterpreter','latex');
%     leyenda = {modelos_descarga(1).nombre, modelos_descarga(2).nombre, modelos_descarga(6).nombre};
%     legend(leyenda, 'Interpreter', 'Latex', 'location', 'NorthEast');  
%     ylabel({'RMSE';'[V]'},'Interpreter','latex');
%     %Save_as_PDF(f, ['Figures/barplot_CyD'],'horizontal',-21.5,5);
%     
% f = figure(13);
%     h_ = bar(RMSE_exp_d,'FaceColor','flat');
%         
%     cmap = colormap(jet);
%     tipo2 = {'Descarga 5 A','Descarga 2,5 A', 'Descarga 1,5 A'};
%     for k = 1:size(RMSE_exp_d,1)
%         h_(k).FaceColor = cmap(80*k,:);
%     end
%     set(gca,'xticklabel',tipo2,'TickLabelInterpreter','latex');
%     ylabel({'RMSE';'[V]'},'Interpreter','latex');
%     %Save_as_PDF(f, ['Figures/barplot_D_individuales'],'horizontal', 9,5);

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
[MAT, V] = matrix(data);
[md(m).modelo, md(m).iter] = linearbatt(data,[max(V) -1.5e-5 R]);
%plotmodel(md(m).modelo,data,md(m).nombre,cod);

% Modelo exponencial
m = 2;
md(m).nombre = 'Exponencial';
p = md(1).modelo.Coefficients.Estimate;
beta0 = [p(1) p(2) p(3) -1e-10 2.6e-5];
[md(m).modelo, md(m).iter] = expbatt(data, beta0);
%plotmodel(md(m).modelo,data,md(m).nombre,cod);

% Modelo exponencial ajustado individualmente (para cada intensidad)
p = md(1).modelo.Coefficients.Estimate;
% beta = {[-5e-16 2.7e-5],[-1e-15 2.6e-5],[-1e-15 2.6e-5]};
% beta = {[-5e-14 2.7e-5],[-1e-13 2.6e-5],[-1e-13 2.6e-5]};
beta = {[-5e-12 2.7e-5],[-1e-10 2.6e-5],[-1e-10 2.6e-5]};
for s = 1:length(data)
    m=m+1;
    md(m).nombre = ['Exponencial' num2str(s)];
    [md(m).modelo, md(m).iter] = expbatt(data,[p(1) p(2) p(3) beta{s}]);
    md_arr{s} = md(m).modelo;
end
%plotmodel(md_arr, data, 'Exponencial (individual)',cod);

% Modelo exponencial-lineal
m = 6;
md(m).nombre = 'Exponencial-Lineal';
p = md(2).modelo.Coefficients.Estimate;
beta0 = [p(1) p(2) p(3) p(4) p(5) -1e-5 -1e-5 -1.5e-16];
[md(m).modelo, md(m).iter]= explinealbatt(data,beta0);
%plotmodel(md(m).modelo,data,md(m).nombre,cod);

if strcmp(cod,'Descarga')

% Modelo 24

m = 7;
md(m).nombre = 'Modelo 22';
p = md(m-1).modelo.Coefficients.Estimate;
beta0 = [p(1) p(2) p(3) p(4) p(5) p(6) p(7) p(8) -p(3)/10 ];
[md(m).modelo, md(m).iter]= modelosbateria(data,beta0,'24');
%plotmodel(md(m).modelo,data,md(m).nombre,cod);

% Modelo 25

m = 8;
md(m).nombre = 'Modelo 23';
p = md(m-1).modelo.Coefficients.Estimate;
beta0 = [p(1) p(2) p(3) p(4) p(5) p(6) p(7) p(8) p(9) -1e-14 ];
[md(m).modelo, md(m).iter]= modelosbateria(data,beta0,'25');
%plotmodel(md(m).modelo,data,md(m).nombre,cod);

% Modelo 26

m = 9;
md(m).nombre = 'Modelo 24';
p = md(m-1).modelo.Coefficients.Estimate;
beta0 = [p(1) p(2) p(3) p(4) p(5) p(6) p(7) p(8) p(9) p(10) -1e-13];
[md(m).modelo, md(m).iter]= modelosbateria(data,beta0,'26');
%plotmodel(md(m).modelo,data,md(m).nombre,cod);


% Modelo 27

m = 10;
md(m).nombre = 'Modelo 25';
p = md(m-1).modelo.Coefficients.Estimate;
beta0 = [p(1) p(2) p(3) p(4) p(5) p(6) p(7) p(8) p(9) p(10) p(11) 1e-5 1e-5];
[md(m).modelo, md(m).iter]= modelosbateria(data,beta0,'27');
%plotmodel(md(m).modelo,data,md(m).nombre,cod);

% Modelo 28

m = 11;
md(m).nombre = 'Modelo 26';
p = md(m-1).modelo.Coefficients.Estimate;
beta0 = [p(1) p(2) p(3) p(4) p(5) p(6) p(7) p(8) p(9) p(10) p(11) 1e-5 1e-5];
[md(m).modelo, md(m).iter]= modelosbateria(data,beta0,'28');
%plotmodel(md(m).modelo,data,md(m).nombre,cod);

% %% Cosenos %% %

% Modelo coseno 1

m = 12;
md(m).nombre = 'coseno1';
p = md(11).modelo.Coefficients.Estimate;
A1 = 2e-1;
A2 = 1e-8;
omega =  6.28870429062523e-06; %pi/2/(50*3600);
beta0 = [p(1) p(2) p(3) p(4) p(5) p(6) p(7) p(8) p(9) p(10) p(11) p(12) p(13) A1 A2 omega];
[md(m).modelo, md(m).iter]= modelosbateria(data,beta0,'coseno1');
%plotmodel(md(m).modelo,data,md(m).nombre,cod);

% Modelo coseno 2

m = 13;
md(m).nombre = 'coseno2';
p = md(12).modelo.Coefficients.Estimate;
beta0 = [p(1) p(2) p(3) p(4) p(5) p(6) p(7) p(8) p(9) p(10) p(11) p(12) p(13) p(14) p(15) p(16) -0.01 1.05897691988906e-05 -0.01 3.21100926265863e-08];
[md(m).modelo, md(m).iter]= modelosbateria(data,beta0,'coseno2');
%plotmodel(md(m).modelo,data,md(m).nombre,cod);

end

end

function md = mas_modelos(data,md,beta)

cod = inputname(1);                                                         % Para leer el nombre de la variable de entrada para poner los títulos

m = length(md);

m = m+1;
md(m).nombre = 'coseno2';
p = md(19).modelo.Coefficients.Estimate;
beta0 = [p(1) p(2) p(3) p(4) p(5) p(6) p(7) p(8) p(9) p(10) p(11) p(12) p(13) p(14) p(15) p(16) beta];
[md(m).modelo, md(m).iter]= modelosbateria(data,beta0,'coseno2');
plotmodel(md(m).modelo,data,md(m).nombre,cod);

end

function md = custom_model(data,md)

cod = inputname(1);                                                         % Para leer el nombre de la variable de entrada para poner los títulos

m = length(md);

% Modelo cosh

m = m+1;
md(m).nombre = 'cosh';
p = md(m-1).modelo.Coefficients.Estimate;
beta0 = [p(1) p(2) p(3) p(4) p(5) p(6) p(7) p(8) p(9) p(10) p(11) p(12) p(13) 1e-5 1e-5];
[md(m).modelo, md(m).iter]= modelosbateria(data,beta0,'cosh');
plotmodel(md(m).modelo,data,md(m).nombre,cod);

end

%% Modelos

% Modelo lineal
function [val, check] = linearbatt(data,beta0)

[MAT, V] = matrix(data);

i = 0;
for d = 1:length(data)
    weights(1+i:i+length(data(d).V)) = 1-length(data(d).V)/length(V);
    i = i+length(data(d).V);
end

myfunction = @(p,MAT) (p(1) + p(2)*(MAT(:,2)+p(3)*MAT(:,3)) ) + p(3)*MAT(:,1) ;

check = [];

for i = 1:5
    val = fitnlm(MAT, V, myfunction, beta0,'Weights',weights);
    check = [check; beta0 , val.RMSE];
    beta0(:) = table2array(val.Coefficients(1:3,1));
end

end

% Modelo exponencial
function [val, check] = expbatt(data, beta0)

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


check = [];

for i = 1:15
    opts = statset('Display','off','TolFun',1e-16);
    val = fitnlm(MAT, V, myfunction, beta0,'Weights',weights,'Options',opts);
    check = [check; beta0, val.RMSE];
    beta0(:) = table2array(val.Coefficients(1:5,1));
end

end

% Modelo exponencial-lineal
function [val, check]= explinealbatt(data, beta0)

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

function [val, check]= modelosbateria(data,beta0,type)

[MAT, V] = matrix(data);

i = 0;
for d = 1:length(data)
    weights(1+i:i+length(data(d).V)) = 1-length(data(d).V)/length(V);
    i = i+length(data(d).V);
end

switch type
    case '24'
        myfunction = @(p,MAT) (p(1) +...
            (p(2)).*(MAT(:,2)+p(3).*MAT(:,3)))+ ...
            (p(4) + 0*p(6)*MAT(:,1) + 0*p(7).*(MAT(:,1).*MAT(:,1))).*...
            exp((p(5) + p(8).*MAT(:,1)).*(MAT(:,2)+p(3).*MAT(:,3))) +...
            (p(3)+p(9).*abs(MAT(:,1))).*MAT(:,1);
    
    case '25'
        myfunction = @(p,MAT) (p(1) +...
            (p(2)+0*p(10).*MAT(:,1)).*(MAT(:,2)+p(3).*MAT(:,3)))+ ...
            (p(4) + p(6).*MAT(:,1) + p(7).*(MAT(:,1).*MAT(:,1))).*...
            exp((p(5) + p(8).*MAT(:,1)).*(MAT(:,2)+p(3).*MAT(:,3))) +...
            (p(3)+p(9).*abs(MAT(:,1))).*MAT(:,1);
      
    case '26'
        myfunction = @(p,MAT) (p(1) +...
            (p(2)+p(10).*MAT(:,1)+p(11).*MAT(:,1).*MAT(:,1)).*(MAT(:,2)+p(3).*MAT(:,3)))+ ...
            (p(4) + p(6).*MAT(:,1) + p(7).*(MAT(:,1).*MAT(:,1))).*...
            exp((p(5) + p(8).*MAT(:,1)).*(MAT(:,2)+p(3).*MAT(:,3))) +...
            (p(3)+p(9).*abs(MAT(:,1))).*MAT(:,1);
    case '27'
        myfunction = @(p,MAT) (p(1) +...
            (p(2)+p(10).*MAT(:,1)+p(11).*MAT(:,1).*MAT(:,1)).*(MAT(:,2)+p(3).*MAT(:,3)))+ ...
            (p(4) + p(6).*MAT(:,1) + p(7).*(MAT(:,1).*MAT(:,1))).*...
            exp((p(5) + p(8).*MAT(:,1)).*(MAT(:,2)+p(3).*MAT(:,3))+...
             p(12).*(MAT(:,2)+p(3).*MAT(:,3)).^p(13)) +...
            (p(3)+p(9).*abs(MAT(:,1))).*MAT(:,1);
    
    case '28'
        myfunction = @(p,MAT) (p(1) +...
            (p(2)+p(10).*MAT(:,1)+p(11).*MAT(:,1).*MAT(:,1)).*(MAT(:,2)+p(3).*MAT(:,3)))+ ...
            (p(4) + p(6).*MAT(:,1) + p(7).*(MAT(:,1).*MAT(:,1))).*...
            exp((p(5) + p(8).*MAT(:,1)).*(MAT(:,2)+p(3).*MAT(:,3))+...
             p(12).* exp((MAT(:,2)+p(3).*MAT(:,3))*p(13))) +...
            (p(3)+p(9).*abs(MAT(:,1))).*MAT(:,1);
        
    case 'coseno1'
         myfunction = @(p,MAT) (p(1) +...
            (p(2)+p(10).*MAT(:,1)+p(11).*MAT(:,1).*MAT(:,1)).*(MAT(:,2)+p(3).*MAT(:,3)))+ ...
            (p(4) + p(6).*MAT(:,1) + p(7).*(MAT(:,1).*MAT(:,1))).*...
            exp((p(5) + p(8).*MAT(:,1)).*(MAT(:,2)+p(3).*MAT(:,3))+...
             p(12).* exp((MAT(:,2)+p(3).*MAT(:,3))*p(13))) +...
            (p(3)+p(9).*abs(MAT(:,1))).*MAT(:,1) + ...
            (p(14)- p(15).*(MAT(:,2)+p(3).*MAT(:,3))).*cos((MAT(:,2)+p(3).*MAT(:,3)) .* p(16));
        
    case 'coseno2'
        myfunction = @(p,MAT) (p(1) +...
            (p(2)+p(10).*MAT(:,1)+p(11).*MAT(:,1).*MAT(:,1)).*(MAT(:,2)+p(3).*MAT(:,3)))+ ...
            (p(4) + p(6).*MAT(:,1) + p(7).*(MAT(:,1).*MAT(:,1))).*...
            exp((p(5) + p(8).*MAT(:,1)).*(MAT(:,2)+p(3).*MAT(:,3))+...
            p(12).* exp((MAT(:,2)+p(3).*MAT(:,3))*p(13))) +...
            (p(3)+p(9).*abs(MAT(:,1))).*MAT(:,1) + ...
            (p(14)- p(15).*(MAT(:,2)+p(3).*MAT(:,3))).*cos((MAT(:,2)+p(3).*MAT(:,3)) .* p(16)) + ...
            p(17).*cos((MAT(:,2)+p(3).*MAT(:,3)) .* p(18)) + ...
            p(19).*cos((MAT(:,2)+p(3).*MAT(:,3)) .* p(20));
        
    otherwise
        disp('Error in type')
end


check = [];

for i = 1:5
    val = fitnlm(MAT, V, myfunction, beta0,'Weights',weights);
    check = [check; beta0, val.RMSE];
    beta0(:) = table2array(val.Coefficients(1:length(beta0),1));
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
% % It = 3;
% [val, idx3] = min(abs(data(3).It - 2));
% [val, idx1] = min(abs(data(1).It - 2));
% 
% R = abs((data(3).V(idx3) - data(1).V(idx1))/(5 - 1.5));

It = [1, 2, 3];
% It = 2;
for t = 1:3

    i = 0;
    for f = 1:length(data)
        i = i + 1;

        [val,idx] = min(abs(data(f).It - It(t)));
        V(i) = data(f).V(idx);
        I(i) = abs(data(f).I(idx));

    end
%     R(t) = ( abs((V(3) - V(2))/(I(2) - I(3))) + abs((V(2) - V(1))/(I(1) - I(2)) ))/2;
      R(t) = ( abs((V(3) - V(1))/(I(3) - I(1))) + abs((V(2) - V(1))/(I(1) - I(2)) ))/2;
%     R(t) =  abs((V(3) - V(1))/(I(3) - I(1))) ;
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

h = figure(); set(h, 'Visible', 'off')
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
%Save_as_PDF(h, ['Figures/', tit, '_','datos'],'horizontal');
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
closee = 'n';

if vIT == 'y'

    h = figure(); set(h, 'Visible', 'off')
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
%     Save_as_PDF(h, ['Figures/', titulo2, '_', titulo, '_It'],'horizontal');
    if closee == 'y'
        close
    end
end

if vIT_error == 'y'

    h = figure(); set(h, 'Visible', 'off')
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
%     Save_as_PDF(h, ['Figures/', titulo2, '_', titulo, '_It(Error)'],'horizontal', 5, 8);
    if closee == 'y'
        close
    end
end

if vPHI == 'y'

    h = figure(); set(h, 'Visible', 'off')
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
    if strcmp(titulo,'coseno1') || strcmp(titulo,'coseno2')
        Save_as_PDF(h, ['Figures/', titulo2, '_', titulo, '_phi'],'horizontal');
    end
    if closee == 'y'
        close
    end

end

if vPHI_error == 'y'

    h = figure(); set(h, 'Visible', 'off')
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
    if strcmp(titulo,'coseno1') || strcmp(titulo,'coseno2')
        Save_as_PDF(h, ['Figures/', titulo2, '_', titulo, '_phi(Error)'],'horizontal');
    end
    if closee == 'y'
        close
    end

end

%   h = figure(); set(h, 'Visible', 'off')
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
