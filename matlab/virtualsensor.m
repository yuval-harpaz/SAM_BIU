function virtualsensor
nvs = 8;            % number of virtual sensors
qspace = 100;
% patient= '2691/Epi200_1hz';
% run = '1';
% epoch = 'Epoch2,';
% band = '20-70Hz,Epi,';
% rootname = ['/Users/ser/data/' patient '/' run '/SAM/' epoch band]
rootname=['Global,20-70Hz,Epi,'];
dx = 5;           % dx is the width of the axis 'window' in seconds
a = gca;

switch(nvs)
    case 1
        [x, y1] = textread([rootname 'VS1'], '%f %f');
        p = plot(x,y1,'LineWidth',1.5);
    case 2
        [x, y1] = textread([rootname 'VS1'], '%f %f');
        [x, y2] = textread([rootname 'VS2'], '%f %f');
        y1 = y1 + qspace;
        y2 = y2 - qspace;
        p = plot(x,y1,x,y2,'LineWidth',1.5);
    case 3
        [x, y1] = textread([rootname 'VS1'], '%f %f');
        [x, y2] = textread([rootname 'VS2'], '%f %f');
        [x, y3] = textread([rootname 'VS3'], '%f %f');
        y1 = y1 + 2. * qspace;
        y3 = y3 - 2. * qspace;
        p = plot(x,y1,x,y2,x,y3,'LineWidth',1.5);
    case 4
        [x, y1] = textread([rootname 'VS1'], '%f %f');
        [x, y2] = textread([rootname 'VS2'], '%f %f');
        [x, y3] = textread([rootname 'VS3'], '%f %f');
        [x, y4] = textread([rootname 'VS4'], '%f %f');
        y1 = y1 + 3. * qspace;
        y2 = y2 + qspace;
        y3 = y3 - qspace;
        y4 = y4 - 3. * qspace;
        p = plot(x,y1,x,y2,x,y3,x,y4,'LineWidth',1.5);
    case 5
        [x, y1] = textread([rootname 'VS1'], '%f %f');
        [x, y2] = textread([rootname 'VS2'], '%f %f');
        [x, y3] = textread([rootname 'VS3'], '%f %f');
        [x, y4] = textread([rootname 'VS4'], '%f %f');
        [x, y5] = textread([rootname 'VS5'], '%f %f');
        y1 = y1 + 4. * qspace;
        y2 = y2 + 2. * qspace;
        y4 = y4 - 2. * qspace;
        y5 = y5 - 4. * qspace;
        p = plot(x,y1,x,y2,x,y3,x,y4,x,y5,'LineWidth',1.5);
    case 6
        [x, y1] = textread([rootname 'VS1'], '%f %f');
        [x, y2] = textread([rootname 'VS2'], '%f %f');
        [x, y3] = textread([rootname 'VS3'], '%f %f');
        [x, y4] = textread([rootname 'VS4'], '%f %f');
        [x, y5] = textread([rootname 'VS5'], '%f %f');
        [x, y6] = textread([rootname 'VS6'], '%f %f');
        y1 = y1 + 5. * qspace;
        y2 = y2 + 3. * qspace;
        y3 = y3 + qspace;
        y4 = y4 - qspace;
        y5 = y5 - 3. * qspace;
        y6 = y6 - 5. * qspace;
        p = plot(x,y1,x,y2,x,y3,x,y4,x,y5,x,y6,'LineWidth',1.5);
    case 7
        [x, y1] = textread([rootname 'VS1'], '%f %f');
        [x, y2] = textread([rootname 'VS2'], '%f %f');
        [x, y3] = textread([rootname 'VS3'], '%f %f');
        [x, y4] = textread([rootname 'VS4'], '%f %f');
        [x, y5] = textread([rootname 'VS5'], '%f %f');
        [x, y6] = textread([rootname 'VS6'], '%f %f');
        [x, y7] = textread([rootname 'VS7'], '%f %f');
        y1 = y1 + 6. * qspace;
        y2 = y2 + 4. * qspace;
        y3 = y3 + 2. * qspace;
        y5 = y5 - 2. * qspace;
        y6 = y6 - 4. * qspace;
        y7 = y7 - 6. * qspace;
        p = plot(x,y1,x,y2,x,y3,x,y4,x,y5,x,y6,x,y7,'LineWidth',1.5);
    case 8
        [x, y1] = textread([rootname 'VS1'], '%f %f');
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
        p = plot(x,y1,x,y2,x,y3,x,y4,x,y5,x,y6,x,y7,x,y8,'LineWidth',1.5);
    otherwise
        disp('Unknown number of virtual sensors');
end

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
switch(nvs)
    case 1
        set(a,'ylim',[1.1*min(y1) 1.1*max(y1)]);
    case 2
        set(a,'ylim',[1.1*min(y2) 1.1*max(y1)]);
	case 3
        set(a,'ylim',[1.1*min(y3) 1.1*max(y1)]);
    case 4
        set(a,'ylim',[1.1*min(y4) 1.1*max(y1)]);
    case 5
        set(a,'ylim',[1.1*min(y5) 1.1*max(y1)]);
	case 6
        set(a,'ylim',[1.1*min(y6) 1.1*max(y1)]);
	case 7
        set(a,'ylim',[1.1*min(y7) 1.1*max(y1)]);
    case 8
        set(a,'ylim',[1.1*min(y8) 1.1*max(y1)]);
    otherwise
        disp('Unknown number of virtual sensors');
end

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