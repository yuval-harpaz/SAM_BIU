
source='c,rfhp0.1Hz';
pat='/media/D6A0A2E3A0A2C977/Pnaming/data';
%load([pat,'/groups']);
groups=[1:8];
groups(2,:)=1;
% alpha: filt='8 15'; beta: filt='15 25'; gamma: filt='25 60';
filt='8 60';
SAM_spm(pat,source,groups,filt,textFile);
%% rewriting the trigger and zeroing bad channels
% prepare4samYH(pat,source,groups)
source=['tf_',source];
%% create folders for -m option in SAMcov by global (alltrials) marker
trigVal=202;startt=-0.2;endt=0.54;
globalize(pat,groups,trigVal,startt,endt)
%% SAMcov
SAM_cov(pat,source,groups,filt)
%% SAMwts
SAM_wts(pat,source,groups,filt)
%% SAMerf
% trigVals=202;
% startt=0.12;endt=0.514;startb=-0.2;endb=0.05;
% SAM_erf(pat,source,groups,filt,trigVals,startt,endt,startb,endb);
%% SAMspm
% set active and control time windows and trigger values.
cd(pat)
textFile='Pname';
if exist(textFile,'file')==2
    eval(['!rm ',textFile])
end
startAct=startt;endAct=endt;trigValAct=trigVals;
startCont=startb;endCont=endb;trigValCont=trigVals;
eval(['!echo 1 >> ',textFile]);
eval(['!echo ',num2str(trigValAct),' ',num2str(startAct),' ',num2str(endAct),' >> ',textFile]);
eval(['!echo 1 >> ',textFile]);
eval(['!echo ',num2str(trigValCont),' ',num2str(startCont),' ',num2str(endCont),' >> ',textFile]);
% all frequencies
SAM_spm(pat,source,groups,filt,textFile);


%% MRI from template
eval(['!echo cd ',pat,' > warp'])
for i=1:size(groups,2)
    eval(['cd ',pat,'/',num2str(groups(1,i))]);
    fitMRI2hs(source);
    cd ..
    eval(['!echo cd ',num2str(groups(1,i)),' >> warp']);
    eval('!echo 3dWarp -deoblique T.nii >> warp');
    eval('!echo cd .. >> warp');
end

display('open a terminal and write the following two commands:')
display(['cd ',pat])
display('warp')
