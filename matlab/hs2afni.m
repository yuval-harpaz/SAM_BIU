function hs2afni(voxSize,mri) %(source)
% creates an AFNI file with the digitization points
% 'small' voxSize creates a hs+orig file with small digitization
% points
% 'big' voxSize (default) creates HS+orig file with 5x5x5mm cubes around the points
%requires hs_file and ortho+orig or warped+orig
% mri, file name instead of ortho/warped
if ~exist('voxSize','var')
    voxSize='big';
end
if ~exist('~/abin','dir')
    if exist('/home/megadmin/abin','dir')
        hs2afni_megadmin(voxSize)
        return
    end
    error('could not find AFNI folder')
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
    !rm hds+orig*
end
if exist('HS+orig.BRIK','file')
    !rm HS+orig*
end
if exist('mri','var')
    eval(['!~/abin/3dUndump -orient PRI -xyz -dval 1 -master ',mri,' -prefix hds hsTxt']);
else
    if exist ('ortho+orig.BRIK','file');
        !~/abin/3dUndump -orient PRI -xyz -dval 1 -master ortho+orig -prefix hds hsTxt
    elseif exist ('warped+orig.BRIK','file');
        !~/abin/3dUndump -orient PRI -xyz -dval 1 -master warped+orig -prefix hds hsTxt
    else
        display('cannot find ortho or warped+orig file')
        return
    end
end
if strcmp(voxSize,'small')
    return
end
!~/abin/3dresample -dxyz 5 5 5 -prefix hsT -inset hds+orig -rmode Cu
!~/abin/3dfractionize -template hsT+orig -input hds+orig -prefix HS
!rm hds+orig*
!rm hsT+orig*

%!~/abin/afni -dset ortho+orig
end
