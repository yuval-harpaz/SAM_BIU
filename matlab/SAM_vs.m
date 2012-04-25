function SAM_vs(pat,source,sub,filt,vox,vs,matfile)
% for given voxels 'vox', 
% sub is the folder name of the subject's data (works for one sub at a time)
% filt is text for bandpass: filt='0.1 50';
% vox is a matrix of n (num of VSs) by 3 (x y z).
% vs 1 or 0 to create a timeseries of the VS for the whole dataset
% matfile (0 or 1) saves a .mat file of the weights if 1.
% pat='/media/disk/Sharon/MEG/Experiment3/Source_localization';
% sub=23;
%
%%
cd(pat)
filt=str2num(filt);
filttext=[num2str(filt(1,1)),'-',num2str(filt(1,2))];
eval(['!echo ',num2str(size(vox,1)),' > vs.txt']);
for i=1:size(vox,1)
    eval(['!echo ',num2str(vox(i,1)),' ',num2str(vox(i,2)),' ',num2str(vox(i,3)),'  >> vs.txt']);
end
%%
folder=sub;
if isnumeric(sub)
    folder=num2str(sub);
end
eval(['!cp vs.txt ',folder,'/SAM/vs.txt']);
eval(['!~/bin/SAMwts -r ',folder,' -d ',source,' -c Global,',filttext,'Hz -m Global,',filttext,'Hz -C -Z -t vs.txt -v'])
if vs==1
    eval(['!~/bin/SAMvs -r ',folder,' -d ',source,' -w Global,',filttext,'Hz,vs.txt,ECD -v']);
end
if matfile==1
    cd([folder,'/SAM']);
    [~,~,ActWgts]=readWeights(['Global,',filttext,'Hz,vs.txt,ECD.wts']);
    save ActWghts ActWgts
    cd ../..
    display(folder)
end
end
