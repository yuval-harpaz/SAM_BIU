function svl2tlrc(pat,groups,svlName,newName)
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
folder=''; %#ok<NASGU>
eval('!echo " " > svl2tlrc')
for sub=1:size(subjects,2)
    group=groups(2,find(groups(1,:)==(subjects(sub))));
    if group>0;
        folder=num2str(subjects(sub));
        eval(['!echo 3dcopy ',folder,'/',svlName,' ',folder,'/',newName,' >> svl2tlrc'])
        eval(['!echo cd ',folder,' >> svl2tlrc'])
        eval(['!echo @auto_tlrc -apar warped+tlrc -input ',newName,'+orig -dxyz 5 -suffix ',folder,' >> svl2tlrc'])
        eval(['!echo cd .. >> svl2tlrc'])
        %display(num2str(sub))
    end
end
