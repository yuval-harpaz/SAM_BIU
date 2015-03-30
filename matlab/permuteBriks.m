function permuteBriks(varA,varB,Folder,mask,subBrik,pThr)
% here we make permutations for two conditions per subjects, mixing the
% conditions randomly to find critical t value and cluster size.
% use 'Folder' when you have folders per subject with tlrc files that have the
% same name, like 'sub1/chicken+tlrc' 'sub2/chicken+tlrc' etc. in this example
% Folder='sub';varA='chikcen'; you also need varB.
% if you have all subjects in one directory called 'varA_1+tlrc'
% 'varA_2+tlrc' etc, then Folder=''; varA='varA_';
% subject numbers are added to the end of folder names if Folder isn't
% empty and to file names (varA and varB) otherwise.
% computes varA-varB !!! see 3dttest++ for setA-setB
% use a mask such as '~/SAM_BIU/docs/MASKctx' (default)
% if you have sub-bricks give us the indexof the one you want to test

%% setup parameters
% is the data in folders per subject or all subjects in one folder
if exist('Folder','var')
    if isempty(Folder)
        folders=false;
        Folder='';
    else
        folders=true;
    end
else
    folders=false;
    Folder='';
end
% check mask parameter
if ~exist('mask','var')
    mask='';
end
if isempty(mask)
    mask='~/SAM_BIU/docs/MASKctx';
end
if strcmp(mask(end-4:end),'+tlrc')
    mask=mask(1:end-5);
end
if ~exist('subBrik','var')
    subBrik='';
end
if isempty(subBrik)
    subBrik='';
else
    subBrik=['[',num2str(subBrik),']'];
end
PWD=pwd;
if strcmp(PWD(end-3:end),'perm')
    cd ../
end
if ~exist('perm','dir')
    mkdir('perm');
end
%% make a list of subjects
if folders
    list=ls ([Folder,'*'],'-d');
    spaces=findstr(' ',list);
    counter=1;
    stri=1;
    while stri<length(list+1)
        if ~ismember(stri,spaces)
            try
                Sub{counter}=[Sub{counter},list(stri)];
            catch
                Sub{counter}='';
                Sub{counter}=[Sub{counter},list(stri)];
            end
            if ismember(stri+1,spaces)
                counter=counter+1;
            end
        end
        stri=stri+1;
    end
else
    list=ls ([varA,'*+tlrc.BRIK']);
    a=findstr(varA,list);
    atlrc=findstr('+tlrc',list);
    if length(a)~=length(atlrc) || isempty(a)
        list=ls ([varA,'*+tlrc.BRIK']); % second try might work, you never know
        a=findstr(varA,list);
        atlrc=findstr('+tlrc',list);
        if length(a)~=length(atlrc) || isempty(a)
            error('problem finding subject number')
        end
    end
    for counter=1:length(a)
        Sub{counter}=list((a(counter)+length(varA)):atlrc(counter)-1);
    end
end
if ischar(varB)
    if strcmp(varB(1:10),'percentile')
        oneSet=true;
        perc=varB(11:end);
    else
        oneSet=false;
        if ~folders
            list=ls ([varB,'*+tlrc.BRIK']);
            b=findstr(varB,list);
            btlrc=findstr('+tlrc',list);
            if length(b)~=length(btlrc) || isempty(b)
                error('problem finding subject number')
            end
            for counter=1:length(b)
                SubB{counter}=list((b(counter)+length(varB)):btlrc(counter)-1);
            end
            if ~isequal(Sub,SubB)
                error('file names are not numbered the same for the two conditions')
            end
            clear SubB
        end
    end
else
    oneSet=true;
end

