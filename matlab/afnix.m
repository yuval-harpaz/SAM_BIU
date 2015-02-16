function [s,w]=afnix(afniCommand,errStop)
% for afni permutations, prevents loop breakdown due to too long afni.log
% file. you can specify errStop=true if you want to stop if error.
if ~exist('errStop','var')
    errStop=false;
end
[s,w]=unix(afniCommand);
longLog=strfind(w,'.afni.log is now');
if ~isempty(longLog)
    pathToLogI=strfind(w,'++ WARNING: file ')+17;
    pathToLog=w(pathToLogI:longLog+8);
    [~,~]=unix(['echo " " > ',pathToLog]);
    [s,w]=unix(afniCommand);
end
err=strfind(w,'ERROR');
if ~isempty(err)
    fprintf(2,w);
    warning(' ');
    if errStop
        dbstop in afnix at 22
    end
end