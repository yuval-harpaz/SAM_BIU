function ns=normWts(covDir,wtsFile)
% give full paths to cov directory and weights file
% example:
% covDir='/home/yuval/Copy/social_motor_study/204707/SAM/AllTrials,3-35Hz';
% wtsFile='/home/yuval/Copy/social_motor_study/204707/SAM/AllTrials,3-35Hz,Alla.wts';

PWD=pwd;
[SAMHeader, ActIndex, ActWgts]=readWeights(wtsFile);
cd (covDir)
!~/bin/readcovBIU.py Noise.cov > noiseCov.txt
Cn=importdata('noiseCov.txt');
save noiseCov Cn
!rm noiseCov.txt
display(['running over ',num2str(size(ActWgts,1)),' voxels']);
ns=zeros(1,size(ActWgts,1));
for c=1:size(ActWgts,1)
    ActNse=0;
    CnCount=1;
    for i=1:248
        for j=1:248
            CnCount=CnCount+1;
            ActNse = ActNse + ActWgts(c,i) .* ActWgts(c,j) .* Cn(CnCount);
        end
    end
    ns(c)=ActNse; 
    if round(c/300)==c/300;
        display(num2str(c));
    end
end
ns=ns';
% save NoiseCovWts ns
boxSize=[...
    SAMHeader.XStart SAMHeader.XEnd ...
    SAMHeader.YStart SAMHeader.YEnd ...
    SAMHeader.ZStart SAMHeader.ZEnd];
% [-120 120 -90 90 -20 150];
cd (PWD)
if exist('NoiseCovWts+orig.BRIK','file')
    !rm NoiseCovWts+orig.BRIK
    !rm NoiseCovWts+orig.HEAD
end
cfg=[];
cfg.step=5;
cfg.boxSize=1000*boxSize;
cfg.prefix='NoiseCovWts';
VS2Brik(cfg,ns);