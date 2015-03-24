function afni
if exist('ortho+orig.BRIK','file') || exist('ortho+tlrc.BRIK','file') || exist('anat+orig.BRIK','file') || exist('anat+tlrc.BRIK','file') || exist('warped+orig.BRIK','file') || exist('warped+tlrc.BRIK','file')
    dset='';
else
    disp('is there anatomy here? openning template')
    dset='-dset ~/SAM_BIU/docs/temp+tlrc';
end
unix(['afni ',dset,' &']);