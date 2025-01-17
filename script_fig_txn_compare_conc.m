%% R99.F2A
SpikeEN = 0; plt.N = 8;
PULSE.ton = 0.000*ones(plt.N,1);
PULSE.toff = 1.00*ones(plt.N,1);
PULSE.conc = [300,100,50,20,10,5,2,1]';
PULSE.tspan = [-1 4];
DATA = simulate_ORN(PULSE,SpikeEN);

%% << F2A >>
plt.Lwd = 2;
plt.FTsz = 24;
plt.Xoff = 0.1;
plt.FGpos = [10 10 900 700];
plt.scale = [2 14 1];
plt.ytick = [-50,-25,0];
plt.xtick = -1:4;
plt.fname = '.\Report\figs\v1\fig_txn_compare_conc.png';

plot_pulse_currents_overlap(plt,DATA)
%% << F2B >>
% plt.Lwd = 1.5;
% plt.FTsz = 18;
plt.Xoff = 0.1;
plt.FGpos = [10 10 900 700];
plt.scale = [0 15 0];
plt.ytick = [-50,-25,0];
plt.xtick = -1:4;
plt.fname = '.\Report\figs\v1\fig_txn_compare_conc_quant.png';

plot_pulse_quantify(plt,DATA)
%%
function plot_pulse_quantify(plt,DATA)

    figure('Renderer', 'painters', 'Position', plt.FGpos);
    plt.t = tiledlayout(sum(plt.scale),1,'TileSpacing','tight','Padding','compact');
    
    %%
    [~,ix]=min(abs(DATA.T-1.5));
    sz = 100;
    nexttile([plt.scale(2) 1])
    hold on
    plot(DATA.PULSE.conc, real(max(DATA.PRED.Im)),'k--')
    scatter(DATA.PULSE.conc, real(max(DATA.PRED.Im)),sz,0.75*turbo(8),'s','LineWidth',plt.Lwd)
    plot(DATA.PULSE.conc, real(DATA.PRED.Im(ix,:)),'k-')
    scatter(DATA.PULSE.conc, real(DATA.PRED.Im(ix,:)),sz,0.75*turbo(8),'filled','s')
    text(100,-42,'Peak Current','FontSize',plt.FTsz)
    text(100,-17,'Plateau Current','FontSize',plt.FTsz)
    xlabel('Concentration (uM)')
    ylabel({'Cell Current (pA)'})
    set(gca,'xscale','log','YDir','reverse','tickdir', 'out','FontSize',plt.FTsz,...
        'color','none','box','off')
    %%
    exportgraphics(gcf,plt.fname,'Resolution',300)
end

function plot_pulse_currents_overlap(plt,D)

    figure('Renderer', 'painters', 'Position', plt.FGpos);
    plt.t = tiledlayout(sum(plt.scale),1,'TileSpacing','tight','Padding','compact');
    plt.X = [D.PULSE.tspan(1)-plt.Xoff, D.PULSE.tspan(2)];
    
    nexttile([plt.scale(1) 1])
    TT = linspace(D.T(1),D.T(end),100);
    OD = simulate_pulse_train(TT,D.PULSE.ton,D.PULSE.toff,D.PULSE.conc);
    OD = OD(end,:);
    plt.ax1 = plot(TT,OD,'k-','LineWidth',plt.Lwd);
    ylabel({'Conc.','(uM)'})
    set(gca,'XLim',plt.X,'XColor','none','XTick', [], 'XTickLabel', [],...
        'YTick', [0 1], 'YTickLabel', {'0','Var'},'YTickLabelRotation',0,...
        'tickdir', 'out','FontSize',plt.FTsz,...
        'color','none','box', 'off')

    nexttile([plt.scale(2) 1])
    hold on
    for k = 1:size(D.PULSE.ton,1)               
        plt.axl(k) = plot(D.T,real(D.PRED.Im(:,k)),'-','LineWidth',plt.Lwd);
    end
    xlabel('Time (sec)')
    ylabel({'Cell Current','(pA)'})
    lgd = legend({num2str(D.PULSE.conc)},'Location','best','Box','off');
    title(lgd,'Conc. (uM)')    
    set(gca,'XLim',plt.X,'XColor','none','XTick',[],'XTickLabel',[],...
        'YLim',[plt.ytick(1) plt.ytick(end)],'YTick',plt.ytick,...
        'tickdir', 'out','FontSize',plt.FTsz,...
        'color','none','box','off','ColorOrder',turbo(8))

    nexttile([plt.scale(3) 1])
    axis();
    xlabel('Time (sec)')
    set(gca,'XLim',plt.X,'XTick',plt.xtick,...
        'YColor','none','YTick', [], 'YTickLabel', [],...
        'tickdir', 'out','FontSize',plt.FTsz,...
        'color','none','box', 'off')
    
    exportgraphics(gcf,plt.fname,'Resolution',300)
end