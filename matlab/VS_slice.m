function [vs,timeline,allInd]=VS_slice(data,wtsFile,sampleStep,lat,bpfreq)
% requires fieldtrip
% designed for raw data (e.g. epileptic spike) or fieldtrip averaged data.
% when ft data is unaveraged vs are created for each trial and are then
% averaged.
% allInd gives the coordinates of every virtual sensor.
% this is only for wts based on a box of voxels.
%% data
%the data can be a fieldtrip data structure or a name of raw data file,
%   e.g., 'c,rfhp0.1Hz';
%% types of weights file .wts
% normal *.wts file, all voxels in a box.
%% format .wts and .mat
% the two formats possible are the original .wts file and a similar .mat
%   file. this program creates the .mat file and uses it if used again to
%   create more virtual sensors. readning .mat is much faster for matlab.
% examples for possible wtsFile input:
% wtsFile='/home/yuval/Data/tel_hashomer/yuval/SAM/VGerf,1-35Hz,VerbAa.wts';
% wtsFile='/home/yuval/Data/tel_hashomer/yuval/SAM/VGerf,1-35Hz,VerbAa.mat';
%% latency and bandpass filter
%   specify the time to be read, e.g. lat=[0.05 0.7] for 50 to 700ms.
%   for raw data bandpass frequencies can be given, e.g., bpfreq=[1 35]

%% reading weights
if strcmp('.wts',wtsFile(end-3:end)) || strcmp('.mat',wtsFile(end-3:end))
    wtsNoSuf=wtsFile(1:end-4);
else
    wtsNoSuf=wtsFile;
end
if ~exist ([wtsNoSuf,'.mat'],'file')
    if ~exist ([wtsNoSuf,'.wts'],'file')
        error(['did not find ',wtsNoSuf,'.wts or .mat file']);
    end
    display('reading the *.wts file and saving it as *.mat')
    [SAMHeader, ActIndex, ActWgts]=readWeights([wtsNoSuf,'.wts']);
    save([wtsNoSuf,'.mat'],'SAMHeader', 'ActIndex', 'ActWgts')
else
    display('loading weights from *.mat file');
    load([wtsNoSuf,'.mat'])
end
%% checking voxels (they are realy grid points you know, no volume).
if SAMHeader.StepSize==0; % which means it is not a box of voxels
    error('no box parameters in the header of wts file')
end
%% getting the data
if ischar(data)
    cfg=[];
    cfg.dataset=data;
    if exist('lat','var')
        cfg.trialdef.beginning=lat(1);
        cfg.trialdef.end=lat(2);
    end
    cfg.trialfun='trialfun_raw';
    cfg1=ft_definetrial(cfg);
    cfg1.channel='MEG';
    if exist('bpfreq','var');
        cfg1.bpfilter='yes';
        cfg1.bpfreq=bpfreq;
    end
    data=ft_preprocessing(cfg1);
    timeline=data.time{1,1};
elseif ~isfield(data,'trial')
    if ~isfield(data,'avg')
        error('is this fieldtrip data? no data.avg or data.trial!')
    end
    timeline=data.time;
    data.trial{1,1}=data.avg;
else
    timeline=data.time{1,1};
end

        
% if ~exist('timeline','var')
%     timeline=data.time{1,1};
% end
%% voxels
[~,allInd]=voxindex([0,0,0],100.*[...
    SAMHeader.XStart SAMHeader.XEnd ...
    SAMHeader.YStart SAMHeader.YEnd ...
    SAMHeader.ZStart SAMHeader.ZEnd],...
    100.*SAMHeader.StepSize,1);


%% resampling and multiplying the data by the weights.
%vs=ActWgts*data.trial{1,1};
resampledData=data.trial{1,1};
startInd=nearest(timeline,lat(1));
startTime=timeline(startInd);
endInd=nearest(timeline,lat(2));
endTime=timeline(endInd);
resampledTime=timeline(startInd:sampleStep:endInd);
resampledData=data.trial{1,1}(:,startInd:sampleStep:endInd);
if length(data.trial)==1
    vs=ActWgts*resampledData;
else
    vs=zeros(length(ActWgts),size(resampledData,2));
    for triali=1:length(data.trial);
        vs=vs+ActWgts*data.trial{1,triali};
    end
    vs=vs./triali;
end
timeline=resampledTime;
display(['the data timeline is from ',num2str(startTime),' to ',num2str(endTime),' in steps of ',num2str((timeline(2)-timeline(1))*1000),'ms']);
display('consider change vs values to z scores, medial vs are noisy');
end