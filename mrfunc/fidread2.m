function [f,qm,im,info1,info2,info3,info4,info5,ind]=fidread2(pfilename,seq,slc,frm,acqno)
% Usage ... [f,qm,im,info1,info2,info3,info4,info5]=fidread(pfilename,seq,slice,frame,acquisition)
%
%  Slice 1 Frame 0 is baseline (example, expect more)
%  Note: there is frame 0 but not slice 0!
%
%  For sf3d - slc is the phase encode of interest and frm
%  would be the spiral shot of interest (0 is the baseline).
%
%  nslices=info1(3);
%  nechoes=info1(4);
%  nexcitations=info1(5);
%  nframes=info1(6);
%  framesize=info1(9);
%  psize=info1(10);


HEADERSIZE=60464;
RDBRAWHEADEROFFSET=30;  % For version 4 use 30.
LOC1 = RDBRAWHEADEROFFSET + 34;
LOC2 = RDBRAWHEADEROFFSET + 70;
LOC3 = RDBRAWHEADEROFFSET + 186;
LOC4 = HEADERSIZE-844;
LOC5 =  RDBRAWHEADEROFFSET + 122;
%OPXRESLOC = 74;
%OPYRESLOC = 76;
%NFRAMESLOC = 46;
%NSLICES = 
%FRAMESIZELOC = 52;
%POINTSIZELOC = 54;

%if isstr(pfilename),
  if (isunix)
     fid=fopen(pfilename,'r','b');
  else
     fid=fopen(pfilename,'r');
  end;
  if (fid<3), disp(['Could not open file! ...']); end;
%else
%  fid=pfilename;
%end;


status=fseek(fid,LOC1,'bof');
if (status), disp(['Could not seek to file location 1! ...']); end;
info1=fread(fid,10,'int16');
status=fseek(fid,LOC2,'bof');
if (status), disp(['Could not seek to file location 2! ...']); end;
info2=fread(fid,6,'int16');  % 
% info 2 is 

status=fseek(fid,LOC3,'bof');
if (status), disp(['Could not seek to file location 3! ...']); end;
info3=fread(fid,20,'float32'); % was float
%info 3 is user 0 through user 19

status=fseek(fid,LOC4,'bof');
if (status), disp(['Could not seek to file location 4! ...']); end;
info4=fread(fid,3,'int32'); % was float
%info 4 is tr and 0? and te *1e-06 to get in seconds

status=fseek(fid,LOC5,'bof');
if (status), disp(['Could not seek to file location 4! ...']); end;
info5=fread(fid,2,'float32'); % was float
%info 5 is x offset and y offset ( from prescription)
% shift is info5/info2(6)*10 in cm 




if (nargin==1),

  f=info1;
  qm=info2;
  im=info3;
  info1 = info4;
  info2 = info5;

else,

  nslices=info1(3);
  nechoes=info1(4);
  nexcitations=info1(5);
  nframes=info1(6);
  framesize=info1(9);
  psize=info1(10);

  if (slc>(nslices+1)),
    error(['Invalid slice!']);
  end;

  if strcmp(seq,'sf9')
    % Redo slice position in file odds then evens
    if rem(slc,2) %odd slice
      slc=slc-floor(slc/2);
    else %even slice
      slc=ceil(nslices/(2*info3(5)))+slc/2;
    end;
    adj=floor(frm/(info3(6)*info3(11)));
    tmp_loc=(slc-1)*(info3(5)*info3(11)*info3(6)+info3(5));
    fidloc = HEADERSIZE + psize*2*framesize*( tmp_loc + frm );
    status=fseek(fid,fidloc,'bof');
    if (status), error(['Could not seek to file fid location! ...']); end;
    if (psize==4), str=['long']; else, str=['short']; end;
    ind=ftell(fid);
    out=fread(fid,2*framesize,str);
    for m=1:framesize,
      qm(m)=out(2*m-1);
      im(m)=out(2*m);
    end;
    qm=qm(:); im=im(:);
    f=sqrt(qm.*qm+im.*im);
  elseif strcmp(seq,'sf3d'),
    nleaves=info3(6);
    nzpe=info3(18);
    fidloc = HEADERSIZE + psize*2*framesize*( (nleaves*nzpe+1)*(acqno-1) + (slc-1)*nleaves + frm );
    status=fseek(fid,fidloc,'bof');
    if (status), error(['Could not seek to file fid location! ...']); end;
    if (psize==4), str=['long']; else, str=['short']; end;
    ind=ftell(fid);
    out=fread(fid,2*framesize,str);
    for m=1:framesize,
      qm(m)=out(2*m-1);
      im(m)=out(2*m);
    end;
    qm=qm(:); im=im(:);
    f=sqrt(qm.*qm+im.*im);    
%  else
%    slc=seq;
%    frm=slc;
%    acqno=frm;
%    fidloc = HEADERSIZE + psize*2*framesize*( tmp_loc + frm );
%    status=fseek(fid,fidloc,'bof');
%    if (status), error(['Could not seek to file fid location! ...']); end;
%    if (psize==4), str=['long']; else, str=['short']; end;
%    ind=ftell(fid);
%    out=fread(fid,2*framesize,str);
%    for m=1:framesize,
%      qm(m)=out(2*m-1);
%      im(m)=out(2*m);
%    end;
%    qm=qm(:); im=im(:);
%    f=sqrt(qm.*qm+im.*im);
  end;

end;

if isstr(pfilename),
  fclose(fid);
end;

if (nargout==0),
  if (nargin==1),
    info1
    info2
    info3
  else,
    subplot(2,1,1)
    plot([1:length(f)],f)
    subplot(2,1,2)
    plot([1:length(qm)],qm,[1:length(im)],im)
  end;
end;




