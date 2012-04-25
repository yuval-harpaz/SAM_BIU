function orig=tlrc2orig(tlrc,warpedFile)
% takes talairach coordinates from a text file in LPI order and transform
% them to orig PRI order.
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
% LPI to RAI
tlrc(:,1)=(-1).*tlrc(:,1);
tlrc(:,2)=(-1).*tlrc(:,2);
% write to temp text file
TLRC=num2str(tlrc(1,:));
eval(['!echo ',TLRC,' > ~/Desktop/tlrcRAI.coord'])
if size(tlrc,1)>1
    for rowi=2:size(tlrc,1)
        TLRC=num2str(tlrc(rowi,:));
        eval(['!echo ',TLRC,' >> ~/Desktop/tlrcRAI.coord'])
    end
end
% transforming in RAI order
! ~/abin/Vecwarp -input ~/Desktop/tlrcRAI.coord -force -output ~/Desktop/origRAI.coord -apar warped+tlrc -backward
orig=importdata('~/Desktop/origRAI.coord');
% RAI to PRI
x=(-1)*orig(:,2);
orig(:,2)=orig(:,1);
orig(:,1)=x;
% cleanup
if size(orig,2)==3
    !rm ~/Desktop/tlrcRAI.coord ~/Desktop/origRAI.coord
else
    warning('something went wrong? check the ~/Desktop/*.coord files for clues')
end
end