% better run script in stages

%% 1) ICA for spike classification
%specify path dataset (filename) bad channels and MEG ('M') or EEG ('M')

pat='';
dataset='tf_c,rfhp1.0Hz,ee';
comp=epiFTica(pat,dataset,[74 204],'M');
%% 2) create a trigger channel
% check the components with component browser.
% specify components 'compNum' to be written as triggers. try compNum=1:10 for start.
compNum=[1 4];
trigger=comp2trig(comp,compNum);
%% 3) write the new trigger channel to file
% has to write one trigger value per file because SAM crashes when triggers
% overlap
% specify bad channels to be replaced by zeros.
if ~exist('pat','var')
    pat='';
end
if ~isempty(pat)
    cd(pat);
end
for i=1:size(compNum,2)
    trig=(abs(trigger)==compNum(i));
    trig(1,1:200)=0;trig(1,(end-200):end)=0; %ignoring edges
    rewriteTrig(dataset,trig,['tf',num2str(compNum(i))],[]);
end
%%
% in a terminal cd to te folder with all runs (all subjects such as b099) and run DoEpiICA b099 tf2
% or:
% SAMwts -r b099 -d tf3_c,rfhp1.0Hz,ee -c Global,20-70Hz -C -Z -x "-10 10" -y "-9 9" -z "0 14" -s 0.5 -v
% cp ~/SAM_BIU/matlab/epilepsy/ICA b025/SAM/ICA
% SAMspm -r b099 -d tf3_c,rfhp1.0Hz,ee -a Global,0-100Hz,Global,ECD -c Global,0-100Hz,Global,ECD -m ICA -D 1 -P -v
% SAMerf -r b099 -d tf3_c,rfhp1.0Hz,ee -w Global,0-100Hz,Global,ECD -m 1 -f "3 70" -v -t "-0.025 0.025" -b "-0.2 -0.15" -z 3

    
    