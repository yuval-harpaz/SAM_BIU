function plotWeights(wtsFile,vox);
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
if SAMHeader.StepSize==0; % which means it is not a box of voxels
    if ~length(vox)==SAMHeader.NumWeights
        error('the number of chosen virtual sensors is not equal to the number of weights')
    end
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
load ~/ft_BIU/matlab/plotwts
for voxi=1:size(vox,1)
        if SAMHeader.StepSize==0; % which means it is not a box of voxels
            wts.avg=ActWgts(voxi,:)';
            figure;ft_topoplotER([],wts);
            title(num2str(vox(voxi,:)));
        else
            ind=voxIndex(vox(voxi,:),100.*[...
                SAMHeader.XStart SAMHeader.XEnd ...
                SAMHeader.YStart SAMHeader.YEnd ...
                SAMHeader.ZStart SAMHeader.ZEnd],...
                100.*SAMHeader.StepSize,0);
            wts.avg=ActWgts(ind,:)';
            figure;ft_topoplotER([],wts);
            title(num2str(vox(voxi,:)));
        end
    end