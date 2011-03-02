
source='c,rfhp0.1Hz';
pat='/media/D6A0A2E3A0A2C977/Pnaming/data';
%load([pat,'/groups']);
groups=[1:8];
groups(2,:)=1;
%% rewriting the trigger and zeroing bad channels
% prepare4samYH(pat,source,groups)
%% create folders for -m option in SAMcov by global (alltrials) marker
trigVal=2;startt=-0.2;endt=0.54;
globalize(pat,groups,trigVal,startt,endt)
%% SAMcov
source=['tf_',source];
filt='1 40';
SAM_cov(pat,source,groups,filt)

%%
%filt=str2num(filt);

SAM_wts(pat,source,groups,filt)
%%
trigVals=202;
startt=0.12;endt=0.51;startb=-0.2;endb=0.05;
SAM_erf(pat,source,groups,filt,trigVals,startt,endt,startb,endb);
%%
% set active and control time windows and trigger values.
cd(pat)
textFile='DomBL';
if exist(textFile,'file')==2
    eval(['!rm ',textFile])
end
startAct=startt;endAct=endt;trigValAct=trigVals;
startCont=startb;endCont=endb;trigValCont=trigVals;
eval(['!echo 1 >> ',textFile]);
eval(['!echo ',num2str(trigValAct),' ',num2str(startAct),' ',num2str(endAct),' >> ',textFile]);
eval(['!echo 1 >> ',textFile]);
eval(['!echo ',num2str(trigValCont),' ',num2str(startCont),' ',num2str(endCont),' >> ',textFile]);
SAM_spm(pat,source,groups,filt,textFile);

%% MRI from template
eval(['!echo cd ',pat,' > warp'])
for i=1:size(groups,2)
    eval(['cd ',pat,'/',num2str(groups(1,i))]);
    fitMRI2hs(source);
    cd ..
    eval(['!echo cd ',num2str(groups(1,i)),' >> warp']);
    eval('!echo 3dWarp -deoblique T.nii >> warp');
    eval('!echo @auto_tlrc -base ~/SAM_BIU/docs/temp+tlrc -input warped+orig -no_ss >> warp')
    eval('!echo cd .. >> warp');
end

display('open a terminal and write the following commands:');
display(['cd ',pat]);
display('warp');
display('afni -R');
display('use switch session to go to all .svl files. choose:');
display('define data mode, plugins, dataset copy');
display('choose dataset (something.svl) give it a new name (func) and save');
display('then cd to SAM folders and run:')
display('@auto_tlrc -apar ../warped+tlrc -input func+orig -dxyz 5')