%% make a list of random shuffling of the conditions
n=length(Sub);
if n<12 % n=11 gives 1023 permutations, n=12 gives 2047 and then we choose 1000 randomly
    M = (dec2bin(0:(2^n)-1)=='1');
    M=M(2:2^(n-1),:);
    % if four
    %     M=M(find(sum(M')==4),:);
    % end
else
    M=round(rand(1500,n));
    M(sum(M,2)==n,:)=[];
    %M(find(sum(M')==n),:)=[];
    M=M(1:1000,:);
end
M=M+1;
clear a* b* counter
%% 3dttest++

Nperm=length(M);
fprintf(['performing ',num2str(Nperm),' permutations: '])
overwrite=false;
skip=false;
% remove constant from datasets when comparing one set to a constant
if oneSet
    BL=num2str(varB);
    for subi=1:n
        
        if exist('perc','var')
            [~,w]=afnix(['3dBrickStat -percentile ',perc,' 1 ',perc,' -non-zero BL_1+tlrc[1]']);
            bl=regexp(w,' ','split');
            BL=bl{2};
        end
        [~,w]=afnix(['3dcalc -prefix blc',Sub{subi},' -a ',varA,Sub{subi},'+tlrc -exp "a-',BL,'"']);
        [~,w]=afnix(['3dcalc -prefix blcNeg',Sub{subi},' -a blc',Sub{subi},'+tlrc -exp "-a"']);
    end
    vars={'blc','blcNeg'};
else
    vars={varA,varB};
end
for permi=1:Nperm
    strA=[' -setA ',varA];
    if oneSet
        strB='';
        str = ['~/abin/3dttest++ -mask ',mask,'+tlrc -prefix perm/perm',num2str(permi)];
    else
        strB=[' -setB ',varB];
        str = ['~/abin/3dttest++ -paired -no1sam -mask ',mask,'+tlrc -prefix perm/perm',num2str(permi)];
    end
    
    for subi=1:n
        if oneSet
            strA=[strA,' sub',Sub{subi},' ',vars{M(permi,subi)},Sub{subi},'+tlrc',subBrik];
        else
            strA=[strA,' sub',Sub{subi},' ',vars{M(permi,subi)},Sub{subi},'+tlrc',subBrik];
            strB=[strB,' sub',Sub{subi},' ',vars{abs(M(permi,subi)-3)},Sub{subi},'+tlrc',subBrik];
        end
    end
    command=[str,strA,strB];
    
    [~, w] = afnix(command);
    err=findstr('ERROR',w);
    if ~isempty(err)
        if strcmp(w((err(1)+7):(err(1)+25)),'output dataset name')
            if ~skip
                uinput = input('perm files exist, 1=overwrite, 2=skip, 3=abort: your choice?  ','s');
                switch uinput
                    case '1'
                        !rm perm/perm*+tlrc*
                        !rm perm/pos+tlrc*
                        !rm perm/neg+tlrc*
                        [~, w] = afnix(command);
                        err=findstr('ERROR',w);
                        if ~isempty(err)
                            error(w)
                        end
                    case '2'
                        skip=true;
                    case '3'
                        return
                end
            end
        else
            error(w(err:end));
        end
    end
    try
        progNum(permi)
    end
end
strA=[' -setA ',varA];
if oneSet
    strB='';
    str = ['~/abin/3dttest++ -mask ',mask,'+tlrc -prefix perm/realTest'];
else
    strB=[' -setB ',varB];
    str = ['~/abin/3dttest++ -paired -no1sam -mask ',mask,'+tlrc -prefix perm/realTest'];
end

for subi=1:n
    if oneSet
        strA=[strA,' sub',Sub{subi},' ',vars{1},Sub{subi},'+tlrc',subBrik];
    else
        strA=[strA,' sub',Sub{subi},' ',vars{1},Sub{subi},'+tlrc',subBrik];
        strB=[strB,' sub',Sub{subi},' ',vars{2},Sub{subi},'+tlrc',subBrik];
    end
end
command=[str,strA,strB];
if exist('perm/realTest+tlrc.BRIK','file')
    !rm perm/realTest+tlrc*
end
[~, w] = afnix(command);
if oneSet
    !rm blc*+tlrc*
end
cd perm
%% get crit T value
for permi=1:Nperm
    [~,t]=afnix(['~/abin/3dBrickStat -min -max perm',num2str(permi),'+tlrc','[1]']);
    newLines=regexp(t,'\n');
    if length(newLines)>1 % sometimes there are two rows due to impossible error, try again.
        [~,t]=afnix(['~/abin/3dBrickStat -min -max perm',num2str(permi),'+tlrc','[1]']);
    end
    try
        T(permi,1:2)=str2num(t);
    catch
        error(t); % for log full warnings and such
    end       
end
T=sort(abs(T(:)));
Tcrit=T(end-floor(length(T)/20)+1);
disp(['critical t-value is ',num2str(Tcrit)])
%% get crit clust size
if exist('pThr','var')
    if isempty(pThr)
        p=[0.01 0.025 0.05 0.1]; % try different threshold
    else
        p=pThr;
    end
else
    p=[0.01 0.025 0.05 0.1];
end
if oneSet
    Tthresholds=abs(tinv(p,n-1));
else
    Tthresholds=abs(tinv(p/2,n-1));
end
disp('looking for clusters')
for thri=1:length(p)
    for permi=1:Nperm
        tThresh=Tthresholds(thri);
        % compute volume of largest positive and negative clusters
        if exist('neg+tlrc.BRIK','file')
            !rm neg+tlrc*
        end
        if exist('pos+tlrc.BRIK','file')
            !rm pos+tlrc*
        end
        [~,~]=afnix(['~/abin/3dcalc -a perm',num2str(permi),'+tlrc''','[1]''',' -exp ''','ispositive(a-',num2str(tThresh),')*a''',' -prefix pos']);
        [~,~]=afnix(['~/abin/3dcalc -a perm',num2str(permi),'+tlrc''','[1]''',' -exp ''','isnegative(a+',num2str(tThresh),')*a''',' -prefix neg']);
        [~,negClust]=afnix(['~/abin/3dclust -quiet -1clip ',num2str(tThresh),' 5 125 neg+tlrc']);
        [~,posClust]=afnix(['~/abin/3dclust -quiet -1clip ',num2str(tThresh),' 5 125 pos+tlrc']);
        
        err=findstr('NO CLUSTERS FOUND',negClust); %#ok<*FSTR>
        if isempty(err)
            clust=negClust(findstr('Cox et al',negClust)+10:end);
            clust=regexp(clust,'\d+','match');
            negClustSize=str2num(clust{1})/125;
        else
            negClustSize=0;
        end
        err=findstr('NO CLUSTERS FOUND',posClust);
        if isempty(err)
            clust=posClust(findstr('Cox et al',posClust)+10:end);
            clust=regexp(clust,'\d+','match');
            posClustSize=str2num(clust{1})/125;
        else
            posClustSize=0;
        end
        clustSize(permi,1:2)=[negClustSize,posClustSize];
        if permi==1
            disp(' ');
            fprintf(['Threshold ',num2str(thri),' of ',num2str(length(p)),', permutation number '])
        end
        try
            progNum(permi)
        catch
            disp(['Threshold ',num2str(thri),' of ',num2str(length(p)),', permutation number ',num2str(permi)])
        end
    end
    clustSize=sort(clustSize(:));
    critClustSize(thri)=clustSize(floor(0.95*permi*2));
    clustSize=[];
    disp('')
end

permResults.Pthreshold=p;
permResults.Tthreshold=Tthresholds;
permResults.critClustSize=critClustSize;
permResults.critT=Tcrit;
permResults.variables.varA=varA;
permResults.variables.varB=varB;
permResults.variables.Folder=Folder;
permResults.variables.mask=mask;
permResults.variables.subBrik=subBrik;
str=datestr(now);
str=strrep(str,' ','_');
save(['permResults',str],'permResults')
% % dig in results
[~,w]=afnix('~/abin/3dBrickStat -min -max realTest+tlrc[1]');
tReal=str2num(w);
if -tReal(1)>Tcrit && ~oneSet
    disp(' ')
    disp(['most negative t (',num2str(tReal(1)),') is significant!'])
end
if tReal(2)>Tcrit
    disp(' ')
    disp(['most positive t (',num2str(tReal(2)),') is significant!'])
end

for thri=1:length(p)
    tThresh=Tthresholds(thri);
    % compute volume of largest positive and negative clusters
    if exist('neg+tlrc.BRIK','file')
        !rm neg+tlrc*
    end
    if exist('pos+tlrc.BRIK','file')
        !rm pos+tlrc*
    end
    [~,~]=afnix(['~/abin/3dcalc -a realTest+tlrc''','[1]''',' -exp ''','ispositive(a-',num2str(tThresh),')*a''',' -prefix pos']);
    if ~oneSet
        [~,~]=afnix(['~/abin/3dcalc -a realTest+tlrc''','[1]''',' -exp ''','isnegative(a+',num2str(tThresh),')*a''',' -prefix neg']);
        [~,negClust]=afnix(['~/abin/3dclust -quiet -1clip ',num2str(tThresh),' 5 125 neg+tlrc']);
        err=findstr('NO CLUSTERS FOUND',negClust); %#ok<*FSTR>
        if isempty(err)
        clust=negClust(findstr('Cox et al',negClust)+10:end);
        clust=regexp(clust,'\d+','match');
        negClustSize=str2num(clust{1})/125;
        else
            negClustSize=0;
        end
    end
    [~,posClust]=afnix(['~/abin/3dclust -quiet -1clip ',num2str(tThresh),' 5 125 pos+tlrc']);
    err=findstr('NO CLUSTERS FOUND',posClust);
    if isempty(err)
        clust=posClust(findstr('Cox et al',posClust)+10:end);
        clust=regexp(clust,'\d+','match');
        posClustSize=str2num(clust{1})/125;
    else
        posClustSize=0;
    end
    if oneSet
        clustSizeReal(thri,1:2)=[0,posClustSize];
    else
        clustSizeReal(thri,1:2)=[negClustSize,posClustSize];
    end
end
disp(' ')
if sum(clustSizeReal(:,1)>critClustSize')>0
    disp('largest negative cluster is significant!')
end
if sum(clustSizeReal(:,2)>critClustSize')>0
    disp('largest positive cluster is significant!')
end
disp('critical cluster size by threshold:')
disp(['threshold:p= ',num2str(p)])
disp(['threshold:t= ',num2str(Tthresholds)])
disp(['crit clust = ',num2str(critClustSize)])
disp('')
disp(['neg clust  = ',num2str(clustSizeReal(:,1)')])
disp(['pos clust  = ',num2str(clustSizeReal(:,2)')])

disp('summary saved as permResults:')
disp(permResults)
if oneSet
    disp(['reminder, positive means ',varA,' > ',num2str(varB),', negative means noise'])
else
    disp(['reminder, positive means ',varA,' > ',varB])
end
cd ..