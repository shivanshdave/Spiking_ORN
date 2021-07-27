
%% Figure-1 (Reisert 1999) Pulse-1, Conc-8
PULSE.ton = 0.5000*ones(8,1);
PULSE.toff = 1.5000*ones(8,1);
PULSE.conc = [300,100,50,20, 10,5,2,1]';
PULSE.tspan = [0 4];

D.R99.F1 = simulate_ORN(PULSE);
%%
plot_currents(D.R99.F1)
%%
% plot_adaptation_raw(DATA)

%% Figure-5 (Reisert 1999) Pulse-2, Conc-5 (0,2,5,10)
PULSE = struct;
n=4;
PULSE.ton = [0,4].*ones(n,2);
PULSE.toff = [4,5].*ones(n,2);
PULSE.conc(:,1) = [0,2,5,10]';
PULSE.conc(:,2) = 20*ones(n,1);
PULSE.tspan = [-0.5 7];

D.R99.F5 = simulate_ORN(PULSE);
%%
plot_currents(D.R99.F5)

function plot_currents(DATA)

    PULSE = DATA.PULSE;
    IPREDn = DATA.IPREDn;
    T = DATA.T;    
    
    %%


    figure;
    np=size(PULSE.ton,2);
    nc=size(PULSE.ton,1);
    t = tiledlayout(nc,1,'TileSpacing','none','Padding','compact');

    Nstim = 1:length(PULSE.ton(:,1));
    ftSz = 14;


    for k = 1:length(Nstim)
        nexttile;
        
        plot(T,real(IPREDn.PRED_CURRENT(:,k)),'-');
        set(gca,'ColorOrderIndex',k)
        ylim([-2 2])
        axis off

    end
   %%
   return;
    ylabel('Normalized Current','Fontsize',ftSz);		
    xlabel('Time (s)','Fontsize',ftSz);

    %Put in odorant trace.
    figure;
    hold on;
    TT = linspace(min(T),max(T),100);
    OD = simulate_pulse_train(TT,PULSE.ton,PULSE.toff,PULSE.conc);
    OD = OD(end,:);
    plot(TT,OD,'k-','LineWidth',2);
    this_ax = axis;
    this_ax(4) = this_ax(4) + 0.2*abs(this_ax(4)-this_ax(3));
    axis(this_ax);
    axis off;
    conc = sprintf('%.4g, ',unique(PULSE.conc));
    conc = conc(1:end-2);
    text(TT(1),1.5*max(OD(:)),['Odorant ',conc,'\mu{M}'],'FontSize',16);
    box off;
    hold off;
    set(gca,'Xlim',get(AX(2),'XLim'));

end

function plot_adaptation_raw(DATA)

    PULSE = DATA.PULSE;
    PRED = DATA.PRED;
    IPREDn = DATA.IPREDn;
    T = DATA.T;


    F1 = figure;

    UKEY = 1:length(PULSE.ton(:,1));
    var_names = fieldnames(PRED);
%     var_names = var_names(1:9);
    
    SPACE = 0.05;
    SP_WD = 0.8;
    SP_HT = 1/(length(UKEY) + 0.5) - 0.5*SPACE; 	

    OD_SP_WD = SP_WD;
    OD_SP_HT = 0.5*SP_HT;

    AX(1) = axes;%Odorant trace axis.
    set(AX(1),'Units','normalized','Position',[0.1, length(UKEY)*SP_HT+3*SPACE, OD_SP_WD, OD_SP_HT]);
    for k = 2:length(UKEY)+1
        AX(k) = axes;
        set(AX(k),'Units','normalized','Position',[0.1, (1+length(UKEY)-k)*SP_HT+3*SPACE, SP_WD, SP_HT]);
    end

                    RGB = {[0 0 1],[0 0.5 0],[1 0 0],[0 0.75 0.75]};

                    AXLIM = [inf,-inf,inf,-inf];
    for k = 1:length(UKEY)
        %subplot(length(UKEY)+1,1,k+1);
        axes(AX(k+1));
        hold on;
        htotal = plot(T,real(IPREDn.PRED_CURRENT(:,k)),'-','LineWidth',2,'Color',RGB{k});

        % if ~isempty(ICNG)
