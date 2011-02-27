function prepare4sam1(pat,source,groups)
% lists folders with data at the given path (linux), fixes visual trigger for SAM
% analysis.
% groups is a matrix of sbjects in the first row. zeros on the second row
% mean- do not analyse.
% source='c,rfhp0.1Hz,lp';pat='/media/disk/Sharon/MEG/Experiment3/Source_lo
% calization'; load groups;
% 
%% 

cd(pat)
!ls > ls.txt
subjects=importdata('ls.txt')';
if ~exist('groups','var')
    groups=[];
end
if isempty(groups)
    groups=subjects;
    groups(2,:)=1;
end


folder='';
for sub=1:size(subjects,2)
    group=groups(2,find(groups(1,:)==(subjects(sub))));
    if group>0;
        folder=num2str(subjects(sub));
        cd(folder)
        trig=readTrig_BIU(source);
        newTrig=fixVisTrig(trig,300,'onset',1);
        title(pwd);
        rewriteTrig(source,newTrig,'tf',[74 204]);
        title(pwd);
        display(num2str(sub))
        cd ..
    end
end
