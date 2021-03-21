function [] = Save_as_PDF(h, path, y_label_horientation, y_lab, y_pdf)

    % This function saves a figure to PDF format
    % Made by: Daniel del Rio Velilla
    
    % Check number of in parameters
    n = nargin;                                                             
    switch n  
        case 3
            y_lab = 0;
            y_pdf = 0;
            
        case 4
            y_pdf = y_lab;
            
        otherwise
    end
    
    % Set labels format
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',10.5);
    set(gca,'LabelFontSizeMultiplier',1.35);
    set(gca,'TitleFontSizeMultiplier',1.25);
    
    % Choose the axis position
    if strcmp(y_label_horientation,'horizontal')
        
        % Get axis size
        ax = axis();
        
        % Move x label
        xlh = get(gca,'xlabel');
        xlh.Position(1) = 0.9*( ax(2) - ax(1) ) + ax(1);  
        
        % Rotate y label
        set(get(gca,'ylabel'),'rotation',0)
        % Number of characters
        label = get(gca,'ylabel');
        for i = 1:length(label.String)
            ylab_size(i) = length(label.String{i});
        end
        
        % Move y label
        ylh = get(gca,'ylabel');
        ylh.Position(1) = -(0.11 + y_lab/100)*( ax(2) - ax(1) );
        ylh.Position(2) = 0.8*( ax(4) - ax(3) ) + ax(3);
        
        
    end

    % save figure as PDF
    set(h,'Units','Inches');
    pos = get(h,'Position');
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3)+y_pdf/10, pos(4)])
    print(h, path,'-dpdf','-r0','-painters')

end