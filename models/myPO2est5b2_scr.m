


clear all
load KazuNPLPdata


dii=[[1:50] [351:401]]';
PO2hh=exp(-(PO2t-PO2t(1))/0.5);
PO2filt=zeros(size(PO2t)); PO2filt([[1:51] [352:401]])=1;


CBFt=LDFt;
CBFi=mean(LDFnp')';
CBFi_base=mean(CBFi(1:50));
CBFib=polyval(polyfit(dii,CBFi(dii),1),[1:length(CBFi)]');
CBFi=CBFi-CBFib+mean(CBFib);
CBFi=CBFi/mean(CBFi(10:40));

CBF2i=mean(LDFlp')';
CBF2i_base=mean(CBF2i(1:50));
CBF2ib=polyval(polyfit(dii,CBF2i(dii),1),[1:length(CBF2i)]');
CBF2i=CBF2i-CBF2ib+mean(CBF2ib);
CBF2i=CBF2i/mean(CBF2i(10:40));

CBFff=mean(LDFlp_base./LDFnp_base);

PO2d=mean(PO2np')';
PO2d_base=mean(PO2d(1:50));
PO2d=PO2d/PO2d_base;
PO2d=(fdeconv(PO2d-1,PO2hh,PO2filt)+1)*PO2d_base;
PO2db=polyval(polyfit(dii,PO2d(dii),1),[1:length(PO2d)]');
PO2d=PO2d-PO2db+PO2d_base;
PO2d=PO2d/PO2d_base;

PO2d2=mean(PO2lp')';
PO2d2_base=mean(PO2d2(1:50));
PO2d2=PO2d2/PO2d2_base;
PO2d2=(fdeconv(PO2d2-1,PO2hh,PO2filt)+1)*PO2d2_base;
PO2d2b=polyval(polyfit(dii,PO2d2(dii),1),[1:length(PO2d2)]');
PO2d2=PO2d2-PO2d2b+PO2d2_base;
PO2d2=PO2d2/PO2d2_base;

%PO2d2=(PO2d2-1)*0.8+1;


FPenv=getFPenv(mean(FPnp'),FPt,6,10,1,CBFt);
FP2env=getFPenv(mean(FPlp'),FPt,6,10,1,CBFt);

fpf=1/mean(FPenv(76:100));
fp2f=1/mean(FP2env(76:100));


tparms=[0.05 CBFt(end)-CBFt(1)]/60;
tparms(3)=1;    % neglect plasma
tparms(4)=0;    % rk flag


xopt=optimset('lsqnonlin');
xopt.TolFun=1e-10;
xopt.TolX=1e-8;
%xopt.MaxIter=1000;
xopt.Display='iter';



alpha_o2=1.39e-3;
hill=2.73;


F0=147*CBFff;
Vv0=2;
Vvk1=12/60;
dCMRO2=0.20;
P50=38;
cHb=mean(cHblp);
Vc=1.0;
Vct=98.0;
PS=7000;
Pa=0.6*mean(PaO2lp);
Pt=mean(PO2lp_base);
bbeta=0.000;
fp2cmro2f=fp2f;
Caamp=0.00;


%    [F0 V0 Vk1 camp-1 P50 Vc Vct   PS    Pa  Pt  beta]
sparms=[F0 Vv0 Vvk1 dCMRO2 P50 cHb Vc Vct PS  Pa Pt bbeta fp2cmro2f Caamp];
slb=[30  1  1/60  +0.05 20 1.5 0.01 97.9  2000 80   0 0.00000 0.0 -0.5];
sub=[25  100 40/60 +0.60 40 3.5 100.00 998.1  20000 300 70 10.00001 1e6 +1.0];


% we are going to allow values over 1 after 5s
ttt=[0:tparms(1)*10:tparms(2)]';
tss=((ttt<7/60)|(ttt>=65/60));
ifix=find(tss');
iunfix=find(~tss');
xramp=[1 10];
xfix=+1.0*mytrapezoid3(ttt*60,10+xramp(1),11.0-xramp(1),xramp);


dofit=1;
%parms2fit=[length(sparms)+[1:length(iunfix)]];
sparms_orig=sparms;
sparms=[sparms_orig xfix(iunfix)'];
sub=[sub xfix(iunfix)'+1.0];
slb=[slb xfix(iunfix)'-1.0];



parms2fit=[];
parms2fit=[parms2fit length(sparms_orig)+[1:length(iunfix)]];


if (dofit),
  [CCt_0,CCc_0,CMRO2t_0,t,CCat_0]=myPO2est5b2(sparms(parms2fit),tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBF2i(:) FP2env(:)]);
  [xx,xresn,xres,xexflag,xout,xlam,xjac]=lsqnonlin(@myPO2est5b2,sparms(parms2fit),slb(parms2fit),sub(parms2fit),xopt,tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBF2i(:) FP2env(:) PO2d2(:)*PO2d2_base]);
  [CCt,CCc,CMRO2t,t,CCa]=myPO2est5b2(xx,tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBF2i(:) FP2env(:)]);
else,
  [CCt,CCc,CMRO2t,t,CCa]=myPO2est5b2(sparms(parms2fit),tparms,sparms,parms2fit,iunfix,[ifix;xfix(ifix)']',ttt,(CBFt-CBFt(1))/60,[CBF2i(:) FP2env(:)]);
end;


PO2di=interp1(CBFt,PO2d*PO2d_base,t*60+CBFt(1));
PO2d2i=interp1(CBFt,(PO2d2-1)*PO2d2_base,t*60+CBFt(1));

Pa_max=150;
Cp_curve=[1:1e5]*(Pa_max/1e5)*alpha_o2;
Ctot_curve=Cp_curve+(4*cHb)*(1./(1+((alpha_o2*P50./Cp_curve).^hill)));

Pat=interp1(Ctot_curve,Cp_curve,CCa)/alpha_o2;




save myPO2res5b2


figure(1)
subplot(411)
plot(t*60+CBFt(1),Pat,'g')
ylabel('P_a')
axis('tight'), grid('on'), fatlines;
subplot(412)
plot(CBFt,CBF2i,'b')
ylabel('CBF'),
axis('tight'), grid('on'), fatlines;
subplot(413)
plot(PO2t,PO2d2*PO2d2_base,'b',t*60+CBFt(1),CCt/alpha_o2,'g')
ylabel('P_{tO2}'),
axis('tight'), grid('on'), fatlines;
subplot(414)
plot(t*60+CBFt(1),CMRO2t*0.0224,'g')
ylabel('CMR_{O2}'),
axis('tight'), grid('on'), fatlines;

