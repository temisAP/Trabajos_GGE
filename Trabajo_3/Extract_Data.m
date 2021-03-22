%% Programa para guardar los valores del excel

clc
clear all
close all


%% DATOS EXPERIMENTALES
read_sheet = {'RTC France', 'TNJ', 'ZTJ', '3G30C','PWP201', 'KC200GT2', 'SPVSX5', 'PSC','CTJ30','ATJ','4S1P'};
read_filename = 'IV_curves.xlsx';

Cells = struct();

for s = 1:length(read_sheet)
    Cells(s).Name = read_sheet{s};
    Cells(s).V_mess = xlsread(read_filename, read_sheet{s}, 'A21:A1202')';
    Cells(s).I_mess = xlsread(read_filename, read_sheet{s}, 'B21:B1202')';
    Cells(s).Isc = xlsread(read_filename, read_sheet{s}, 'B1');
    Cells(s).Imp = xlsread(read_filename, read_sheet{s}, 'B2');
    Cells(s).Vmp = xlsread(read_filename, read_sheet{s}, 'B3');
    Cells(s).Voc = xlsread(read_filename, read_sheet{s}, 'B4');
    
end

save('Data/Cells_Data.mat', 'Cells')


%% MODELO 1D2R
path_1D2R = '1D2R\Fit_model_1D2R.xlsx';
analitico_1D2R = struct();
numerico_1D2R = struct();

for s = 1:length(read_sheet)    
    sheet = 'Analitico';
    [analitico_1D2R(s).Ipv, analitico_1D2R(s).I0, analitico_1D2R(s).Rs,...
     analitico_1D2R(s).Rsh,analitico_1D2R(s).a] = read_1d2r(path_1D2R,sheet,s);
 
    sheet = 'Numerico';
    [numerico_1D2R(s).Ipv, numerico_1D2R(s).I0, numerico_1D2R(s).Rs,...
     numerico_1D2R(s).Rsh,numerico_1D2R(s).a] = read_1d2r(path_1D2R,sheet,s);

end

save('Data/analitico_1D2R.mat', 'analitico_1D2R')
save('Data/numerico_1D2R.mat', 'numerico_1D2R')


%% MODELO 2D2R
path_2D2R = '2D2R\Fit_model_2D2R.xlsx';
analitico_2D2R = struct();
numerico_2D2R = struct();

for s = 1:length(read_sheet)    
    sheet = 'Analitico';
    [analitico_2D2R(s).Ipv, analitico_2D2R(s).I01, analitico_2D2R(s).I02,...
     analitico_2D2R(s).Rs, analitico_2D2R(s).Rsh, analitico_2D2R(s).a1,...
     analitico_2D2R(s).a2] = read_2d2r(path_2D2R,sheet,s);
 
    sheet = 'Numerico';
    [numerico_2D2R(s).Ipv, numerico_2D2R(s).I01, numerico_2D2R(s).I02,...
     numerico_2D2R(s).Rs, numerico_2D2R(s).Rsh, numerico_2D2R(s).a1,...
     numerico_2D2R(s).a2] = read_2d2r(path_2D2R,sheet,s);

end

save('Data/analitico_2D2R.mat', 'analitico_2D2R')
save('Data/numerico_2D2R.mat', 'numerico_2D2R')


%% FUNCIONES
function [Ipv,I0,Rs,Rsh,a] = read_1d2r(filename,sheet,s)
    try
        % Ipv
        pos = strjoin({'B',num2str(s+1)},'');
        Ipv = xlsread(filename,sheet,pos);
        % I0
        pos = strjoin({'C',num2str(s+1)},'');
        I0 = xlsread(filename,sheet,pos);
        % Rs
        pos = strjoin({'D',num2str(s+1)},'');
        Rs = xlsread(filename,sheet,pos);
        % Rsh
        pos = strjoin({'E',num2str(s+1)},'');
        Rsh = xlsread(filename,sheet,pos);
        % a
        pos = strjoin({'F',num2str(s+1)},'');
        a = xlsread(filename,sheet,pos);
    catch
        disp('No data')
        Ipv = 1;
        I0 = 1;
        Rs =1;
        Rsh = 1;
        a = 1;
    end
end

function [Ipv,I01,I02,Rs,Rsh,a1,a2] = read_2d2r(filename,sheet,s)
    try
        % Ipv
        pos = strjoin({'B',num2str(s+1)},'');
        Ipv = xlsread(filename,sheet,pos);
        % I01
        pos = strjoin({'C',num2str(s+1)},'');
        I01 = xlsread(filename,sheet,pos);
        % I02
        pos = strjoin({'D',num2str(s+1)},'');
        I02 = xlsread(filename,sheet,pos);
        % Rs
        pos = strjoin({'E',num2str(s+1)},'');
        Rs = xlsread(filename,sheet,pos);
        % Rsh
        pos = strjoin({'F',num2str(s+1)},'');
        Rsh = xlsread(filename,sheet,pos);
        % a1
        pos = strjoin({'G',num2str(s+1)},'');
        a1 = xlsread(filename,sheet,pos);
        % a2
        pos = strjoin({'H',num2str(s+1)},'');
        a2 = xlsread(filename,sheet,pos);
    catch
        disp('No data')
        Ipv = 0;
        I01 = 0;
        I02 = 0;
        Rs =0;
        Rsh = 0;
        a1 = 0;
        a2 = 0;
    end
end