% 						hcng  = plot(T,real(ICNG(:,k)),'c--','LineWidth',2);
% 					end
% 
% 					if ~isempty(ICACL)
% 						hcacl  = plot(T,real(ICACL(:,k)),'m--','LineWidth',2);
% 					end
% 
% 					if ~isempty(IL)
% 						hleak = plot(T,IL(:,k),'g--','LineWidth',2);
% 					end
        hold off;
        set(gca,'FontSize',16)
        if (k ~= length(UKEY))
            set(gca,'XTickLabel',[]);
        end
            axis tight;
            axlim = axis;
            AXLIM(1) = min(AXLIM(1),axlim(1));
            AXLIM(2) = max(AXLIM(2),axlim(2)); 
            AXLIM(3) = min(AXLIM(3),axlim(3));
            AXLIM(4) = max(AXLIM(4),axlim(4));
            box off;
        end
        for k = 1:length(UKEY)
                axes(AX(k+1)); %#ok<*LAXES>
                axis(AXLIM);
        end


                    axes(AX(max(2,floor(length(UKEY)/2)+1)));
    ylabel('Normalized Current','Fontsize',18');
    axes(AX(end));			
    xlabel('Time (s)','Fontsize',18');


    axes(AX(1));
    %Put in odorant trace.
    hold on;
    TT = linspace(min(T),max(T),100);
    OD = simulate_pulse_train(TT,PULSE.ton,PULSE.toff,PULSE.conc);
    OD = OD(end,:);
    plot(TT,OD,'k-','LineWidth',2);
    this_ax = axis;
    this_ax(4) = this_ax(4) + 0.2*abs(this_ax(4)-this_ax(3));
    axis(this_ax);
    axis off;
    conc = sprintf('%.4g, ',unique(PULSE.conc));
    conc = conc(1:end-2);
    text(TT(1),1.5*max(OD(:)),['Odorant ',conc,'\mu{M}'],'FontSize',16);
    box off;
    hold off;
    set(gca,'Xlim',get(AX(2),'XLim'));


    %suptitle(NAMES{s});
                    suptitle(' ');

    F2 = figure;

    % ADDED 1 NROW
    nrows = 1 + ceil(sqrt(9));
    mcols = ceil(9/nrows);


                    ww = 1;
    for k = 1:length(var_names)
        if (strcmp(var_names{k},'bLR'))
                                    %Don't do anything.
        else
                hax = subplot(nrows,mcols,ww);% 
                plot(T,real(PRED.(var_names{k})));
                hl = ylabel(var_names{k});

                box off; 
                set(gca,'FontSize',16);
                set(get(gca,'XLabel'),'FontSize',16);
                set(get(gca,'YLabel'),'FontSize',16);
                h = findobj(gcf,'Type','line');
                set(h,'LineWidth',2);
                axis tight;
                AX = axis;
                fac = 0.1*(AX(4)-AX(3)); %Give a little space.
                AX(3) = AX(3)-fac;
                AX(4) = AX(4)+fac;
                axis(AX);
                if (ww ~= 8)
                    set(gca,'XTickLabel',[]);
                else 
                    xlabel('Time (s)','Fontsize',18');
                end
                                    ww = ww + 1;
        end
    end

    if ~isempty(IPREDn.ICNG)
        hax = subplot(nrows,mcols,ww);                                              
        hcng  = plot(T,real(IPREDn.ICNG),'-','LineWidth',2);          
        hl = ylabel('CNG Curr. (pA)','Fontsize',16');
        box off; 
        set(gca,'FontSize',16);
        set(get(gca,'XLabel'),'FontSize',16);
        set(get(gca,'YLabel'),'FontSize',16);
        h = findobj(gcf,'Type','line');
        set(h,'LineWidth',2);
        axis tight;
        AX = axis;
        fac = 0.1*(AX(4)-AX(3)); %Give a little space.
        AX(3) = AX(3)-fac;
        AX(4) = AX(4)+fac;
        axis(AX);
        if (ww ~= 8)
            set(gca,'XTickLabel',[]);
        else 
            xlabel('Time (s)','Fontsize',18');
        end
        axis(AXLIM);             

        ww = ww + 1;                                              
    end                                                            

    if ~isempty(IPREDn.ICACL)  
        hax = subplot(nrows,mcols,ww);
        hcacl  = plot(T,real(IPREDn.ICACL),'-','LineWidth',2);                                              
        hl = ylabel('Cl(Ca) Curr. (pA)');       

        box off; 
        set(gca,'FontSize',16);
        set(get(gca,'XLabel'),'FontSize',16);
        set(get(gca,'YLabel'),'FontSize',16);
        h = findobj(gcf,'Type','line');
        set(h,'LineWidth',2);
        axis tight;
        AX = axis;
        fac = 0.1*(AX(4)-AX(3)); %Give a little space.
        AX(3) = AX(3)-fac;
        AX(4) = AX(4)+fac;
        axis(AX);
        if (ww ~= 8)
            set(gca,'XTickLabel',[]);
        else 
            xlabel('Time (s)','Fontsize',18');
        end

        axis(AXLIM);   
        ww = ww + 1;  
    end                                                            





    % nrows = ceil(sqrt(length(var_names)));
% 				mcols = ceil(length(var_names)/nrows);
% 
% 				for k = 1:length(var_names)
% 					hax = subplot(nrows,mcols,k);% 
% 					plot(T,real(PRED.(var_names{k})));
% 					hl = ylabel(var_names{k});
% 
% 					box off; 
% 					set(gca,'FontSize',16);
% 					set(get(gca,'XLabel'),'FontSize',16);
% 					set(get(gca,'YLabel'),'FontSize',16);
% 					h = findobj(gcf,'Type','line');
% 					set(h,'LineWidth',2);
% 					axis tight;
% 					AX = axis;
% 					fac = 0.1*(AX(4)-AX(3)); %Give a little space.
% 					AX(3) = AX(3)-fac;
% 					AX(4) = AX(4)+fac;
% 					axis(AX);
% 					if (k ~= length(var_names))
% 						%set(gca,'XTickLabel',[],'FontSize',16,'XColor',[1 1 1]);
% 					else
% 						xlabel('Time (s)','Fontsize',16');
% 					end
% 				end
    subplotspace('h',15);
    %suptitle(NAMES{s});

end