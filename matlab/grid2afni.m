function grid2afni(grid,mri) %(source)
% creates an AFNI file with the digitization points
% 'small' voxSize creates a grid+orig file with small digitization
% points
% 'big' voxSize (default) creates GRID+orig file with 5x5x5mm cubes around the points
%requires  ortho+orig or warped+orig mri, file name instead of ortho/warped

    voxSize='big';


pnt=grid.pos*1000;
PNT=reshape(pnt',size(pnt,1)*3,1);
if exist('gridTxt','file')
    !rm gridTxt
end
txtFileName = 'gridTxt';
fid = fopen(txtFileName, 'w');
fprintf(fid,'%f\t%f\t%f\n',PNT);
fclose(fid);
if exist('grid+orig.BRIK','file')
    !rm hds+orig*
end
if exist('GRID+orig.BRIK','file')
    !rm GRID+orig*
end
if exist('mri','var')
    eval(['!~/abin/3dUndump -orient PRI -xyz -dval 1 -master ',mri,' -prefix grid gridTxt']);
else
    if exist ('ortho+orig.BRIK','file');
        !~/abin/3dUndump -orient PRI -xyz -dval 1 -master ortho+orig -prefix grid gridTxt
    elseif exist ('warped+orig.BRIK','file');
        !~/abin/3dUndump -orient PRI -xyz -dval 1 -master warped+orig -prefix grid gridTxt
    else
        display('cannot find ortho or warped+orig file')
        return
    end
end

!~/abin/3dresample -dxyz 3 3 3 -prefix gridT -inset grid+orig -rmode Cu
!~/abin/3dfractionize -template gridT+orig -input grid+orig -prefix GRID
!rm grid+orig*
!rm gridT+orig*

%!~/abin/afni -dset ortho+orig
end
