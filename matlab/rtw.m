function rtw(fileName)
% puts a *.rtw file in the current folder
if ~exist('fileName','var')
    fileName=dir('*,rf*');
    if isempty(fileName)
        error('could not find file, specify it as input argument, please')
    else
        fileName=fileName.name;
    end
end
[~,fold]=fileparts(pwd);
p=pdf4D(fileName);
config=get(p,'config');
unix_time=double(config.user_block_data{end}.timestamp);
dateN=unix_time/86400 + datenum(1970,1,1);
date = datestr(dateN);

time1=datenum(2010,8,15);
time2=datenum(2011,8,15);
time3=datenum(2012,8,15);
if dateN<time1
    error('too early')
elseif dateN>time1 && dateN<time2    
    copyfile('~/SAM_BIU/docs/SuDi0810.rtw',[fold,'.rtw'])
elseif dateN>time2 && dateN<time3
    copyfile('~/SAM_BIU/docs/SuDi0811.rtw',[fold,'.rtw'])
elseif dateN>time3
    copyfile('~/SAM_BIU/docs/SuDi0812.rtw',[fold,'.rtw'])
else
    error('cannot find date or something')
end
    


