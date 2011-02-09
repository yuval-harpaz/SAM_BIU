function virtualsensorMEEG(Xlength,MorE,source,VSdir)
% plots the virtual sensors created by SAM. first, cd to where the *VS* files are.
% Xlength is to specify the x scale. Xlength=10 means the plot will cover
% 10s in one screen.
% if MEG or EEG are to be desplyed, use MorE to indicate which.
%source is the full filename.
%VSdir is the path to the VSs
for i=1:8;if exist(['Global,20-70Hz,Epi,VS',num2str(i)],'file');nvs=i;end;end;
%nvs = 8;            % number of virtual sensors
if ~exist('MorE','var');MorE=[];end
pdf=pdf4D(source);
hdr=get(pdf,'header');
lastSamp=hdr.epoch_data{1,1}.pts_in_epoch;
if strcmp(MorE,'M');
    chans=1:8:240;
    str=[];
    for i=1:30;str=[str,' ','''A',num2str(chans(i)),''''];end;
    chi=channel_index(pdf,eval(['{',str,'}']),'name');
    labels=channel_name(pdf,chi);
    data=read_data_block(pdf,[1 lastSamp],chi);
elseif strcmp(MorE,'E');
    chans=1:30;
    str=[];
    for i=1:30;str=[str,' ','''E',num2str(chans(i)),''''];end;
    chi=channel_index(pdf,eval(['{',str,'}']),'name');
    labels=channel_name(pdf,chi);
    data=read_data_block(pdf,[1 lastSamp],chi);
end
m=mean(data,2);
meanmat=zeros(size(data));
for i=1:30
    meanmat(i,:)=m(i);
end
data=data-meanmat;
    
    
qspace = 100;
% patient= '2691/Epi200_1hz';
% run = '1';
% epoch = 'Epoch2,';
% band = '20-70Hz,Epi,';
% rootname = ['/Users/ser/data/' patient '/' run '/SAM/' epoch band]
rootname=[VSdir,'/Global,20-70Hz,Epi,'];
dx = 10;           % dx is the width of the axis 'window' in seconds
if exist('Xlength','var');dx=Xlength;end
a = gca;
[x, y1] = textread([rootname 'VS1'], '%f %f');
for i=2:8;
    eval(['y',num2str(i),'=zeros(size(y1));']);
end
for i=9:38;
    eval(['y',num2str(i),'=data(',num2str((i-8)),',1:(size(y1,1)));']);
end
[x, y2] = textread([rootname 'VS2'], '%f %f');
[x, y3] = textread([rootname 'VS3'], '%f %f');
[x, y4] = textread([rootname 'VS4'], '%f %f');
[x, y5] = textread([rootname 'VS5'], '%f %f');
[x, y6] = textread([rootname 'VS6'], '%f %f');
[x, y7] = textread([rootname 'VS7'], '%f %f');
[x, y8] = textread([rootname 'VS8'], '%f %f');
y1 = y1 + 7. * qspace;
y2 = y2 + 5. * qspace;
y3 = y3 + 3. * qspace;
y4 = y4 + qspace;
y5 = y5 - qspace;
y6 = y6 - 3. * qspace;
y7 = y7 - 5. * qspace;
y8 = y8 - 7. * qspace;
for i=9:38;
    if strcmp(MorE,'M')
        eval(['y',num2str(i),'=','y',num2str(i),'*0.5*10^14-(',num2str(((i-4.5)*2).*qspace),');'])
    elseif strcmp(MorE,'E')
        eval(['y',num2str(i),'=','y',num2str(i),'*10^5-(',num2str(((i-4.5)*2).*qspace),');'])
    end
end
str='p=plot(';
for i=1:38;
    str=[str,'x,y',num2str(i),','];
end
str=[str,'''LineWidth''',',1.5);'];
eval(str)

% p = plot(x,y1,x,y2,x,y3,x,y4,x,y5,x,y6,x,y7,x,y8,'LineWidth',1.5);
% hold on;
% plot(x,data)

% switch(nvs)
%     case 1
%         [x, y1] = textread([rootname 'VS1'], '%f %f');
%         p = plot(x,y1,'LineWidth',1.5);
%     case 2
%         [x, y1] = textread([rootname 'VS1'], '%f %f');
%         [x, y2] = textread([rootname 'VS2'], '%f %f');
%         y1 = y1 + qspace;
%         y2 = y2 - qspace;
%         p = plot(x,y1,x,y2,'LineWidth',1.5);
%     case 3
%         [x, y1] = textread([rootname 'VS1'], '%f %f');
%         [x, y2] = textread([rootname 'VS2'], '%f %f');
%         [x, y3] = textread([rootname 'VS3'], '%f %f');
%         y1 = y1 + 2. * qspace;
%         y3 = y3 - 2. * qspace;
%         p = plot(x,y1,x,y2,x,y3,'LineWidth',1.5);
%     case 4
%         [x, y1] = textread([rootname 'VS1'], '%f %f');
%         [x, y2] = textread([rootname 'VS2'], '%f %f');
%         [x, y3] = textread([rootname 'VS3'], '%f %f');
%         [x, y4] = textread([rootname 'VS4'], '%f %f');
%         y1 = y1 + 3. * qspace;
%         y2 = y2 + qspace;
%         y3 = y3 - qspace;
%         y4 = y4 - 3. * qspace;
%         p = plot(x,y1,x,y2,x,y3,x,y4,'LineWidth',1.5);
%     case 5
%         [x, y1] = textread([rootname 'VS1'], '%f %f');
%         [x, y2] = textread([rootname 'VS2'], '%f %f');
%         [x, y3] = textread([rootname 'VS3'], '%f %f');
%         [x, y4] = textread([rootname 'VS4'], '%f %f');
%         [x, y5] = textread([rootname 'VS5'], '%f %f');
%         y1 = y1 + 4. * qspace;
%         y2 = y2 + 2. * qspace;
%         y4 = y4 - 2. * qspace;
%         y5 = y5 - 4. * qspace;
%         p = plot(x,y1,x,y2,x,y3,x,y4,x,y5,'LineWidth',1.5);
%     case 6
%         [x, y1] = textread([rootname 'VS1'], '%f %f');
%         [x, y2] = textread([rootname 'VS2'], '%f %f');
%         [x, y3] = textread([rootname 'VS3'], '%f %f');
%         [x, y4] = textread([rootname 'VS4'], '%f %f');
%         [x, y5] = textread([rootname 'VS5'], '%f %f');
%         [x, y6] = textread([rootname 'VS6'], '%f %f');
%         y1 = y1 + 5. * qspace;
%         y2 = y2 + 3. * qspace;
%         y3 = y3 + qspace;
%         y4 = y4 - qspace;
%         y5 = y5 - 3. * qspace;
%         y6 = y6 - 5. * qspace;
%         p = plot(x,y1,x,y2,x,y3,x,y4,x,y5,x,y6,'LineWidth',1.5);
%     case 7
%         [x, y1] = textread([rootname 'VS1'], '%f %f');
%         [x, y2] = textread([rootname 'VS2'], '%f %f');
%         [x, y3] = textread([rootname 'VS3'], '%f %f');
%         [x, y4] = textread([rootname 'VS4'], '%f %f');
%         [x, y5] = textread([rootname 'VS5'], '%f %f');
%         [x, y6] = textread([rootname 'VS6'], '%f %f');
%         [x, y7] = textread([rootname 'VS7'], '%f %f');
%         y1 = y1 + 6. * qspace;
%         y2 = y2 + 4. * qspace;
%         y3 = y3 + 2. * qspace;
%         y5 = y5 - 2. * qspace;
%         y6 = y6 - 4. * qspace;
%         y7 = y7 - 6. * qspace;
%         p = plot(x,y1,x,y2,x,y3,x,y4,x,y5,x,y6,x,y7,'LineWidth',1.5);
%     case 8
%         [x, y1] = textread([rootname 'VS1'], '%f %f');
%         [x, y2] = textread([rootname 'VS2'], '%f %f');
%         [x, y3] = textread([rootname 'VS3'], '%f %f');
%         [x, y4] = textread([rootname 'VS4'], '%f %f');
%         [x, y5] = textread([rootname 'VS5'], '%f %f');
%         [x, y6] = textread([rootname 'VS6'], '%f %f');
%         [x, y7] = textread([rootname 'VS7'], '%f %f');
%         [x, y8] = textread([rootname 'VS8'], '%f %f');
%         y1 = y1 + 7. * qspace;
%         y2 = y2 + 5. * qspace;
%         y3 = y3 + 3. * qspace;
%         y4 = y4 + qspace;
%         y5 = y5 - qspace;
%         y6 = y6 - 3. * qspace;
%         y7 = y7 - 5. * qspace;
%         y8 = y8 - 7. * qspace;
%         p = plot(x,y1,x,y2,x,y3,x,y4,x,y5,x,y6,x,y7,x,y8,'LineWidth',1.5);
%     otherwise
%         disp('Unknown number of virtual sensors');
% end

grid on;
xlabel('time (sec)','Fontsize',12);
ylabel('dipole moment (nA-m)','Fontsize',12);

% Set appropriate axis limits and settings
set(gcf,'doublebuffer','on');

%% This avoids flickering when updating the axis
set(a,'xlim',[0 dx]);

% set the x & y-axis limits
xmax = max(x);
xmin = min(x);
set(a,'ylim',[1.1*min(y38) 1.1*max(y1)]);

%% Generate constants for use in uicontrol initialization
pos = get(a,'position');
Newpos = [pos(1) pos(2)-0.1 pos(3) 0.05];

%% This will create a slider which is just underneath the axis
%% but still leaves room for the axis labels above the slider
S=['set(gca,''xlim'',get(gcbo,''value'')+[0 ' num2str(dx) '])'];

%% Setting up callback string to modify XLim of axis (gca)
%% based on the position of the slider (gcbo)

%% Creating Uicontrol
h=uicontrol('Style','slider',...
    'units','normalized',...
    'position',Newpos,...
    'callback',S,...
    'min',0,...
    'max',xmax-dx);
title(pwd)
if exist([VSdir,'/Global,20-70Hz,Global,ECD,Epi.max'],'file')
    display(['!gedit ',VSdir,'/Global,20-70Hz,Global,ECD,Epi.max']);
end
end