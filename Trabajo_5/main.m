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

color = [0, 0.4470, 0.7410;
         0.8500, 0.3250, 0.0980;
         0.4940, 0.1840, 0.5560];
c = 0;

% Descarga

figure()
    hold on
for f = 1:length(Descarga)
    c = c+1;
    p = polyfit(Descarga(f).It,Descarga(f).V,1);
    Descarga(f).Lineal = ...
        polyval(p,Descarga(f).It);

    % Plots
    plot(Descarga(f).It,...
         Descarga(f).V, 'LineWidth', 1.5,...
         'Color', color(c,:), 'DisplayName', Descarga(f).Name)
    plot(Descarga(f).It,...
         Descarga(f).Lineal, '--', 'LineWidth', 1.5,...
         'Color', color(c,:), 'DisplayName', Descarga(f).Name)
end
    grid on; box on;
    legend('Interpreter', 'Latex', 'Location', 'Best')
    title('Descarga')

% Carga

figure()
    hold on
for f = 1:length(Carga)
        plot(Carga(f).It,...
             Carga(f).V, 'DisplayName', Carga(f).Name)
end
    legend('Interpreter', 'Latex', 'Location', 'Best')
    title('Carga')


%% CALCULO DE Rc,d

Rc = getR(Carga);
Rd = getR(Descarga);

%% DESCARGA

modelos_descarga = modelos(Descarga,Rd);

%% CARGA
i = 3; %La curva que da mayor phi
Descarga_inicial = Descarga(i).phi1(end) + Descarga(i).phi2(end) .* modelos_descarga(i).modelo.Coefficients.Estimate(3);
for s=1:length(Carga)
    Carga(s).phi1 = Descarga_inicial - Carga(s).phi1;
end
modelos_carga = modelos(Carga,Rc);

%% Funciones

function md = modelos(data,R)

md = struct('nombre',[],'modelo',[],'iter',[]);

% Modelo lineal
m = 1;
md(m).nombre = 'Lineal';
[md(m).modelo, md(m).iter] = linearbatt(data,R);
plotmodel(md(m).modelo,data,md(m).nombre);

% Modelo exponencial
m = 2;
md(m).nombre = 'Exponencial';
[md(m).modelo, md(m).iter] = expbatt(data,md(1).modelo, [-8e-9 3e-5]);
plotmodel(md(m).modelo,data,md(m).nombre);

beta = {[-5e-16 3e-5],[-1e-15 3e-5],[-1e-15 3e-5]};
for s = 1:length(data)
    m=m+1;
    md(m).nombre = ['Exponencial' num2str(s)];
    [md(m).modelo, md(m).iter] = expbatt(data,md(1).modelo,beta{s});
    plotmodel(md(m).modelo,data,md(m).nombre);
end

% Modelo exponencial-lineal
m = m+1;
md(m).nombre = 'Exponencial-Lineal';
[md(m).modelo, md(m).iter]= explinealbatt(data,md(2).modelo);
plotmodel(md(m).modelo,data,md(m).nombre);

md;

end

%% CARGA


%% Funciones

function plotmodel(model,data,titulo)

  color = [0, 0.4470, 0.7410;
           0.8500, 0.3250, 0.0980;
           0.4940, 0.1840, 0.5560];

  p = model.Coefficients.Estimate;

  % V(It)

  h = figure();
    hold on
    for d=1:length(data)
      MAT = matrix(data(d));
      V = model.Formula.ModelFun(p,MAT);
      It = data(d).It;
      plot(It, V,'--', ...
        'LineWidth', 1.5, 'Color', color(d,:), 'DisplayName', data(d).Name)
      plot(It, data(d).V,...
        'LineWidth', 1.5, 'Color', color(d,:), 'DisplayName', data(d).Name)
    end
    grid on; box on;
    ylim([15 25])
    legend('Interpreter', 'Latex', 'Location', 'Best')
    title(titulo)
    %Save_as_PDF(h_, ['Figuras/1_Nu_dif_', sheet{s}],'horizontal');

% V(phi)

  h = figure();
    hold on
    for d=1:length(data)
      MAT = matrix(data(d));
      V = model.Formula.ModelFun(p,MAT);
      phi = MAT(:,2) + MAT(:,3) * p(3);

      plot(phi, V, '--',...
        'LineWidth', 1.5, 'Color', color(d,:), 'DisplayName', data(d).Name)
      plot(phi, data(d).V,...
        'LineWidth', 1.5, 'Color', color(d,:), 'DisplayName', data(d).Name)
    end
    grid on; box on;
    ylim([15 25])
    legend('Interpreter', 'Latex', 'Location', 'Best')
    title(titulo)
    %Save_as_PDF(h_, ['Figuras/1_Nu_dif_', sheet{s}],'horizontal');

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

%% Modelo lineal

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


%% Modelo exponencial

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


%% Modelo exponencial-lineal

function [val, check]= explinealbatt(data, model)

  [MAT, V] = matrix(data);

  i = 0;
  for d = 1:length(data)
    weights(1+i:i+length(data(d).V)) = 1-length(data(d).V)/length(V);
    i = i+length(data(d).V);
  end


  myfunction = @(p,MAT) (p(1) + p(2)*(MAT(:,2)+p(3)*MAT(:,3)))  + ...
                         (p(4) + p(6)*MAT(:,1) + p(7).*(MAT(:,1).*MAT(:,1))).*exp((p(5) + p(8)*MAT(:,1)).*(MAT(:,2)+p(3)*MAT(:,3))) + p(3)*MAT(:,1) ;

  p = model.Coefficients.Estimate;
  beta0 = [p(1) p(2) p(3) p(4) p(5) -1e-5 -1e-5 -1.5e-16];
  check = [];

  for i = 1:5
    val = fitnlm(MAT, V, myfunction, beta0,'Weights',weights);
    check = [check; beta0, val.RMSE];
    beta0(:) = table2array(val.Coefficients(1:8,1));
  end

end
%% Otras funciones

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
