function maskStat(tlrcFile)
%can mask out out of the head voxels in statistical results or other
%functional data after transfer to oue talairach template.
% statFile='something+tlrc';
if exist ('tempStat+tlrc.BRIK','file')
    error ('tempStat+tlrc* exists, remove and rerun')
end
copyfile([tlrcFile,'.BRIK'],'tempStat+tlrc.BRIK');
copyfile([tlrcFile,'.HEAD'],'tempStat+tlrc.HEAD');
if exist('~/abin','dir')
    !~/abin/3dcalc -a ~/SAM_BIU/docs/MASK+tlrc -b tempStat+tlrc -expr 'a*b' -prefix masked
elseif exist ('/home/megadmin/abin','dir')
    !/home/megadmin/abin/3dcalc -a ~/SAM_BIU/docs/MASK+tlrc -b tempStat+tlrc -expr 'a*b' -prefix masked
else
    display ('could not find abin directory at ~/ or at /home/megadmin/')
    !rm tempStat+tlrc.BRIK tempStat+tlrc.HEAD
    return
end
if exist ('masked+tlrc.BRIK','file') && exist ('masked+tlrc.HEAD','file')
    eval(['!rm ',tlrcFile,'.BRIK'])
    eval(['!rm ',tlrcFile,'.HEAD'])
    eval(['!mv masked+tlrc.BRIK ',tlrcFile,'.BRIK'])
    eval(['!mv masked+tlrc.HEAD ',tlrcFile,'.HEAD'])
    display(' removing masked+tlrc, overwriting original file')
    !rm tempStat+tlrc.BRIK tempStat+tlrc.HEAD
end
end