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


%% PHI

%{
figure()
    hold on
    c = 0;
for f = 1:2:length(fields)
    c = c + 1;
    Ensayos_Bateria.(fields{f}).phi = ...
        Ensayos_Bateria.(fields{f}).V.*ic(f)- Rc*ic(f)^2;

    plot(Ensayos_Bateria.(fields{f}).phi.*Ensayos_Bateria.(fields{f}).t,...
         Ensayos_Bateria.(fields{f}).V, 'LineWidth', 1.5,...
         'Color', color(c,:), 'DisplayName', fields{f})
end

for f = 2:2:length(fields)
    Ensayos_Bateria.(fields{f}).phi = ...
        Ensayos_Bateria.(fields{f}).V.*ic(f)- Rd*ic(f)^2;
end
%}

linearmodel = linearbatt(Descarga,Rd)


%% R

function  val = getR(data)

  It = [1, 2, 3]*1e4;
  % Carga
  for t = 1:3

      i = 0;
      for f = 1:length(data)

          i = i + 1;

          [val,idx] = min(abs(data(f).It - It(t)));
          V(i) = data(f).V(idx);
          I(i) = ic(f);

      end

      Rc(t) = mean( (V(3) - V(2))/(I(2) - I(3)) + (V(2) - V(1))/(I(1) - I(2)) );
  end

  Rc = mean(Rc);

  val = abs(Rc);


end


%% Modelo lineal

function val = linearbatt(data,R)

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

  i = 1;
  for d = 1:length(data)
    weights(i:i+length(data(d))) = length(data(d).V)/length(V);
    i = length(data(d));
  end

  myfunction = @(p,MAT) (p(1) + p(2)*(phi1+R*phi2) ) + p(3)*I ;

  beta0 = [max(V) -1.5e-5 R];

  for i = 1:5
    val = fitnlm(MAT, V, myfunction, beta0,'Weights',weights);
    beta0(:) = table2array(val.Coefficients(1:3,1));
  end

end
