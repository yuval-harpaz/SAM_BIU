function [vs,timeline]=VS_ft(data,wtsFile,vox,lat,bpfreq)
% requires fieldtrip
%% data
%the data can be a fieldtrip data structure or a name of raw data file,
%   e.g., 'c,rfhp0.1Hz';
%% types of weights file .wts
% type 1: normal *.wts file, all voxels in a box.
% type 2: *.wts filw contains a chosen number of voxels, not in a box.
%   this is achieved after applying -t option for SAMwts, specifying a text
%   file such as Wer.max (first row - number of voxels, next rows - x y z (cm)).
%   text file example:
%        3
%       -2 6 5
%       -1 6 5
%        0 6 5
% such text files can be produced by SVLPeak.
%% format .wts and .mat
% the two formats possible are the original .wts file and a similar .mat
%   file. this program creates the .mat file and uses it if used again to
%   create more virtual sensors. readning .mat is much faster for matlab.
% examples for possible wtsFile input:
% wtsFile='Wer.max.wts';
% wtsFile='Wer.max.mat';
% wtsFile='/home/yuval/Data/tel_hashomer/yuval/SAM/VGerf,1-35Hz,VerbAa.wts';
% wtsFile='/home/yuval/Data/tel_hashomer/yuval/SAM/VGerf,1-35Hz,VerbAa.mat';
%% vox
% vox is a matrix of voxel coordinates, e.g. [-2 6 5;-1 6 5;0 6 5];
%   it is also possible to specify a text file of voxels such as Wer.max in
%   the above example, e.g. vox='Wer.max';
%% latency and bandpass filter
%   for raw data (c,rfhp0.1Hz) it is possible to specify the time to be read,
%   e.g. lat=[0 100] for the first 100s. left empty the whole file will be read.
%   fieldtrip data is already epoched and will be processed for its whole length.
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
if ischar(vox) % checks if vox is a text file
    if exist(vox,'file')
        voxt=textread(vox);
        vox=voxt(2:length(voxt)-1,:);
    else
        error(['could not find text file: ',vox]);
    end
end
if SAMHeader.StepSize==0; % which means it is not a box of voxels
    if ~length(vox)==SAMHeader.NumWeights
        error('the number of chosen virtual sensors is not equal to the number of weights')
    end
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
elseif ~isfield(data,'trial')
    if ~isfield(data,'avg')
        error('is this fieldtrip data? no data.avg or data.trial!')
    end
    timeline=data.time;
    data.trial{1,1}=data.avg;
end
if ~exist('timeline','var')
    timeline=data.time{1,1};
end
%% multiplying the data by the weights.
vs=zeros(1,length(data.trial{1,1}),1);
for triali=1:length(data.trial)
    for voxi=1:size(vox,1)
        if SAMHeader.StepSize==0; % which means it is not a box of voxels
            vs(voxi,:,triali)=ActWgts(voxi,:)*data.trial{1,triali};
        else
            ind=voxindex(vox(voxi,:),100.*[...
                SAMHeader.XStart SAMHeader.XEnd ...
                SAMHeader.YStart SAMHeader.YEnd ...
                SAMHeader.ZStart SAMHeader.ZEnd],...
                100.*SAMHeader.StepSize,0);
            vs(voxi,:,triali)=ActWgts(ind,:)*data.trial{1,triali};
        end
    end
end
display('consider change vs values to z scores, medial vs are noisy');
end
%
%     wts=data;
%     if size(ActWgts,1)==1
%         wts.avg=ActWgts';
%         vs=ActWgts*data.avg;
%     else
%         if ~exist('vox','var')
%             error('reuires "vox", weights file contains many voxels, specify which one')
%         end
%         ind=voxindex(vox,100.*[...
%             SAMHeader.XStart SAMHeader.XEnd ...
%             SAMHeader.YStart SAMHeader.YEnd ...
%             SAMHeader.ZStart SAMHeader.ZEnd],...
%             100.*SAMHeader.StepSize,0);
%         wts.avg=ActWgts(ind,:);
%         vs=ActWgts(ind,:)*data.avg;
%     end
%     wts.time=0;
%     if ActWgts
%         wts.trial{1,1}=ActWgts';
%         figure;ft_topoplotER([],wts);
%         figure;plot(data.time,vs);
%
%     end