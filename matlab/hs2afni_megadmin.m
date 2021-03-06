function hs2afni(voxSize) %(source)
% creates an AFNI file with the digitization points
% 'small' voxSize creates a hs+orig file with small digitization
% points
% 'big' voxSize (default) creates HS+orig file with 5x5x5mm cubes around the points
%requires hs_file and ortho+orig or warped+orig
if ~exist('voxSize','var')
    voxSize='big';
end
% get headshape
hs = ft_read_headshape('hs_file');
%ft_plot_headshape(shape)

pnt=hs.pnt*1000;
PNT=reshape(pnt',size(pnt,1)*3,1);
if exist('hsTxt','file')
    !rm hsTxt
end
txtFileName = 'hsTxt';
fid = fopen(txtFileName, 'w');
fprintf(fid,'%s\t%s\t%s\n',PNT);
fclose(fid);
if exist('hs+orig.BRIK','file')
    !rm hs+orig*
end
if exist('HS+orig.BRIK','file')
    !rm HS+orig*
end
if exist ('ortho+orig.BRIK','file');
    !/home/megadmin/abin/3dUndump -orient PRI -xyz -dval 1 -master ortho+orig -prefix hs hsTxt
elseif exist ('warped+orig.BRIK','file');
    !/home/megadmin/abin/3dUndump -orient PRI -xyz -dval 1 -master warped+orig -prefix hs hsTxt
else
    display('cannot find ortho or warped+orig file')
    return
end
if strcmp(voxSize,'small')
    return
end
!/home/megadmin/abin/3dresample -dxyz 5 5 5 -prefix hsT -inset hs+orig -rmode Cu
!/home/megadmin/abin/3dfractionize -template hsT+orig -input hs+orig -prefix HS
!rm hs+orig*
!rm hsT+orig*

%!~/abin/afni -dset ortho+orig
end
