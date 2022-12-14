function yprime=bold1(t,y,g1,g2,g3,g4,g5,g6,g7,g8)
% BOLD model as described by Buxton, et al. in his
% SMR97 abstract (#743). The model assumes BOLD is due
% to venous blood changes with intra- and extra-vascular
% components.

% Signal change depends on the total deoxyhemoglobin in
% tissue, q(t), and the total venous volume, v(t).
% Venous compartment is modeled as expandable (balloon)
% where the input is the capillary bed (F is flow in/out).

to=2;	% transit time = 2 secs
Eo=0.4;	% exchange initial condition is 0.4

if (t==0),	% Other initial conditions
  % q(0)=1;
  % v(0)=1;
  Fin=0;
  Fout=0;
  E=Eo;
else,
  %Fin=g2;
  tmp=0.5*mflowmod(g1,g2,g3,g4,g5);
  Fin=1+nus_fval(t,g1,tmp);
  %Fout=4*y(2)-3;	% Linear
  Fout=(g7/100)*(10.^((y(2)-1)./g8)-1)+1+g6*y(2);	% Linear+Exponential
  %Fout=hister1(y(2),tau,amplitude,vmax,in_out);	% Nonlinear
  E=1-(1-Eo)^(1/Fin);
end;

yprime(1)=(1/to)*(Fin*E/Eo - Fout*y(1)/y(2));
yprime(2)=(1/to)*(Fin - Fout);

