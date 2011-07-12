function SAM_wts(pat,source,groups,filt)
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
filt=str2num(filt);
%% 
folder='';
for sub=1:size(subjects,2)
    group=groups(2,find(groups(1,:)==(subjects(sub))));
    if group>0;
        folder=num2str(subjects(sub));
        eval(['!~/bin/SAMwts -r ',folder,' -d ',source,' -c Global,',num2str(filt(1,1)),'-',num2str(filt(1,2)),'Hz -C -Z -x "-10 10" -y "-9 9" -z "0 14" -s 0.5 -v'])
        display(num2str(sub))
    end
end
