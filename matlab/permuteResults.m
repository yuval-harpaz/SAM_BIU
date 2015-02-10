function permuteResults(pThr,sizeORt)
% runs on results of permuteBriks
% pThre is the threshold for clustering
% sizeORt - save voxels with sig big clusters ('size'), extreme t values
% ('t') or both ('both')
%% setup parameters
% is the data in folders per subject or all subjects in one folder
if exist('pThr','var')
    if isempty(pThr)
        pThr=0.05;
    end
else
    pThr=0.05;
end
% check mask parameter
if ~exist('sizeORt','var')
    sizeORt='';
end
if isempty(sizeORt)
    sizeORt='both';
end
PWD=pwd;
if ~strcmp(PWD(end-3:end),'perm')
    try
        cd perm
    catch
        disp('where is perm folder?')
    end
end
doSize=false;
doT=false;
switch sizeORt
    case 't'
        doT=true;
    case 'size'
        doSize=true;
    case 'both';
        doT=true;
        doSize=true;
end
        
%% get results
LS=ls('permResults*','-t'); % sort results to take last run
permResults=(LS(1:strfind(LS,'.mat')-1));
permResults=load(permResults);
permResults=permResults.permResults;
tThresh=permResults.Tthreshold(ismember(permResults.Pthreshold,pThr));
critSize=permResults.critClustSize(ismember(permResults.Pthreshold,pThr));
critT=permResults.critT;

%Tcrit=T(end-floor(length(T)/20)+1);
%% get crit clust size
%p=[0.01 0.025 0.05 0.1]; % try different threshold



tThresh=floor(tThresh*1000)/1000; % to make it equal to clusterize GUI
if ~exist('PermTemp+tlrc.BRIK','file')
    [~,w]=unix('3dcalc -a realTest+tlrc -exp "a*0" -prefix PermTemp');
end
if doSize
    if exist('resultsSize+tlrc.BRIK','file')
        [~,~]=unix('rm resultsSize+tlrc*');
    end
    % save clusters as text for whereami and as BRIK 
    [~,~]=unix(['~/abin/3dclust -quiet -prefix resultsSize -nosum -1dindex 0 -1tindex 1 -2thresh -',num2str(tThresh),' ',num2str(tThresh),' -dxyz=1 1 ',num2str(critSize),' realTest+tlrc > resultsSize.txt']);
    % get text message without saving files
    [~,clust]=unix(['~/abin/3dclust -quiet -nosum -1dindex 0 -1tindex 1 -2thresh -',num2str(tThresh),' ',num2str(tThresh),' -dxyz=1 1 ',num2str(critSize),' realTest+tlrc']);
%     [~,CMsize]=unix('whereami -coord_file resultsSize.txt[1,2,3] -tab -atlas TT_Daemon');
%     [~,MIsize]=unix('whereami -coord_file resultsSize.txt[13,14,15] -tab -atlas TT_Daemon');
%     !3dExtrema -sep_dist 30 -closure -volume resultsSize+tlrc[1] > max.txt
%     !3dExtrema -sep_dist 30 -closure -volume -minima resultsSize+tlrc[1] > min.txt
%     [~,minSize]=unix('whereami -coord_file min.txt[2,3,4] -tab -atlas TT_Daemon');
%     [~,minSize]=unix('3dExtrema -sep_dist 30 -closure -volume -minima resultsSize+tlrc[1]')
    if ~isempty(findstr('NO CLUSTERS FOUND',clust))
        if exist('resultsSize+tlrc.BRIK','file')
            error('strange')
        else
            unix('3dcopy PermTemp+tlrc resultsSize+tlrc');
        end
    end
end
if doT
    if exist('resultsT+tlrc.BRIK','file')
        [~,~]=unix('rm resultsT+tlrc*');
    end
    % not really clusters, just looking for all extreme points
    [~,~]=unix(['~/abin/3dclust -quiet -prefix resultsT -nosum -1dindex 0 -1tindex 1 -2thresh -',num2str(critT),' ',num2str(critT),' -dxyz=1 1 1 realTest+tlrc > resultsT.txt']);
    [~,t]=unix(['~/abin/3dclust -quiet -nosum -1dindex 0 -1tindex 1 -2thresh -',num2str(critT),' ',num2str(critT),' -dxyz=1 1 1 realTest+tlrc']);
    if ~isempty(findstr('NO CLUSTERS FOUND',t))
        if exist('resultsT+tlrc.BRIK','file')
            error('strange')
        else
            unix('3dcopy PermTemp+tlrc resultsT+tlrc');
        end
    end
%     [~,CMt]=unix('whereami -coord_file resultsT.txt[1,2,3] -tab -atlas TT_Daemon');
%     [~,MIt]=unix('whereami -coord_file resultsT.txt[13,14,15] -tab -atlas TT_Daemon');
end
% CM center of mass
% MI maximum intensity

% combine images, if the same voxel is in both files include it only once
if doT && doSize
    if exist('results+tlrc.BRIK','file')
        [~,~]=unix('rm results+tlrc*');
    end
    [~,~]=unix('3dcalc -a resultsT+tlrc -b resultsSize+tlrc -prefix results -exp "a+b-a*equals(a,b)"');
end
    
    


cd (PWD)