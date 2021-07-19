function DATA = simulate_ORN(PULSE)
%% System co-eff
P = struct('Sigma',0.0569, 'cap',0.0039, 'cc1lin',0.7750,...
        'cc2',26.3950,'ck1lin',8.5342,'ck2',0.3069,'clmax',0.9397,...
        'cnmax',0.9663,'cx1lin',1.2307,'cx2',10.9297,'ef',2.7583,...
        'gl',4.9195,'hmc1',1.4829,'hmc2',2.7678,'inf',1.7619,'inhmax',3.5697,...
        'k1',0.1143,'k2lin',12.9344,'kI',10.0453,'kinh',1.0018,'kinhcng',0.5181,...
        'n1',3.1844,'n2',3.1128,'nI',1.9848,'ninh',1.3081,'ninhcng',1.4511,...
        'pd',7.5749,'r1',3.1663,'r2',6.5597,'smax',45.5118,'vcl',-7.7902,...
        'vcng',0.0106,'vl',-44.0413);

%% Initialize
init_bLR   = 1.e-8;
init_aG    = 1.e-8;
init_cAMP  = 1.e-8;
init_Ca    = 1.e-8; 
init_CAMK = 1.e-8;
init_CaCAM = 1.e-8;
init_IX = 1.e-8;
init_V = -70;

