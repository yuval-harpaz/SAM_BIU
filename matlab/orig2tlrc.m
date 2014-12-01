function tlrc=orig2tlrc(orig,warpedFile)
% takes PRI cm (4D MEG) coordinates them to tlrc coordinates in mm and LPI order.
% give it the path to warped or ortho+tlrc file (no need for suffix)
if ~exist('warpedFile','var')
    if exist('ortho+tlrc.BRIK','file')
        warpedFile='ortho+tlrc';
    elseif exist('warped+tlrc.BRIK','file')
        warpedFile='warped+tlrc';
    else
        error('no warped tlrc file found or specified')
    end
end
% PRI to RAI
orig=orig.*10;
orig(:,1)=(-1).*orig(:,1);
orig=orig(:,[2 1 3]);
% write to temp text file
TLRC=num2str(orig(1,:));
eval(['!echo ',TLRC,' > ~/Desktop/origRAI.coord'])
if size(orig,1)>1
    for rowi=2:size(orig,1)
        TLRC=num2str(orig(rowi,:));
        eval(['!echo ',TLRC,' >> ~/Desktop/origRAI.coord'])
    end
end
% transforming in RAI order
! ~/abin/Vecwarp -input ~/Desktop/origRAI.coord -force -output ~/Desktop/tlrcRAI.coord -apar warped+tlrc
tlrc=importdata('~/Desktop/tlrcRAI.coord');
% RAI to LPI
%x=(-1)*tlrc(:,2);
tlrc(:,2)=(-1).*tlrc(:,2);
tlrc(:,1)=(-1).*tlrc(:,1);
% cleanup
if size(tlrc,2)==3
    !rm ~/Desktop/tlrcRAI.coord ~/Desktop/origRAI.coord
else
    warning('something went wrong? check the ~/Desktop/*.coord files for clues')
end
end