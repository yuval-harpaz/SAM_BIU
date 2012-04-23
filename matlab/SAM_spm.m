function SAM_spm(pat,source,groups,filt,textFile)
% lists folders with data at the given path (linux), fixes visual trigger for SAM
% analysis.
% groups is a matrix of sbjects in the first row. zeros on the second row
% mean- do not analyse.
% load groups;
% pat='/media/disk/Sharon/MEG/Experiment3/Source_localization';
% filt is text for bandpass: filt='0.1 50';
%% 
cd(pat)
!ls > ls.txt
subjects=importdata('ls.txt')';
!rm ls.txt
if isempty(groups)
    groups=subjects;
    groups(2,:)=1;
end
filtstr=str2num(filt);
%% 
folder='';
for sub=1:size(subjects,2)
    group=groups(2,find(groups(1,:)==(subjects(sub))));
    if group>0;
        folder=num2str(subjects(sub));
        eval(['!cp ',textFile,' ',folder,'/SAM']);
        eval(['!~/bin/SAMspm -r ',folder,' -d ',source,...
            ' -a Global,',num2str(filtstr(1,1)),'-',num2str(filtstr(1,2)),'Hz,Global,ECD',...
            ' -c Global,',num2str(filtstr(1,1)),'-',num2str(filtstr(1,2)),'Hz,Global,ECD ',...
            '-m ',textFile,' -f "',filt,'" -D 1 -P -v -t 3']);
        display(num2str(sub))
    end
end
