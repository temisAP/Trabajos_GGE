clc
clear all
close all

load('data.mat');
%        1   2   3   4  5   6   7   8
order = [3,  2,  3,  1, 2,  1,  2,  2];
span =  [5, 25, 21, 31, 5, 11, 101, 5];

% dt = 1/5; t = (0:dt:200-dt)';  i = 5*sin(2*pi*0.2*t) + randn(size(t));
% order = 3; framelen = 21;  b = sgolay(order,framelen);

for s = 2
    v = data{s,1}; 
    i = data{s,2}; 
    %dydx = gradient(i(:)) ./ gradient(v(:));
% 
% ycenter = conv(i,b((framelen+1)/2,:),'valid');
% ybegin = b(end:-1:(framelen+3)/2,:) * i(framelen:-1:1); yend = b((framelen-1)/2:-1:1,:) * i(end:-1:end-(framelen-1));
% y = [ybegin; ycenter; yend]; plot([i y]) 
% legend('Noisy Sinusoid','S-G smoothed sinusoid')
%     
    

    
    if s == 6
        v(end) = []; 
        i(end) = []; 
    end
    
    sgf = sgolayfilt(i,order(s),span(s)); 
    %sgf = sgolayfilt(dydx,order(s),span(s)); 
    p_origen = -inv((sgf(4)-sgf(1))/(v(4)-v(1)))
    p_final = -inv((sgf(end-4)-sgf(end))/(v(end-4)-v(end)))
    
    figure(s)
        plot(v,[i, sgf])
        
    pendientes(s,:) = [p_origen, p_final];
    
end

%% Filtro a la derivada

didv = gradient(i(:))./gradient(v(:));
didv = sgolayfilt(didv, 3, 21); 

disp([ 'R1 = ' num2str(inv(-didv(1))) 'R2 = ' num2str(inv(-didv(end)))])

figure()
    hold on
    plot(v,i)
    plot(v, didv)
    
% dt = 1/5; t = (0:dt:200-dt)';  x = 5*sin(2*pi*0.2*t) + randn(size(t));
% 
% order = 7; framelen = 21;  b = sgolay(order,framelen);
% ycenter = conv(x,b((framelen+1)/2,:),'valid');
% ybegin = b(end:-1:(framelen+3)/2,:) * x(framelen:-1:1); yend = b((framelen-1)/2:-1:1,:) * x(end:-1:end-(framelen-1));
% y = [ybegin; ycenter; yend]; plot([x y]) 
% legend('Noisy Sinusoid','S-G smoothed sinusoid')
%%


% voc = v(1:40); vsc = v(40:end);
% ioc = i(1:40); isc = i(40:end);
% 
% order = 3;
% span = 21;
% sgf = sgolayfilt(ioc,order,span); 
% figure()
%     plot(voc,[ioc, sgf])
%     
% p_origen = -inv((sgf(2)-sgf(1))/(voc(2)-voc(1)))
% 
% 
% sgf = sgolayfilt(isc,3,21); 
% figure()
%     plot(vsc,[isc, sgf])
%     
% p_final = -inv((sgf(end-1)-sgf(end))/(v(end-1)-v(end)))