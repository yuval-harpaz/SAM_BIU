
source='c,rfhp0.1Hz';
pat='/media/disk/Sharon/MEG/Experiment3/Source_localization';
load([pat,'/groups']);
%% rewriting the trigger and zeroing bad channels
prepare4sam1(pat,source,groups)
%% create folders for -m option in SAMcov by global (alltrials) marker
trigVal=1;startt=-0.11;endt=0.91;
globalize(pat,groups,trigVal,startt,endt)
%% SAMcov
source=['tf_',source];
filt='1 50';
SAM_cov(pat,source,groups,filt)

%%
%filt=str2num(filt);

SAM_wts(pat,source,groups,filt)
%%
trigVals=20:20:200;
SAM_erf(pat,source,groups,filt,trigVals,0.13,0.21)
%%
% set active and control time windows and trigger values.
cd(pat)
textFile='DomBL';
if exist(textFile,'file')==2
    eval(['!rm ',textFile])
end
startAct=0.13;endAct=0.21;trigValAct=20;
startCont=-0.8;endCont=0;trigValCont=20;
eval(['!echo 1 >> ',textFile]);
eval(['!echo ',num2str(trigValAct),' ',num2str(startAct),' ',num2str(endAct),' >> ',textFile]);
eval(['!echo 1 >> ',textFile]);
eval(['!echo ',num2str(trigValCont),' ',num2str(startCont),' ',num2str(endCont),' >> ',textFile]);
SAM_spm(pat,source,groups,filt,textFile);