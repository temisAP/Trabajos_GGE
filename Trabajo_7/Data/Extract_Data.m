clear all
clc

%% LEER DATOS

filename = 'efficiencies_dc_dc.xlsx';

%% DESCARGA

sheets = [1:3];
names = {'3_3 V', '5 V', '15 V'};

DCDC = struct();

for s = 1:length(sheets)
    
    % Read xls sheet
    data = xlsread(filename,sheets(s));

    % Assign struct fields
    DCDC(s).Name = names{s};
    DCDC(s).Vin = data(:,1);
    DCDC(s).Iin = data(:,2);
    DCDC(s).Pin = data(:,3);
    
    DCDC(s).Vout = data(:,4);
    DCDC(s).Iout = data(:,5);
    DCDC(s).Pout = data(:,6);
    
    DCDC(s).PinPout = data(:,7);
    DCDC(s).Eff = data(:,8);
        
end

save('DCDC.mat', 'DCDC');