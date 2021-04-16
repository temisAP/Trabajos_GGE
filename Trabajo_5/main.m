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


%% Modelo lineal
[linearmodel, iter_lineal] = linearbatt(Descarga,Rd);
plotmodel(linearmodel,Descarga);


%% Modelo exponencial

expmodel = expbatt(Descarga,linearmodel);
plotmodel(expmodel,Descarga);

%% Plot

function plotmodel(model,data)

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
      plot(It, V, ...
        'LineWidth', 1.5, 'Color', color(d,:), 'DisplayName', data(d).Name)
      plot(It, data(d).V,...
        'LineWidth', 1.5, 'Color', color(d,:), 'DisplayName', data(d).Name)
    end
    grid on; box on;
    legend('Interpreter', 'Latex', 'Location', 'Best')
    title('Modelo lineal')

% V(phi)

  h = figure();
    hold on
    for d=1:length(data)
      MAT = matrix(data(d));
      V = model.Formula.ModelFun(p,MAT);
      phi = MAT(:,2) + MAT(:,3) * p(3);

      plot(phi, V, ...
        'LineWidth', 1.5, 'Color', color(d,:), 'DisplayName', data(d).Name)
      plot(phi, data(d).V,...
        'LineWidth', 1.5, 'Color', color(d,:), 'DisplayName', data(d).Name)
    end
    grid on; box on;
    legend('Interpreter', 'Latex', 'Location', 'Best')
    title('Modelo lineal')

end

%% Modelo lineal

function [val, check] = linearbatt(data,R)

  [MAT, V] = matrix(data);

  i = 0;
  for d = 1:length(data)
    weights(1+i:i+length(data(d).V)) = length(data(d).V)/length(V);
    i = i+length(data(d).V);
  end

  myfunction = @(p,MAT) (p(1) + p(2)*(MAT(:,2)+p(3)*MAT(:,3)) ) + p(3)*MAT(:,1) ;

  beta0 = [max(V) -1.5e-5 R];
  check = beta0;

  for i = 1:5
    val = fitnlm(MAT, V, myfunction, beta0,'Weights',weights);
    beta0(:) = table2array(val.Coefficients(1:3,1));
    check = [check; beta0];
  end

end


%% Modelo exponencial

function val = expbatt(data, model)

  [MAT, V] = matrix(data);

  i = 0;
  for d = 1:length(data)
    weights(1+i:i+length(data(d).V)) = length(data(d).V)/length(V);
    i = i+length(data(d).V);
  end


  myfunction = @(p,MAT) (p(1) + p(2)*(MAT(:,2)+p(3)*MAT(:,3)) ) + ...
                         p(4)*exp(p(5)*(MAT(:,2)+p(3)*MAT(:,3)) + p(3)*MAT(:,1)) ;

  p = model.Coefficients.Estimate;
  beta0 = [p(1) p(2) p(3) 1e-4 -1e-16];

  for i = 1:5
    val = fitnlm(MAT, V, myfunction, beta0,'Weights',weights);
    beta0(:) = table2array(val.Coefficients(1:5,1));
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
