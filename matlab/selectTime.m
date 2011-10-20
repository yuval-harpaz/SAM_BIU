function selectTime(chan)
close all
dx = 5*1017.25;           % dx is the width of the axis 'window' in seconds
a = gca;
f=figure;
plot(chan);
!rm clicks.txt
%% preparing slider
set(gcf,'doublebuffer','on');
set(a,'xlim',[0 dx]);
xmax = max(size(chan,2));
xmin = min(1);
set(a,'ylim',[1.1*min(chan) 1.1*max(chan)]);
pos = get(a,'position');
Newpos = [pos(1) pos(2)-0.1 pos(3) 0.05];
S=['set(gca,''xlim'',get(gcbo,''value'')+[0 ' num2str(dx) '])'];
h=uicontrol('Style','slider',...
    'units','normalized',...
    'position',Newpos,...
    'callback',S,...
    'min',0,...
    'max',xmax-dx);
title(pwd)
datacursormode on
dcm_obj = datacursormode(f);
set(dcm_obj,'UpdateFcn',@DCMupdatefcn)
pause
    function txt = DCMupdatefcn(empt,event_obj)
        pos = get(event_obj,'Position');
        txt = ['Sample: ',num2str(pos(1))];
        display(txt)
        eval(['!echo ',num2str(pos(1)),' >> clicks.txt']);
    end
end