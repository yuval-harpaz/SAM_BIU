function prepare4sam(subj,badChans) % (pat,source,groups)
% lists folders with data at the given path (linux), fixes visual trigger for SAM
% analysis.
% groups is a matrix of sbjects in the first row. zeros on the second row
% mean- do not analyse.
% source='c,rfhp0.1Hz,lp';pat='/media/disk/Sharon/MEG/Experiment3/Source_lo
% calization'; load groups;
% 
%% 
pat='/media/D6A0A2E3A0A2C977/Pnaming/data';
source='c,rfhp0.1Hz';
cd(pat)
!ls > ls.txt
subjects=importdata('ls.txt')';
% if ~exist('groups','var')
%     groups=[];
% end
groups=subjects;
groups(2,:)=0;
groups(2,subj)=1;
% if isempty(groups)
%     groups=subjects;
%     groups(2,:)=1;
% end


%folder='';
for sub=1:size(subjects,2)
    group=groups(2,find(groups(1,:)==(subjects(sub)))); %#ok<FNDSB>
    if group>0;
        folder=num2str(subjects(sub));
        cd(folder)
        trig=readTrig_BIU(source);
        trig=bitand(uint16(trig),202);
        trigi=find(trig);
        trigi=trigi+110;
        newTrig=zeros(size(trig));
        newTrig(1,trigi)=202;
        rewriteTrig(source,newTrig,'tf',badChans);
        title(pwd);
        display(num2str(sub))
        cd ..
    end
end
