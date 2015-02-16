function [s,w]=afnix(afniCommand)
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
    error(w)
end