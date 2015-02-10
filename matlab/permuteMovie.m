function permuteMovie(varA,varB,Folder,mask,subBrik,pThr,sizeORt)
% permuteMovie('Ma_','Mw_',[],[],145:150,0.01,'both');
PWD=pwd;
if strcmp(PWD(end-3:end),'perm')
    cd ..
end
skip=[];
for briki=subBrik
    doPerm=true; % for this perm
    if isempty(skip)
        if exist(['s_',num2str(briki),'+tlrc.BRIK'],'file') || exist(['t_',num2str(briki),'+tlrc.BRIK'],'file')
            uinput = input('files exists, 1=overwrite, 2=skip: your choice?  ','s');
            switch uinput
                case '1'
                    skip=false;
                    doPerm=true;
                case '2'
                    skip=true;
                    doPerm=false;
            end
        end
    elseif exist(['s_',num2str(briki),'+tlrc.BRIK'],'file') || exist(['s_',num2str(briki),'+tlrc.BRIK'],'file')
        if skip
            doPerm=false;
        end
    end
    if doPerm
        disp(['subBrik ',num2str(briki),', last is ',num2str(subBrik(end))]);
        permuteBriks(varA,varB,Folder,mask,briki)
        cd perm
        !rm perm*+tlrc*
        permuteResults(pThr,sizeORt);
        switch sizeORt
            case 't'
                [~,w]=unix(['mv resultsT+tlrc.BRIK ../t_',num2str(briki),'+tlrc.BRIK']);
                [~,w]=unix(['mv resultsT+tlrc.HEAD ../t_',num2str(briki),'+tlrc.HEAD']);
            case 'size'
                [~,w]=unix(['mv resultsSize+tlrc.BRIK ../s_',num2str(briki),'+tlrc.BRIK']);
                [~,w]=unix(['mv resultsSize+tlrc.HEAD ../s_',num2str(briki),'+tlrc.HEAD']);
            case 'both'
                [~,w]=unix(['mv results+tlrc.BRIK ../b_',num2str(briki),'+tlrc.BRIK']);
                [~,w]=unix(['mv results+tlrc.HEAD ../b_',num2str(briki),'+tlrc.HEAD']);
                [~,w]=unix(['mv resultsT+tlrc.BRIK ../t_',num2str(briki),'+tlrc.BRIK']);
                [~,w]=unix(['mv resultsT+tlrc.HEAD ../t_',num2str(briki),'+tlrc.HEAD']);
                [~,w]=unix(['mv resultsSize+tlrc.BRIK ../s_',num2str(briki),'+tlrc.BRIK']);
                [~,w]=unix(['mv resultsSize+tlrc.HEAD ../s_',num2str(briki),'+tlrc.HEAD']);
        end
        cd ../
        
    end
end
[~, Info] = BrikLoad ([varA,'1+tlrc']);
Torg=num2str(Info.TAXIS_FLOATS(1)*1000); % FIXME when start not in brik zero...
TR=num2str(Info.TAXIS_FLOATS(2)*1000);
if strcmp(sizeORt,'t') || strcmp(sizeORt,'both')
    rmPrompt('T+tlrc')
    strT=['3dTcat -tr ',TR,' -prefix T '];
    for briki=subBrik
        strT=[strT,'t_',num2str(briki),'+tlrc[1] '];
    end
    [~,w]=unix(strT);
    if exist('T+tlrc.BRIK','file')
        %!rm t_*+tlrc*
        [~,w]=unix(['3drefit -Torg ',Torg,' T+tlrc'])
    else
        error('3dTcat failed?')
    end
    [V,Info] = BrikLoad ('T+tlrc');
    sig=squeeze(sum(sum(sum(V))));
    if(sum(sig)==0)
        disp('NOTHING for extreme T values')
    else
        disp(['some sig T results for sub-briks ',num2str(find(sig')+subBrik(1)-1)])
    end
end
if strcmp(sizeORt,'size') || strcmp(sizeORt,'both')
    rmPrompt('Size+tlrc')
    strS=['3dTcat -tr ',TR,' -prefix Size '];
    for briki=subBrik
        strS=[strS,'s_',num2str(briki),'+tlrc[1] '];
    end
    [~,w]=unix(strS);
    if exist('Size+tlrc.BRIK','file')
        %!rm s_*+tlrc*
        unix(['3drefit -Torg ',Torg,' Size+tlrc']);
    else
        error('3dTcat failed?')
    end
    [V,Info] = BrikLoad ('Size+tlrc');
    sig=squeeze(sum(sum(sum(V))));
    if(sum(sig)==0)
        disp('NOTHING for extreme cluster sizes')
    else
        disp(['some sig Size results for sub-briks ',num2str(find(sig')+subBrik(1)-1)])
    end
end
if strcmp(sizeORt,'both')
    rmPrompt('TandSize+tlrc')
    strB=['3dTcat -tr ',TR,' -prefix TandSize '];
    for briki=subBrik
        strB=[strB,'b_',num2str(briki),'+tlrc[1] '];
    end
    unix(strB);
    if exist('TandSize+tlrc.BRIK','file')
        unix(['3drefit -Torg ',Torg,' TandSize+tlrc']);
        %!rm b_*+tlrc*
    else
        error('3dTcat failed?')
    end
end

function rmPrompt(brikName)
if exist([brikName,'.BRIK'],'file')
    uinput = input([brikName,' exists, 1=overwrite, 2=abort: your choice?  '],'s');
    switch uinput
        case '1'
            unix(['rm ',brikName,'*']);
        case '2'
            disp('you can use 3dTcat to collect the files');
            return
    end
end