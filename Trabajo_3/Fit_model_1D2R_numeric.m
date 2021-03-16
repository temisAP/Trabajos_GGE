%% Fit model 1D2R

%%%%% Matriz de puntos caracteristicos de cada IV curve
clear all
clc

% Temperatura
kB = 1.380649e-23; %J K-1
qe = 1.6e-19; %C
T = 288.15; %K
global Vt; Vt = kB*T/qe;

% Nombre de las hojas del archivo excel
read_filename = 'IV_curves.xlsx';
sheet = {'RTC France', 'TNJ', 'ZTJ', '3G30C','PWP201', 'KC200GT2', 'SPVSX5', 'PSC'};

% Selección de hoja (s)
% 1 ---> RTC France
% 2 ---> TNJ
% 3 ---> ZTJ
% 4 ---> 3G30C
% 5 ---> PWP201
% 6 ---> KC200GT2
% 7 ---> SPVSX5
% 8 ---> PSC


%% Bucle para cada hoja
for s = 1:8
    
    clear u
    
    % Carga de valores experimentales
    V_mess = xlsread(read_filename, sheet{s}, 'A21:A1202');
    I_mess = xlsread(read_filename, sheet{s}, 'B21:B1202');
    Isc = xlsread(read_filename, sheet{s}, 'B1');
    Imp = xlsread(read_filename, sheet{s}, 'B2');
    Vmp = xlsread(read_filename, sheet{s}, 'B3');
    Voc = xlsread(read_filename, sheet{s}, 'B4');
    betha = xlsread(read_filename, sheet{s}, 'B5'); % Imp/Isc
    alpha = xlsread(read_filename, sheet{s}, 'B6'); % Vmp/Voc
    
    V_mess = V_mess';
    I_mess = I_mess';
    
    % Minimize Least squares
    [umin,fval]=fminsearch(@(u)RECT(u,V_mess,I_mess),[1,1e-8,1,10,1]);
    
    % Results: parameters of equivalent circuit
    
    Ipv=umin(1);
    I0=umin(2);
    Rs=umin(3);
    Rsh=umin(4);
    a=umin(5);
    
    % Plot de valores experimentales y Karmalkar analytic
    
    I_modelo = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo(i) = Panel_Current(umin,V_mess(i));
    end
    
%     h_ = figure(1);
%         hold on
%         plot(V_mess, I_mess, '-', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', 'Experimental')
%         plot(V_mess, I_modelo, '-.', 'LineWidth', 1.5, 'Color', 'k', 'DisplayName', '1D2R')
%         scatter([0 Vmp Voc], [Isc Imp 0], 50, 'k', 'filled','o', 'DisplayName', 'Puntos caracteristicos')
%         hold off
%         axis([0, V_mess(end), 0, I_mess(1)*1.05])
%         box on; grid on
%         xlabel('$V$ [V]','Interpreter','latex')
%         ylabel({'$I$';'[A]'},'Interpreter','latex')
%         legend('Interpreter', 'Latex', 'location', 'SouthWest')
%         Save_as_PDF(h_, ['Figures/1D2R', sheet{s}], 'horizontal');
    
    save_filename = 'Fit_model_1D2R.xlsx';
    save_sheet = 'Hoja1';
        
    % Name
    pos = strjoin({'A',num2str(s+1)},'');
    A = cellstr(sheet{s});
    xlswrite(save_filename,A,save_sheet,pos);
    % Ipv
    pos = strjoin({'B',num2str(s+1)},'');
    A = round(Ipv,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % I0
    pos = strjoin({'C',num2str(s+1)},'');
    A = round(I0,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % Rs
    pos = strjoin({'D',num2str(s+1)},'');
    A = round(Rs,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % Rsh
    pos = strjoin({'E',num2str(s+1)},'');
    A = round(Rsh,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    % a
    pos = strjoin({'F',num2str(s+1)},'');
    A = round(a,3,'significant');
    xlswrite(save_filename,A,save_sheet,pos);
    
end

%% Funciones

function I_modelo = Panel_Current(u, V_mesh)
global Vt

%Ipv=u(1); I0=u(2); Rs=u(3); Rsh=u(4); a=u(5);

I_modelo =fzero(@(I) u(1)-u(2)*(exp((V_mesh+u(3)*I)/(Vt*u(5)))-1)-(V_mesh+u(3)*I)/u(4)-I, 0);
end

function error = RECT(u, V_mesh, I_exp)

for i=1:size(V_mesh,2)
    I_modelo(i) = Panel_Current(u,V_mesh(i));
end
error = (sum((I_modelo - I_exp).^2))^0.5;

end
