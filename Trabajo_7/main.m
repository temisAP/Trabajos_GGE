clc
clear all
close all

%% Load data

% Load experimental data

try
    load('Data\DCDC.mat')
catch
    disp('No se ha creado el archivo de datos')
    return
end

%% Ajustar curva

Eff = DCDC(1).Eff;
Pout = DCDC(1).Pout;

color = [36.1 76.5 0;
         78 0 22.4;
         9.6 38.3 91.5]/100;

% a*(1-exp(-b*x))

for s=1:length(DCDC)
            
        % Set up fittype and options.
        ft = fittype( 'a*(1-exp(-b*x))', 'independent', 'x', 'dependent', 'y' );
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        opts.StartPoint = [0.7 4];

        % Fit model to data.
        [fitresult, gof] = fit( DCDC(s).Pout,  DCDC(s).Eff, ft, opts );
        
        DCDC(s).coef =coeffvalues(fitresult);
        DCDC(s).gof = gof;
        DCDC(s).RMSE = gof.rmse;
        
        coeff = coeffvalues(fitresult);
        x = DCDC(s).Pout;
        
        figure(s)
        hold on
            plot(DCDC(s).Pout, DCDC(s).Eff, 'o', 'MarkerSize', 5,...
            'LineWidth', 0.5, 'Color', 'k', 'DisplayName', 'Experimental')
            plot(DCDC(s).Pout, coeff(1)*(1-exp(-coeff(2)*x)), '-',...
            'LineWidth', 1.2, 'Color', color(1,:), 'DisplayName', 'Modelo 1')
            
        figure(s + length(DCDC))
        hold on
            plot(DCDC(s).Pout, abs(DCDC(s).Eff - coeff(1)*(1-exp(-coeff(2)*x))), '-',...
            'LineWidth', 1.2, 'Color', color(1,:), 'DisplayName', 'Modelo 1')
        
end

% a*(1-exp(-(b*x-c*x^2)))

for s=1:length(DCDC)
            
        % Set up fittype and options.
        ft = fittype( 'a*(1-exp(-(b*x+c*x^2)))', 'independent', 'x', 'dependent', 'y' );
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        opts.StartPoint = [DCDC(s).coef(1) DCDC(s).coef(2) -0.08];

        % Fit model to data.
        [fitresult, gof] = fit( DCDC(s).Pout,  DCDC(s).Eff, ft, opts );
        
        DCDC(s).coef2 =coeffvalues(fitresult);
        DCDC(s).gof2 = gof;
        DCDC(s).RMSE2 = gof.rmse;
        
        coeff = coeffvalues(fitresult);
        x = DCDC(s).Pout;
        
        figure(s)
        hold on
            plot(DCDC(s).Pout, coeff(1)*(1-exp(-(coeff(2)*x+coeff(3)*x.^2))), '-',...
            'LineWidth', 1.2, 'Color', color(2,:), 'DisplayName', 'Modelo 2')
        
        figure(s + length(DCDC))
        hold on
            plot(DCDC(s).Pout, abs(DCDC(s).Eff - coeff(1)*(1-exp(-(coeff(2)*x+coeff(3)*x.^2)))), '-',...
            'LineWidth', 1.2, 'Color', color(2,:), 'DisplayName', 'Modelo 2')
 
end

% a*(1-exp(-(b*x+c*x^2+d*x^3)))

for s=1:length(DCDC)
            
        % Set up fittype and options.
        ft = fittype( 'a*(1-exp(-(b*x+c*x^2+d*x^3)))', 'independent', 'x', 'dependent', 'y' );
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        opts.StartPoint = [DCDC(s).coef2(1) DCDC(s).coef2(2) DCDC(s).coef2(3) 0.008];
        opts.Lower = [-Inf -Inf -Inf 0];
        opts.Upper = [Inf Inf Inf 1000];
        
        
        % Fit model to data.
        [fitresult, gof] = fit( DCDC(s).Pout,  DCDC(s).Eff, ft, opts );
        
        DCDC(s).coef3 =coeffvalues(fitresult);
        DCDC(s).gof3 = gof;
        DCDC(s).RMSE3 = gof.rmse;
        
        coeff = coeffvalues(fitresult);
        x = DCDC(s).Pout;
        
        h = figure(s);
        hold on
            plot(DCDC(s).Pout, coeff(1)*(1-exp(-(coeff(2)*x+coeff(3)*x.^2+coeff(4)*x.^3))), '-',...
            'LineWidth', 1.2, 'Color', color(3,:), 'DisplayName', 'Modelo 3')
            grid on; box on;
            legend('Interpreter', 'Latex', 'Location', 'Best')
            xlabel('$P_{out}$ [W]','Interpreter','latex');
            ylabel({'$\eta$'},'Interpreter','latex');
            Save_as_PDF(h, ['Figures/', DCDC(s).Name],'horizontal');
            
        h = figure(s + length(DCDC));
        hold on
            plot(DCDC(s).Pout, abs(DCDC(s).Eff - coeff(1)*(1-exp(-(coeff(2)*x+coeff(3)*x.^2+coeff(4)*x.^3)))), '-',...
            'LineWidth', 1.2, 'Color', color(3,:), 'DisplayName', 'Modelo 3')
            grid on; box on;
            legend('Interpreter', 'Latex', 'Location', 'Best')
            xlabel('$P_{out}$ [W]','Interpreter','latex');
            ylabel({'$\left| \eta - \eta_{exp} \right|$'},'Interpreter','latex');
            Save_as_PDF(h, ['Figures/Error ', DCDC(s).Name],'horizontal', 7.5, 10);
 
end

%% Tabla RMSE

RMSE = [DCDC.RMSE; DCDC.RMSE2; DCDC.RMSE3];





