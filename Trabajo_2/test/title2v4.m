function h = title2(str)
% TITLE2(STR) places a two line title above the plot.
% STR is the string, and each line is separated by a
% vertical bar, |.
% The axis is resized to accomodate the title.

% Resizing the Figure Window will effect the location
% of the titles.

% Written by John L. Galenski III
% All Rights Reserved  05-11-94
% LDM051194jlg
% modified by jae H. Roh, 1-20-97

% Extract each line
vb = find(str == '|');
str1 = str(1:vb-1);
str2 = str(vb+1:length(str));

% Determine the location of the title
ht = get(gca,'Title');

% save Unit settings
aUnits = get(gca,'Units');
htUnits = get(ht,'Units');

% work in pixels
set(ht,'Units','pixels');
pt = get(ht, 'Position');

% Make the axes title invisible so that it 
% does not interfare with the two line title
set(ht,'Visible','Off') 

% Place the first line in its usual place
t1 = text('String',str1,'Units','pixels', ...
          'Position',pt,'Vertical','Base', ...
                'Horizontal','center');
            et = get(t1,'Extent');
            
            % shrink the axis to make room for the second line
            set(gca,'Units','pixels');
            axisPos = get(gca,'Position');
            axisPos(4) = axisPos(4)-et(4);
            set(gca,'Position',axisPos);
            
            % place the second line
            t2 = text('String',str2,'Units','pixels', ...
                      'Position',[pt(1) pt(2)-et(4)],'Vertical','bottom', ...
                        'Horizontal','center');
                        
                        % restore units settings
                        set([t1 t2],'Units',htUnits);
                        set(gca,'Units',aUnits);
                        
                        % Return the handles if requested
                        if nargout == 1
                            h = [t1;t2];
                            end
