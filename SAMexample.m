%% SAM beamforming using matlan
% the script runs SAM with '!' which means that it is a system command
% (linux) and doesn't really run on MATLAB. the use of matlab simplifies
% the application for many subjects and for putting the right names of
% newly created files in the command lines. 
% it assumes one set of filters for the whole analysis though one can use
% different filters, say 1-70Hz for SAMcov and then 8-15Hz for SAMerf.
% also note that some options are constant such as -z (3) for SAMerf or -C for SAMwts.
% to see the different options write !SAMwts, !SAMcov etc.
%%
source='c,rfhp0.1Hz';
pat='/media/D6A0A2E3A0A2C977/Pnaming/data';
%load([pat,'/groups']);
groups=[1:8];
groups(2,:)=1;
% newName='alpha'; filt='8 15'; newName='beta'; filt='15 25'; newName='gamma'; filt='25 60';
filt='8 60';
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
trigVals=202;
startt=0.12;endt=0.54;startb=-0.2;endb=0.05;
% SAM_erf(pat,source,groups,filt,trigVals,startt,endt,startb,endb);
%% SAMspm
% set active and control time windows and trigger values.
cd(pat)
textFile='Pname';
% if exist(textFile,'file')==2
%     eval(['!rm ',textFile])
% end
% startAct=startt;endAct=endt;
trigValAct=trigVals;
% startCont=startb;endCont=endb;
trigValCont=trigVals;
% eval(['!echo 1 >> ',textFile]);
% eval(['!echo ',num2str(trigValAct),' ',num2str(startAct),' ',num2str(endAct),' >> ',textFile]);
% eval(['!echo 1 >> ',textFile]);
% eval(['!echo ',num2str(trigValCont),' ',num2str(startCont),' ',num2str(endCont),' >> ',textFile]);
% all frequencies
SAM_spm(pat,source,groups,filt,textFile);

%% get svl files out of SAM folders
cd(pat)
for i=1:8
    cd(num2str(i))
    eval(['!mv SAM/',textFile,'* ./'])
    cd ..
end
%% making a text file 'svl2tlrc' to run in terminal for transforming the svl to tlairach space

% newName='alpha'; filt='8 15'; newName='beta'; filt='15 25'; newName='gamma'; filt='25 60';
filtstr=str2num(filt);
svlName=[textFile,',',num2str(filtstr(1,1)),'-',num2str(filtstr(1,2)),'Hz,',num2str(trigValAct),'-',num2str(trigValCont),',Tp.svl'];
svl2tlrc(pat,groups,svlName,newName)
%% command for grand averaging 
%3dmerge -gmean -1noneg -1clip 0.05*max0 -1thresh 0.1 -1blur_fwhm 5 -prefix all 1/all1+tlrc 2/all2+tlrc 3/all3+tlrc 4/all4+tlrc 5/all5+tlrc 6/all6+tlrc 7/all7+tlrc 8/all8+tlrc
SET='';
for i=find(groups(2,:)>0)
    I=num2str(i);
    SET=[SET,' ',I,'/',newName,I,'+tlrc'];
end

merge3d=['3dmerge -gmean -1noneg -1clip 0.05*max0 -1thresh 0.1 -1blur_fwhm 5 -prefix ',newName,SET];
display('run this in a terminal:');
eval(['!echo ',merge3d]);
%% commands for ttest
% 3dttest -base1 0 -set2 1/all1+tlrc 2/all2+tlrc 3/all3+tlrc 4/all4+tlrc 5/all5+tlrc 6/all6+tlrc 7/all7+tlrc 8/all8+tlrc 
% 3dttest -set1 sub1cond1+tlrc sub2con1+tlrc sub3cond1+tlrc -set2 sub1cond2+tlrc sub2cond2+tlrc  sub2cond2+tlrc -paired
ttest3d=['3dttest -base1 0 -set2',SET];
mvbrick=['mv tdif+tlrc.BRIK t',newName,'+tlrc.BRIK'];
mvhead=['mv tdif+tlrc.HEAD t',newName,'+tlrc.HEAD'];
% display('run these command in a terminal');
eval(['!echo ',ttest3d]);
eval(['!echo ',mvbrick]);
eval(['!echo ',mvhead]);
eval('!echo " "');
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
