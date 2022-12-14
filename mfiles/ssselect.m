function [ae,be,ce,de] = ssselect(a,b,c,d,e,f,g)
%SSSELECT Extract subsystem from larger system.
%	[Ae,Be,Ce,De] = SSSELECT(A,B,C,D,INPUTS,OUTPUTS) returns the
%	state space subsystem with the specified inputs and outputs.  The
%	vectors INPUTS and OUTPUTS contain indexes into the system
%	inputs and outputs respectively.
%
%	[Ae,Be,Ce,De] =  SSSELECT(A,B,C,D,INPUTS,OUTPUTS,STATES) returns
%	the state space subsystem with the specified inputs, outputs,
%	and states.

%	Clay M. Thompson 6-26-90
%	Copyright (c) 1986-93 by the MathWorks, Inc.

error(nargchk(6,7,nargin));
error(abcdchk(a,b,c,d));

[nx,na] = size(a);

if (nargin==6)
  inputs=e; outputs=f; states=1:nx;
end
if (nargin==7)
  inputs=e; outputs=f; states=g;
end

% --- Extract system ---
if ~isempty(a), ae = a(states,states);  else ae=[]; end
if ~isempty(b), be = b(states,inputs);  else be=[]; end
if ~isempty(c), ce = c(outputs,states); else ce=[]; end
if ~isempty(d), de = d(outputs,inputs); else de=[]; end

