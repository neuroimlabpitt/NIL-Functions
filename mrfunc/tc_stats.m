function f=tc_stats(x,stat_range1,stat_range2,t)
% Usage ... f=tc_stats(x,stat_range1,stat_range2,t)
%
% This function calculates some of a time series x
% statistics relevant to fMRI. The order of the
% statistics are:
%  (1-2) [mean of stat_range1 mean of stat_range2]
%  (3-4) [std  of stat_range1 std  of stat_range2]
%  (5-6) [z-stat of range1/range2 z-stat of range2/range1]
%  (7-8) [max of range1 index of range1]
%  (9-10) [max of range2  index of range2]
%  (11-12) [min of range1 index of range1]
%  (13-14) [min of range2 index of range2]
%  (15-16) [fwhm of range1 fwhm of range2]
%  (17-18) interpolated version of (15-16)

if nargin<=3,
  t=[1:length(x)];
end;

ts=t(2)-t(1);

range1=x(stat_range1(1):stat_range1(2));
range2=x(stat_range2(1):stat_range2(2));

f(1)=mean(range1);
f(2)=mean(range2);
f(3)=std(range1);
f(4)=std(range2);
f(5)=(f(2)-f(1))/f(3);
f(6)=(f(1)-f(2))/f(4);
[tmp_max1,tmp_maxi1]=max(range1);
[tmp_max2,tmp_maxi2]=max(range2);
[tmp_min1,tmp_mini1]=min(range1);
[tmp_min2,tmp_mini2]=min(range2);
f(7)=tmp_max1;
f(8)=ts*(tmp_maxi1+stat_range1(1)-1);
f(9)=tmp_max2;
f(10)=ts*(tmp_maxi2+stat_range2(1)-1);
f(11)=tmp_min1;
f(12)=ts*(tmp_mini1+stat_range1(1)-1);
f(13)=tmp_min2;
f(14)=ts*(tmp_mini2+stat_range2(1)-1);

for m=length(range1):-1:tmp_maxi1,
  if range1(m)>0.5*f(7),
    farsidei=m;
    break;
  else,
    farsidei=m;
  end;
end;
for m=1:tmp_maxi1,
  if range1(m)>=0.5*f(7),
   nearsidei=m;
   break;
  else,
   nearsidei=1;
  end;
end;

if (nearsidei<=1),
  disp('Warning: Changing nearside index (1)');
  nearsidei=nearsidei+1;
end;
if (farsidei<=1),
  disp('Warning: Changing farside index (1)');
  farsidei=farsidei+1;
end;

%tmpm1=(range1(nearsidei)-range1(nearsidei-1))/ts;
%tmpm2=(range1(farsidei)-range1(farsidei+1))/ts;
%tmpb1=range1(nearsidei)-tmpm1*(ts*(stat_range1(1)+nearsidei-1));
%tmpb2=range1(farsidei)-tmpm2*(ts*(stat_range1(1)+farsidei));
%tmpl1=(0.5*f(7)-tmpb1)/tmpm1;
%tmpl2=(0.5*f(7)-tmpb2)/tmpm2;
tmpm1=range1(nearsidei)-range1(nearsidei-1);
tmpm1=(range1(nearsidei)-0.5*f(7))/tmpm1;
tmpl1=nearsidei-ts*tmpm1;
tmpm2=range1(farsidei)-range1(farsidei+1);
tmpm2=(range1(farsidei)-0.5*f(7))/tmpm2;
tmpl2=farsidei+ts*tmpm2;
f(15)=(farsidei-nearsidei)*ts;
f(17)=(tmpl2-tmpl1);

for m=length(range2):-1:tmp_maxi2,
  if range2(m)>0.5*f(9),
    farsidei=m;
    break;
  else,
    farsidei=m;
  end;
end;
for m=1:tmp_maxi2,
  if range2(m)>=0.5*f(9),
   nearsidei=m;
   break;
  else,
   nearsidei=m;
  end;
end;

if (nearsidei<=1),
  disp('Warning: Changing nearside index (2)');
  nearsidei=nearsidei+1;
end;
if (farsidei<=1),
  disp('Warning: Changing farside index (2)');
  farsidei=farsidei+1;
end;

%tmpm1=(range2(nearsidei)-range2(nearsidei-1))/ts;
%tmpm2=(range2(farsidei)-range2(farsidei+1))/ts;
%tmpb1=range2(nearsidei)-tmpm1*(ts*(stat_range2(1)+nearsidei-1));
%tmpb2=range2(farsidei)-tmpm2*(ts*(stat_range2(1)+farsidei));
%tmpl1=(0.5*f(9)-tmpb1)/tmpm1;
%tmpl2=(0.5*f(9)-tmpb2)/tmpm2;
tmpm1=range2(nearsidei)-range2(nearsidei-1);
tmpm1=(range2(nearsidei)-0.5*f(9))/tmpm1;
tmpl1=nearsidei-ts*tmpm1;
tmpm2=range2(farsidei)-range2(farsidei+1);
tmpm2=(range2(farsidei)-0.5*f(9))/tmpm2;
tmpl2=farsidei+ts*tmpm2;
f(16)=(farsidei-nearsidei)*ts;
f(18)=(tmpl2-tmpl1);


ti=[t(1):0.01*ts:t(length(t))];
xi=interp1(t,x,ti,'spline');
[tmpi1,tmpi2]=max(xi);
[tmpi3,tmpi4]=min(xi);
f(19)=ti(tmpi2);
f(20)=ti(tmpi4);
tmpi21=find(xi>(0.1*f(9)));
f(21)=ti(tmpi21(1));

f=f(:);

if nargout==0,
  plot(t,x,'-',ti,xi,'--',ti(tmpi2),tmpi1,'x',ti(tmpi4),tmpi3,'o')
  [tmpi2 tmpi4],
end;

