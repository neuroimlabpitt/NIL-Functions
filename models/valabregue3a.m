
clear all

opt1min=optimset('fminbnd');
dtol=1e-10;
dynamic_model_flag=1;
RK_flag=1;
BOLD_flag=1;
plots_flag=1;

L=400e-4;	% units: cm
dx=L/100;
x=[0:dx:L];	% units: cm

alpha=1.39e-3;	% units: mmol/L/mmHg
P50=26;		% units: mmHg
hill=2.73;
cHb=2.3;	% units: mmol/L
PO=4;

F0=50;		% units: ml/min

% calculate the initial condition first from the steady state solution
%   assume CMRO2 is given (units: mmol/min)
%     we can solve for either Ct, Cp (mmol/ml) or PS (ml/min)
%     PS has been reported around to be around 3000 to 7000 ml/min!
%     but this is likely dependent on the choice of L!
      PS=8000;
%   assume Cp_bar is known
%

%CMRO20=2.7938;
%Cp_bar=0.0065;
%PS=CMRO20/(Cp_bar-Ct);

Pa=90;		% units: mmHg
Pt=20;		% units: mmHg
Cpa=Pa*alpha;
Ca=Cpa+(cHb*PO)/(1+((P50/Pa)^hill));
Ct=Pt*alpha;

Hparms = [cHb PO alpha P50 hill];
Cc = fminbnd(@H_inv,1e-8,Ca,opt1min,Ca,Ct,PS,F0,Hparms);
CMRO20 = PS*( H_inv(Cc,Hparms) - Ct );
E = 2*(1-Cc/Ca);

% now we have a steady-state calculation that can be used as initial
% condition, let's try to calculate the dynamic model

if (dynamic_model_flag),

T=2.0;		% units: min
dt=1/(60*10);	% units: min (0.5 sec resolution)
t=[0:dt:T];

Vc=1;		% units: ml
Vt=96;		% units: ml

F=ones(size(t))*F0;
famp=0.64; fstart=9.7/60; fdur=4.5/60; framp=8/60;
F=F0*(1+famp*mytrapezoid(t,fstart,fdur,framp));
CMRO2=ones(size(t))*CMRO20;
camp=0.12; cstart=2.2/60; cdur=12/60; cramp=.5/60;
CMRO2=CMRO20*(1+camp*mytrapezoid(t,cstart,cdur,cramp));


