function SAM_cov(pat,source,groups,filt)
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
%% 
folder='';
for sub=1:size(subjects,2)
    group=groups(2,find(groups(1,:)==(subjects(sub))));
    if group>0;
        folder=num2str(subjects(sub));
        eval(['!SAMcov -r ',folder,' -d ',source,' -m Global -f "',filt,'" -v'])
        eval(['!cp ',folder,'/SAM/Global,1-50Hz/*.cov ',folder,'/SAM/Global,1-50Hz/Global.cov'])
        % mv sub/SAM/Global,1-40Hz/5a.cov sub/SAM/Global,1-40Hz/Global.cov
        display(num2str(sub))
    end
end
