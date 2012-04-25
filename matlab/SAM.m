function SAM(pat,source,groups,trigVal,startt,endt)
% lists folders with data at the given path (linux), fixes visual trigger for SAM
% analysis.
% groups is a matrix of sbjects in the first row. zeros on the second row
% mean- do not analyse.
% load groups;
% pat='/media/disk/Sharon/MEG/Experiment3/Source_localization';
% trigVal=1;startt=-0.11;endt=0.91; % 0.01 due to global trigger preceeding
% time zero
%% settings
trigVal=num2str(trigVal);
startt=num2str(startt);
endt=num2str(endt);
%% creating a text file with epoch window parameters
cd(pat)
if exist('Global','file')==2;
    !rm Global
end
!echo 1 >> Global
eval(['!echo ',trigVal,' ',startt,' ',endt,' >> Global']);
display('Global=');
!cat Global
if ~exist('groups','var')
    groups=[];
end

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
        if ~exist([folder,'/SAM'])
            mkdir([folder,'/SAM'])
        end
        eval(['!cp Global ',folder,'/SAM/Global'])
        if exist([folder,'/SuDi0810.rtw'],'file')<2
            eval(['!cp ~/SAM_BIU/docs/SuDi0810.rtw ',folder,'/',folder,'.rtw'])
        end
        display(num2str(sub))
    end
end