CCc(1)=Cc;
CCt(1)=Ct;
EE(1)=E;
for mm=2:length(t),

  CCt(mm) = CCt(mm-1) + (dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - CCt(mm-1)) - CMRO2(mm-1) );

  if (RK_flag),
    %CMRO2a(mm-1)=CMRO20;
    %CMRO2b(mm-1)=CMRO20;
    %CMRO2c(mm-1)=CMRO20;
    CMRO2a(mm-1)=CMRO20*(1+camp*mytrapezoid(t(mm-1),cstart,cdur,cramp));
    CMRO2b(mm-1)=CMRO20*(1+camp*mytrapezoid(t(mm-1)+dt/2,cstart,cdur,cramp));
    CMRO2c(mm-1)=CMRO20*(1+camp*mytrapezoid(t(mm-1)+dt,cstart,cdur,cramp));
    Ctk1=(dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - CCt(mm-1)) - CMRO2a(mm-1) );
    Ctk2=(dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - (CCt(mm-1)+Ctk1/2) ) - CMRO2b(mm-1) );
    Ctk3=(dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - (CCt(mm-1)+Ctk2/2) ) - CMRO2b(mm-1) );
    Ctk4=(dt/Vt)*( PS*( H_inv(CCc(mm-1),Hparms) - (CCt(mm-1)+Ctk3) ) - CMRO2c(mm-1) );

    CCt(mm) = CCt(mm-1) + Ctk1/6 + Ctk2/3 + Ctk3/3 + Ctk4/6;
  end;

  A =  F(mm-1)*2*( Ca - CCc(mm-1) );
  B =  PS*( H_inv(CCc(mm-1),Hparms) - CCt(mm-1) );
  CCc(mm) = CCc(mm-1) + (dt/Vc)*( A - B );

  if (RK_flag),
    Fa(mm-1)=F0*(1+famp*mytrapezoid(t(mm-1),fstart,fdur,framp));
    Fb(mm-1)=F0*(1+famp*mytrapezoid(t(mm-1)+dt/2,fstart,fdur,framp));
    Fc(mm-1)=F0*(1+famp*mytrapezoid(t(mm-1)+dt,fstart,fdur,framp));
    Cck1=(dt/Vc)*( Fa(mm-1)*2*(Ca-CCc(mm-1)) - PS*(H_inv(CCc(mm-1),Hparms)-CCt(mm-1)) );
    Cck2=(dt/Vc)*( Fb(mm-1)*2*(Ca-(CCc(mm-1)+Cck1/2)) - PS*(H_inv(CCc(mm-1)+Cck1/2,Hparms)-CCt(mm-1)) );
    Cck3=(dt/Vc)*( Fb(mm-1)*2*(Ca-(CCc(mm-1)+Cck2/2)) - PS*(H_inv(CCc(mm-1)+Cck2/2,Hparms)-CCt(mm-1)) );
    Cck4=(dt/Vc)*( Fc(mm-1)*2*(Ca-(CCc(mm-1)+Cck3)) - PS*(H_inv(CCc(mm-1)+Cck3,Hparms)-CCt(mm-1)) );
    CCc(mm) = CCc(mm-1) + Cck1/6 + Cck2/3 + Cck2/3 + Cck4/6;
  end;

  EE(mm) = 2*( 1 - CCc(mm)/Ca );

end;

end;

[EEa,CMRO2a]=valabregue3ff(F0*[1 1+famp],PS,Pt,Pa);
[EEb,CMRO2b]=valabregue3ff(F,PS,Pt,Pa);


if (BOLD_flag),
  F1=F/F(1);
  vtau=8/60; vtau2=30/60;
  V1(1)=0; V1b(1)=0; for mm=2:length(t), V1(mm)=V1(mm-1)+(dt/vtau)*((F1(mm-1)-1)-V1(mm-1)); V1b(mm)=V1b(mm-1)+(dt/(vtau2))*((F1(mm-1)-1)-V1b(mm-1)); end;
  if (famp==0.0),
    V1= 1*V1 + 1;
  else,
    V1= 1.0*((((famp+1)^0.4)-1)/famp)*V1 + 0.0*V1b + 1;
  end;
  [B1,F1o,Q1]=simpleBOLD(F1,V1,EE,[dt 0.20 1/60 Ca F0 1]);
end;

if (plots_flag),
  figure(1)
  subplot(211)
  plot(t*60,F,'b-')
  ylabel('CBF')
  axis('tight'), grid('on'),
  %ax=axis; axis([0 118 ax(3:4)]);
  dofontsize(15), fatlines,
  subplot(212)
  plot(t*60,CMRO2,'b-',t*60,CMRO2b,'g-')
  ylabel('rCMRO2')
  axis('tight'), grid('on'),
  xlabel('Time')
  %ax=axis; axis([0 118 ax(3:4)]);
  dofontsize(15), fatlines,
  legend('Dynamic','Steady')
  figure(2)
  subplot(211)
  plot(t*60,EE,'b-',t*60,EEb,'g-')
  ylabel('E')
  xlabel('Time')
  axis('tight'), grid('on'),
  %ax=axis; axis([0 118 ax(3:4)]);
  dofontsize(15), fatlines,
  legend('Dynamic','Steady',4)
  subplot(212)
  plot(t*60,B1,'b-')
  ylabel('BOLD')
  axis('tight'), grid('on'),
  %ax=axis; axis([0 118 ax(3:4)]);
  xlabel('Time')
  dofontsize(15), fatlines,
end;

