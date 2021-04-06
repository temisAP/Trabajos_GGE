%% Programa para guardar los valores del excel

clc
clear all
close all


%% DATOS EXPERIMENTALES
read_sheet = {'panel_satélite'};
read_filename = 'data.xlsx';

Cells = struct();

for s = 1:length(read_sheet)
    Cells(s).Name = read_sheet{s};
    Cells(s).V_mess = xlsread(read_filename, read_sheet{s}, 'A2:A1183')';
    Cells(s).I_mess = xlsread(read_filename, read_sheet{s}, 'B2:B1183')';
    
    
    Cells(s).Isc = xlsread(read_filename, read_sheet{s}, 'B1');
    Cells(s).Imp = xlsread(read_filename, read_sheet{s}, 'B2');
    Cells(s).Vmp = xlsread(read_filename, read_sheet{s}, 'B3');
    Cells(s).Voc = xlsread(read_filename, read_sheet{s}, 'B4');
    
end


for s = 1:length(read_sheet)
    
    
    % Carga de valores experimentales
    V_mess = Cells(s).V_mess;
    I_mess = Cells(s).I_mess;
    P_mess = V_mess.*I_mess;
    

posx = V_mess(V_mess >= 8 &  V_mess <= 10.5);

[fit1, bondad] = fit(posx, P_mess(7:18), 'poly4');
coeff = coeffvalues(fit1);

x = linspace(8, 10.5, 100);

for i = 1:length(x)
    P(i) = coeff(1)*x(i)^4 + coeff(2)*x(i)^3 + coeff(3)*x(i)^2 + coeff(4)*x(i) + coeff(5);
end

[P_mp, pos_max] = max(P);
V_mp = x(pos_max);
pos_mp = 15;
I_mp = I_mess(pos_mp);


[fit2, bondad2] = fit(V_mess((end-5):end), I_mess((end-5):end), 'poly2');
coeff2 = coeffvalues(fit2);

x2 = linspace(V_mess(end-5), V_mess(end), 100);

% for i =1:100
%     I(i) = coeff2(1)*x(i)^2 + coeff2(2)*x(i) + coeff(3);
% end
V_oc = roots(coeff2');

[fit3, bondad3] = fit(V_mess(1:5), I_mess(1:5), 'poly1');
coeff3 = coeffvalues(fit3);
Isc = coeff3(2);


    Cells(s).Isc = Isc;
    Cells(s).Imp = I_mp;
    Cells(s).Vmp = V_mp;
    Cells(s).Voc = V_oc;
    
end

save('Cells_Data.mat', 'Cells')