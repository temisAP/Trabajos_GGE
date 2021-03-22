close all
sheet = {'RTC France', 'TNJ', 'ZTJ', '3G30C','PWP201', 'KC200GT2', 'SPVSX5', 'PSC'};

for s=1:11
    
    %% Modelo 1D2R analitico
    filename = '..\Fit_model_1D2R.xlsx';
    sheet = 'Hoja1';
    [Ipv,I0,Rs,Rsh,a] = read_1d2r(filename,sheet);
    umin = [Ipv,I0,Rs,Rsh,a(s)];
    
    I_modelo = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo(i) = Panel_Current(umin,V_mess(i));
    end
    
    error = (sum((I_modelo - I_mess).^2))^0.5;
    error2 = (((I_modelo - I_mess).^2)).^0.5;
    
    %% Modelo 1D2R numerico
    filename = '..\Fit_model_1D2R.xlsx';
    sheet = 'Hoja1';
    [Ipv,I0,Rs,Rsh,a] = read_1d2r(filename,sheet);
    umin = [Ipv,I0,Rs,Rsh,a(s)];
    
    I_modelo = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo(i) = Panel_Current(umin,V_mess(i));
    end
   
    error = (sum((I_modelo - I_mess).^2))^0.5;
    error2 = (((I_modelo - I_mess).^2)).^0.5;
    
    %% Modelo 2D2R analitico
    filename = '..\Fit_model_1D2R.xlsx';
    sheet = 'Hoja1';
    [Ipv,I01,I02,Rs,Rsh,a1,a2] = read_2d2r(filename,sheet);
    umin = [Ipv,I01,I02,Rs,Rsh,a1,a2];
    
    I_modelo2 = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo2(i) = Panel_Current_2D2R(umin,V_mess(i));
    end
    error = (sum((I_modelo2 - I_mess).^2))^0.5;
    error2 = (((I_modelo2 - I_mess).^2)).^0.5;
    
    %% Modelo 2D2R numerico
    filename = '..\Fit_model_1D2R.xlsx';
    sheet = 'Hoja1';
    [Ipv,I01,I02,Rs,Rsh,a1,a2] = read_2d2r(filename,sheet);
    umin = [Ipv,I01,I02,Rs,Rsh,a1,a2];
    
    % Discretizacion de la solucion para representarla
    I_modelo2 = zeros(size(V_mess,2),1)';
    for i=1:size(V_mess,2)
        I_modelo2(i) = Panel_Current_2D2R(umin,V_mess(i));
    end
    error = (sum((I_modelo2 - I_mess).^2))^0.5;
    error2 = (((I_modelo2 - I_mess).^2)).^0.5;
    
    
end

function [Ipv,I0,Rs,Rsh,a] = read_1d2r(filename,sheet)

try
    % Ipv
    pos = strjoin({'B',num2str(s+1)},'');
    Ipv = xlsread(filename,sheet,pos);
    % I0
    pos = strjoin({'C',num2str(s+1)},'');
    A = round(I0,3,'significant');
    I0 = xlswrite(filename,sheet,pos);
    % Rs
    pos = strjoin({'D',num2str(s+1)},'');
    Rs = xlswrite(filename,sheet,pos);
    % Rsh
    pos = strjoin({'E',num2str(s+1)},'');
    Rsh = xlswrite(filename,sheet,pos);
    % a
    pos = strjoin({'F',num2str(s+1)},'');
    a = xlswrite(filename,sheet,pos);
catch
    disp('No data')
end
end

function [Ipv,I01,I02,Rs,Rsh,a1,a2] = read_2d2r(filename,sheet)

try
    % Ipv
    pos = strjoin({'B',num2str(s+1)},'');
    Ipv = xlsread(filename,sheet,pos);
    % I01
    pos = strjoin({'C',num2str(s+1)},'');
    A = round(I0,3,'significant');
    I0 = xlswrite(filename,sheet,pos);
    % I02
    pos = strjoin({'D',num2str(s+1)},'');
    A = round(I0,3,'significant');
    I0 = xlswrite(filename,sheet,pos);
    % Rs
    pos = strjoin({'E',num2str(s+1)},'');
    Rs = xlswrite(filename,sheet,pos);
    % Rsh
    pos = strjoin({'F',num2str(s+1)},'');
    Rsh = xlswrite(filename,sheet,pos);
    % a1
    pos = strjoin({'G',num2str(s+1)},'');
    a = xlswrite(filename,sheet,pos);
    % a2
    pos = strjoin({'H',num2str(s+1)},'');
    a = xlswrite(filename,sheet,pos);
catch
    disp('No data')
end
end
