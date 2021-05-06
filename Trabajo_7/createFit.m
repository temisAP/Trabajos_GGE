function [fitresult, gof] = createFit(Pout, Eff)

%% Fit: 'fit'.
[xData, yData] = prepareCurveData( Pout, Eff );

% Set up fittype and options.
ft = fittype( 'a*(c-exp(-b*x))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.7 4 1];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );




