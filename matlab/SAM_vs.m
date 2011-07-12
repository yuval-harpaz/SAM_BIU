function SAM_vs(pat,source,groups,filt,t,vs,matfile)
% lists folders with data at the given path (linux), fixes visual trigger for SAM
% analysis.
% groups is a matrix of sbjects in the first row. zeros on the second row
% mean- do not analyse.
% load groups;
% pat='/media/disk/Sharon/MEG/Experiment3/Source_localization';
% filt is text for bandpass: filt='0.1 50';
% t is a matrix of n (num of VSs) by 3 (x y z).
% vs 1 or 0 to create a timeseries of the VS for the whole dataset
% matfile (0 or 1) saves a .mat file of the weights if 1.
%%
cd(pat)

if isempty(groups)
    error('requires groups matrix');
end
filt=str2num(filt);
filttext=[num2str(filt(1,1)),'-',num2str(filt(1,2))];
eval(['!echo ',num2str(size(t,1)),' > vs.txt']);
for i=1:size(t,1)
    eval(['!echo ',num2str(t(i,1)),' ',num2str(t(i,2)),' ',num2str(t(i,3)),'  >> vs.txt']);
end
%%
folder='';
for sub=1:size(groups,2)
    group=groups(2,sub);
    if group>0;
        folder=num2str(groups(1,sub));
        eval(['!cp vs.txt ',folder,'/SAM/vs.txt']);
        eval(['!~/bin/SAMwts -r ',folder,' -d ',source,' -c Global,',filttext,'Hz -m Global,',filttext,' -C -Z -t ',t,' -v'])
        if vs==1
            eval(['!~/bin/SAMvs -r ',folder,' -d ',source,' -w Global,',filttext,'Hz,vs.txt,ECD -v']);
        end
        if matfile==1
            cd([folder,'/SAM']);
            [~,~,ActWgts]=readWeights(['Global,',filttext,'Hz,vs.txt,ECD.wts']);
            save ActWghts ActWgts
            cd ../..
        end
    end
    
    
    display(num2str(groups(1,sub)))
    
end
end
