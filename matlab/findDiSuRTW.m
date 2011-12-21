function path2RTW=findDiSuRTW(session,position)
% session is a string such as pwd, it has to include the session name such
% as 30.12.11@_11:46
% position = 'Su' for supine ro 'ST' for supine tip.


Aug2011=datenum('30.08.11','dd.mm.yy');
Aug2010=datenum('30.08.10','dd.mm.yy');
Aug2012=datenum('30.08.12','dd.mm.yy');
datei=findstr('@',session);
dateSes=datenum(PWD(datei-8:datei-1),'dd.mm.yy');

if dateSes>Aug2010 && dateSes<Aug2011
    path2RTW='~/SAM_BIU/docs
    
end
end