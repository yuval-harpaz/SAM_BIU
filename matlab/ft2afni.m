function ft2afni(pos,color,prefix) %(source)
% creates an AFNI file with the digitization points
% 'small' voxSize creates a grid+orig file with small digitization
% points
% 'big' voxSize (default) creates GRID+orig file with 5x5x5mm cubes around the points
%requires  ortho+orig or warped+orig mri, file name instead of ortho/warped
xyzMin=[min(pos(:,1)) min(pos(:,2)) min(pos(:,3))];
%xyzMin=cfg.boxSize([1 3 5]);
%xyzMax=cfg.boxSize([2 4 6]);
xyzMax=[max(pos(:,1)) max(pos(:,2)) max(pos(:,3))];
dif=diff(pos(:,1));
dif=dif(dif~=0);
stepx=abs(median(dif));
dif=diff(pos(:,2));
dif=dif(dif~=0);
stepy=abs(median(dif));
dif=diff(pos(:,3));
dif=dif(dif~=0);
stepz=abs(median(dif));
xsize=length(xyzMin(1):stepx:xyzMax(1));
ysize=length(xyzMin(2):stepy:xyzMax(2));
zsize=length(xyzMin(3):stepz:xyzMax(3));
% here I create a functional template from scratch
if exist ('./temp+orig.BRIK','file')
    !rm temp+orig*
end
xyzstr=[num2str(xsize),' ',num2str(ysize),' ',num2str(zsize)];
[~,w]=unix(['~/abin/3dUndump -dimen ',xyzstr,' -prefix temp'])
origins=abs(xyzMin);
[~,w]=unix(['~/abin/3drefit -orient LPI -space MNI -view tlrc -xdel ',num2str(stepx),' -ydel ',num2str(stepy),' -zdel ',num2str(stepz),' temp+orig'])
%[~,w]=unix(['~/abin/3drefit -xorigin ',num2str(origins(1)),' -yorigin ',num2str(origins(2)),' -zorigin ',num2str(origins(3)),' temp+tlrc'])
[~,w]=unix('3dcalc -prefix tempF -a temp+tlrc -exp "a" -datum float')
[V,Info]=BrikLoad('tempF+tlrc');
%OptTSOut.Scale = 1;
OptTSOut.Prefix = prefix;
OptTSOut.verbose = 1;
OptTSOut.view='tlrc';
Info.ORIGIN(1:3)=abs(xyzMin);
Info.ORIGIN(3)=-Info.ORIGIN(3);
%OptTSOut.Slices=tsize;
%if exist([cfg.prefix,'+orig.BRIK'],'file')
%    eval(['!rm ',cfg.prefix,'+orig*'])
%end
%write it
color(isnan(color))=0;
WriteBrik (color, Info, OptTSOut);
!rm temp*+*