yinit = {init_bLR, init_aG, init_cAMP, init_Ca,init_CaCAM,init_CAMK,init_IX,init_V};
FN = {'bLR','aG','cAMP','Ca','CaCaM','aCaMK','IX','V'};
yinit = cell2struct(yinit,FN,2);
N = size(PULSE.ton,1);
var_names = fieldnames(yinit);
init_vals = struct2cell(yinit);
init_vals = [init_vals{:}];
init_vals = repmat(init_vals(:)',N,1);
init_vals = init_vals(:)';		

NVAR = length(var_names);
NCURVE = length(PULSE.ton(:,1));
NEQ = NVAR*NCURVE;
JP = spdiags(ones(NEQ,2*NVAR-1),[-(NEQ-NCURVE):NCURVE:(NEQ-NCURVE)],NEQ,NEQ);

%% SImulate
%Solve for 6 seconds so that we may come to a steady-state from our initial conditions.
tspan = [-6;PULSE.tspan'];
ODEOPTS = odeset('JPattern','on','MaxStep',0.9);

tic % start timer
[T,Y] = ode15s(@(t,y) SYSTEM(t,y,ODEOPTS,PULSE,P,N,JP), tspan, init_vals);

%Cut off the initial solution point which was just there to get us to steady-state.
T = T(2:end);
Y = Y(2:end,:);

PRED = [];
for j = 1:length(var_names)
    PRED.(var_names{j}) = Y(:,((j-1)*N+1):(j*N));
end

%% Compute currents
Incx = [];
inhcng = 1+(P.inhmax-1).*PRED.CaCaM.^P.ninhcng./(PRED.CaCaM.^P.ninhcng + P.kinhcng.^P.ninhcng);
%inhcng = 1;
Icng = (P.cnmax.*PRED.cAMP.^P.n1./(PRED.cAMP.^P.n1 + (inhcng.*P.hmc1).^P.n1)).*(P.vcng-PRED.V);
Icacl = (P.clmax.*PRED.Ca.^P.n2./(PRED.Ca.^P.n2 + P.hmc2.^P.n2)).*(P.vcl-PRED.V);
Il = P.gl.*(P.vl-PRED.V);        

% predicted currents
IPRED.PRED_CURRENT = -Icng - Icacl;
IPRED.ICNG = -Icng;
IPRED.ICACL = -Icacl;
IPRED.INCX = -Incx;
IPRED.IL = -Il;

% normalized currents
NORMALIZING_FACTOR = 70;
IPREDn.ICNG = IPRED.ICNG/NORMALIZING_FACTOR;
IPREDn.ICACL = IPRED.ICACL/NORMALIZING_FACTOR;
IPREDn.INCX = IPRED.INCX/NORMALIZING_FACTOR;
IPREDn.IL = IPRED.IL/NORMALIZING_FACTOR;	
IPREDn.PRED_CURRENT = IPRED.PRED_CURRENT/NORMALIZING_FACTOR;
IPREDn.NORMALIZING_FACTOR = NORMALIZING_FACTOR;

DATA.PULSE = PULSE;
DATA.PRED = PRED;
% DATA.IPRED = IPRED;
DATA.IPREDn = IPREDn;
DATA.T = T;
end


function dy = SYSTEM(t,y,ODEOPTS,PULSE,P,N,JP) 
    if toc > 120
        error('Maximum execution time elapsed.');
    end
    
    if strcmp(ODEOPTS,'jpattern')
		dy = JP;
    else
		%Define the tot variables to be 1.
		P.Rtot = 1;
		P.Gtot = 1;

		bLR = y(1:N,1);
		aG = y(N+1:2*N,1);
		cAMP = y(2*N+1:3*N,1);
		Ca = y(3*N+1:4*N,1);
		CaCAM = y(4*N+1:5*N,1);
		CAMK = y(5*N+1:6*N,1);
		IX = y(6*N+1:7*N,1);
		V = y(7*N+1:8*N,1);

		%#####LIGAND-RECEPTOR INTERACTION#####
		k2 = P.k2lin.*bLR;
		%#####TRANSDUCTION####################
		%a1 = P.a1lin.*aG.*(P.ACtot-aAC);
		cc1 = P.cc1lin.*Ca;
		%cx1 = 10*P.ck1lin.*CaCAM.^2; 
		%cx1 = P.cx1lin.*CaCAM; 
		cx1 = P.cx1lin.*Ca;
		%ck1 = ((P.ck1lin*CAMK.^P.ckn)./(P.ckh.^P.ckn + CAMK.^P.ckn)).*CaCAM;
		ck1 = P.ck1lin.*CaCAM;
		%fca = (P.smax)./(1+(CAMK./(P.kinh)).^P.ninh);
		%P.smin = 0;

		%fca = P.smin + (P.smax-P.smin)./(1+(CAMK./(P.kinh)).^P.ninh);
		fca = (P.smax)./(1+(CAMK./(P.kinh)).^P.ninh);
		synth = aG.*fca;
		inhcng = 1+(P.inhmax-1).*CaCAM.^P.ninhcng./(CaCAM.^P.ninhcng + P.kinhcng.^P.ninhcng);	
		Icng = (P.cnmax.*cAMP.^P.n1./(cAMP.^P.n1 + (inhcng.*P.hmc1).^P.n1)).*(P.vcng-V);		
		Icacl = ((P.clmax.*Ca.^P.n2)./(Ca.^P.n2 + P.hmc2.^P.n2)).*(P.vcl-V);
		Il = P.gl.*(P.vl-V);

        hv = @(x) 1./(1+exp(-x./0.001));
        Ostim = sum(PULSE.conc.*(hv(t-PULSE.ton)- hv(t-PULSE.toff)),2);

		%#####ODOR STIMLUATION & LIGAND-RECEPTOR INTERACTION#####
		D_bLR = P.k1*Ostim.*(P.Rtot-bLR) - P.r1.*bLR;
		D_aG = k2.*(P.Gtot-aG) - P.r2.*aG;
		%#####TRANSDUCTION####################
		D_cAMP = synth - P.pd.*cAMP;
		%D_Ca = P.inf.*Icng - (P.vncx-V).*(P.ef./(1 + (IX./P.kI).^P.nck2)).*Ca + 4*(-cc1 + P.cc2.*CaCAM);

		D_Ca = P.inf.*Icng - (P.ef./(1 + (IX./P.kI).^P.nI)).*Ca + (-cc1 + P.cc2.*CaCAM);
		D_CaCAM = cc1 - P.cc2.*CaCAM;
		D_CAMK = ck1 - P.ck2.*CAMK;
		D_IX = cx1 - P.cx2.*IX;  %This has got to go back down in order for oscillations...
		D_V = (1./P.cap).*(Icng + Icacl + Il);
        
        % ML Spike
        
        
        %
        
		dy = [D_bLR;D_aG;D_cAMP;D_Ca;D_CaCAM;D_CAMK;D_IX;D_V];
    end
end