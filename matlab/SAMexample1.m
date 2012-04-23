
source='c,rfhp0.1Hz';
pat='/media/D6A0A2E3A0A2C977/Pnaming/data';
%load([pat,'/groups']);
groups=1:8;
groups(2,:)=1;
%% rewriting the trigger and zeroing bad channels
% prepare4samYH(pat,source,groups)
%% create folders for -m option in SAMcov by global (alltrials) marker
trigVal=2;startt=-0.2;endt=0.54;
globalize(pat,groups,trigVal,startt,endt)
%% SAMcov
% newName='alpha'; filt='8 15'; newName='beta'; filt='15 25'; newName='gamma'; filt='25 60';
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
% also copies the svl file to afni format (brick). new name - alpha.
for i=1:size(groups,2)
    eval(['cd ',pat,'/',num2str(groups(1,i))]);
    fitMRI2hs(source);
    !~/abin/3dWarp -deoblique T.nii
    eval(['!~/abin/3dcopy Pname,8-15Hz,202-202,Tp.svl ',newName]);
end
%% Nudge
% in a terminal cd to every folder and open afni
% define data mode - plugins - nudge
% choose dataset (choose warp) - change valuses and nudge - when fits: 'Do All' and exit.
%% transfer MRI (warped) and MEG to talairach
% run such only after Nudging
% this creates a script to br run in terminal
cd(pat)
eval(['!echo cd ',pat,' > orig2tlrc'])
if ~exist('../merge','dir')
    !mkdir ../merge
end
strSET='';
strMerge='3dmerge -gmean -1noneg -1clip 0.05*max0 -1thresh 0.1 -1blur_fwhm 5 -prefix alpha ';
strTtset='3dttest -base1 0 -set2 '
% strTtest='3dttest -set1 sub1cond1+tlrc sub2con1+tlrc sub3cond1+tlrc -set2 sub1cond2+tlrc sub2cond2+tlrc  sub2cond2+tlrc -paired'
for i=1:size(groups,2)
    eval(['!echo cd ',num2str(groups(1,i)),' >> orig2tlrc']);
    eval('!echo @auto_tlrc -base ~/SAM_BIU/docs/temp+tlrc -input warped+orig -no_ss >> orig2tlrc');
    eval(['!echo @auto_tlrc -apar warped+tlrc -input ',newName,'+orig -dxyz 5 -suffix ',num2str(groups(1,i)),' >> orig2tlrc']);
    eval('!echo cd .. >> orig2tlrc');
    strSET=[strSET,num2str(groups(1,i)),'/',newName,num2str(groups(1,i)),'+tlrc '] %#ok<AGROW>
end
eval(['!echo ',strMerge,strSET,' >> orig2tlrc']);
eval(['!echo ',strTtset,strSET,'-prefix t >> orig2tlrc']);

%sub1+tlrc sub2+tlrc sub3+tlrc sub4+tlrc
% for i=1:size(groups,2)
%     eval(['cd ',pat,'/',num2str(groups(1,i))]);
%     !~/abin/@auto_tlrc -base ~/SAM_BIU/docs/temp+tlrc -input warped+orig -no_ss
    
display('open a terminal and write the following commands:');
display(['cd ',pat]);
display('warp');
display('afni -R');
display('use switch session to go to all .svl files. choose:');
display('define data mode, plugins, dataset copy');
display('choose dataset (something.svl) give it a new name (func) and save');
display('then cd to SAM folders and run:')
display('@auto_tlrc -apar ../warped+tlrc -input func+orig -dxyz 5')
