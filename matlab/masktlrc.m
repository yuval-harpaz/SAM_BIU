function masktlrc(tlrcFile,templateMask,suffix)
% this function can mask out out of the head voxels in statistical results or other
% functional data after transfer to talairach coordinates.
% tlrcFile='something+tlrc', the functional data. it has to be in tlrc space and with
% 5x5x5mm resolution.
% three template masks are available, 'MASK+tlrc' (inner skull, default),
% 'MASKbrain+tlrc', brain and 'MASKctx+tlrc' for the cortex.
% if you don't give a suffix it will overwrite the original file.
if ~exist('templateMask','var')
    templateMask=[];
end
if isempty(templateMask)
    templateMask='MASK+tlrc';
end
if strcmp(templateMask,'MASK+tlrc') || strcmp(templateMask,'MASKbrain+tlrc') || strcmp(templateMask,'MASKctx+tlrc')
    templateMask=['~/SAM_BIU/docs/',templateMask];
end
if ~exist('suffix','var')
    suffix='';
end
if exist ('tempStat+tlrc.BRIK','file')
    !rm tempStat+tlrc*
end
copyfile([tlrcFile,'.BRIK'],'tempStat+tlrc.BRIK');
copyfile([tlrcFile,'.HEAD'],'tempStat+tlrc.HEAD');
if exist('~/abin','dir')
    path23dcalc='~/abin/3dcalc';
elseif exist ('/home/megadmin/abin','dir')
    path23dcalc='/home/megadmin/abin/3dcalc';
else
    display ('could not find abin directory at ~/ or at /home/megadmin/')
    !rm tempStat+tlrc.BRIK tempStat+tlrc.HEAD
    return
end
eval(['!',path23dcalc,...
    ' -a ',templateMask,...
    ' -b tempStat+tlrc -expr ''',...
    'b*a''',' -datum float -prefix masked']);
if exist ('masked+tlrc.BRIK','file') && exist('masked+tlrc.HEAD','file')
    if isempty(suffix)
        display(' removing masked+tlrc, overwriting original file')
        eval(['!rm ',tlrcFile,'.BRIK'])
        eval(['!rm ',tlrcFile,'.HEAD'])
    end
    eval(['!mv masked+tlrc.BRIK ',tlrcFile(1:(end-5)),suffix,'+tlrc.BRIK'])
    eval(['!mv masked+tlrc.HEAD ',tlrcFile(1:(end-5)),suffix,'+tlrc.HEAD'])
    !rm tempStat+tlrc.BRIK tempStat+tlrc.HEAD
end
end
