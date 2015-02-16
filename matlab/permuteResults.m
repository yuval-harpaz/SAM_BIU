function permuteResults(pThr,sizeORt)
% runs on results of permuteBriks
% pThre is the threshold for clustering  0.05 or [0.01 0.025 0.05 0.1]
% (default).
% sizeORt - save voxels with sig big clusters 'size', extreme t values
% 't' or both 'both'
%% setup parameters
% is the data in folders per subject or all subjects in one folder
if exist('pThr','var')
    if isempty(pThr)
        pThr=[0.01 0.025 0.05 0.1];
    end
else
    pThr=[0.01 0.025 0.05 0.1];
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
for thri=1:length(pThr)
    tThresh=permResults.Tthreshold(ismember(permResults.Pthreshold,pThr(thri)));
    critSize=permResults.critClustSize(ismember(permResults.Pthreshold,pThr(thri)));
    critT=permResults.critT;
    
    %Tcrit=T(end-floor(length(T)/20)+1);
    %% get crit clust size
    %p=[0.01 0.025 0.05 0.1]; % try different threshold
    
    
    
    tThresh=floor(tThresh*1000)/1000; % to make it equal to clusterize GUI
    if ~exist('PermTemp+tlrc.BRIK','file')
        [~,w]=afnix('3dcalc -a realTest+tlrc -exp "a*0" -prefix PermTemp');
        [~,w]=afnix('3drefit -sublabel 1 noResults -sublabel 0 noResults PermTemp+tlrc');
    end
    strP=num2str(1-pThr(thri));
    if doSize
        if exist('resultsSize+tlrc.BRIK','file')
            [~,~]=afnix('rm resultsSize+tlrc*');
        end
        % save clusters as text for whereami and as BRIK
        [~,~]=afnix(['~/abin/3dclust -quiet -prefix resultsSize -nosum -1dindex 0 -1tindex 1 -2thresh -',num2str(tThresh),' ',num2str(tThresh),' -dxyz=1 1 ',num2str(critSize),' realTest+tlrc > resultsSize.txt']);
        % get text message without saving files
        [~,clust]=afnix(['~/abin/3dclust -quiet -nosum -1dindex 0 -1tindex 1 -2thresh -',num2str(tThresh),' ',num2str(tThresh),' -dxyz=1 1 ',num2str(critSize),' realTest+tlrc']);
        if ~isempty(findstr('NO CLUSTERS FOUND',clust)) %#ok<*FSTR>
            if exist('resultsSize+tlrc.BRIK','file')
                error('strange')
            else
                [~,~]=afnix('~/abin/3dcopy PermTemp+tlrc resultsSize+tlrc');
            end
        end
        [~,s]=afnix(['~/abin/3dcalc -prefix resultsSize',strP,' -a resultsSize+tlrc[1] -exp "ispositive(a)*',num2str(thri),'"']);
     
        %[~,~]=unix(['mv resultsSize+tlrc.Brik resultsSize',+tlrc.Brik'
    end
    
    if doT
        if thri==1;
            if exist('resultsT+tlrc.BRIK','file')
                [~,~]=unix('rm resultsT+tlrc*');
            end
            % not really clusters, just looking for all extreme points
            [~,~]=afnix(['~/abin/3dclust -quiet -prefix resultsT -nosum -1dindex 0 -1tindex 1 -2thresh -',num2str(critT),' ',num2str(critT),' -dxyz=1 1 1 realTest+tlrc > resultsT.txt']);
            [~,t]=afnix(['~/abin/3dclust -quiet -nosum -1dindex 0 -1tindex 1 -2thresh -',num2str(critT),' ',num2str(critT),' -dxyz=1 1 1 realTest+tlrc']);
            if ~isempty(findstr('NO CLUSTERS FOUND',t))
                if exist('resultsT+tlrc.BRIK','file')
                    error('strange')
                else
                    [~,~]=afnix('3dcopy PermTemp+tlrc resultsT+tlrc');
                end
            end
            [~,t]=afnix('~/abin/3dcalc -prefix resultsT -a resultsT+tlrc[1] -exp "ispositive(a)*"');
            %     [~,CMt]=unix('whereami -coord_file resultsT.txt[1,2,3] -tab -atlas TT_Daemon');
            %     [~,MIt]=unix('whereami -coord_file resultsT.txt[13,14,15] -tab -atlas TT_Daemon');
        end
    end
    % CM center of mass
    % MI maximum intensity
    
%     % combine images, if the same voxel is in both files include it only once
%     if doT && doSize
%         if exist('results+tlrc.BRIK','file')
%             [~,~]=unix('rm results+tlrc*');
%         end
%         [~,~]=unix('3dcalc -a resultsT+tlrc -b resultsSize+tlrc -prefix results -exp "a+b-a*equals(a,b)"');
%     end
%     [~,b]=unix(['~/abin/3dcalc -prefix results',strP,' -a results+tlrc[1] -exp "ispositive(a)*',strP,'"']);
     
end
OP.prefix='resultsSizeAll';
OP.view='tlrc';
OP.space='tlrc';
if doSize
    if size(pThr>1)
        for thri=1:length(pThr)
            strP=num2str(1-pThr(thri));
            [v,Info]=BrikLoad(['resultsSize',strP,'+tlrc']);
            if thri==1
                V=v;
            else
                if sum(v(:)>0)>0
                    V(v>0)=v(v>0);
                    %disp(['some results for ',num2str(pThr(thri)),' threshold'])
                end
            end 
        end
    end
    if sum(V(:)>0)==0
        Info.BRICK_LABS='Nada';
    else
        Info.BRICK_LABS='ThreshInd';
        %disp(['some results for ',num2str(pThr(thri)),' threshold'])
    end
    WriteBrik(V,Info,OP);
end
%!rm resultsSize*+tlrc*
cd (PWD)