function [] = Save_as_PDF(h, path, rotation)
    % save figure as PDF
    set(get(gca,'ylabel'),'rotation',rotation)
    set(gca,'TickLabelInterpreter','latex');
    set(gca,'FontSize',10.5);
    set(gca,'LabelFontSizeMultiplier',1.35);
    set(gca,'TitleFontSizeMultiplier',1.25);
    
    set(h,'Units','Inches');
    pos = get(h,'Position');
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(h, path,'-dpdf','-r0','-painters')

end