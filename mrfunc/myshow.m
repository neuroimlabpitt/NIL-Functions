function out = myshow(a,level,windfact)
% usage .. show(a,level,f);
% displays matrix "a" as a greyscale image in the matlab window
% and "f" is the optional window factors [min,max]

if exist('windfact') == 0, 
  amin = min(a(:));
  amax = max(a(:));
  minmax = [amin,amax];
  a = (a  - amin);
else
  amin = windfact(1);
  amax = windfact(2);
  a = (a  - amin);
  a = a .* (a > 0);
end

adim=size(a);
if length(adim)==3,
    tmpim=zeros(adim(1),adim(2),3);
    if adim(3)>=3, a3=3; else, a3=adim(3); end;
    tmpim=a(:,:,1:a3);
end;

image(((a)./(amax-amin).*level)');
axis('image');
axis('on');
grid on;
if length(adim)==2, colormap(gray); end;

if nargout==0,
  disp(['min/max= ',num2str(minmax(1)),' / ',num2str(minmax(2))]);
end;