function [critT,stat,sigT]=permuteMat(varA,varB)
% every row is a subject, columns for channels



%% make a list of random shuffling of the conditions
n=size(varA,1);
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

Nperm=length(M);
fprintf(['performing ',num2str(Nperm),' permutations: '])
if ~exist('varB','var')
    varB='';
end
if isempty(varB)
    oneSet=true;
else
    oneSet=false;
end


% remove constant from datasets when comparing one set to a constant
if oneSet
    for permi=1:Nperm
        dataA=varA.*repmat(2.*(M(permi,:)-1.5)',1,size(varA,2));
        [~,~,~,stat]=ttest(dataA);
        T(permi,1)=min(stat.tstat);
        T(permi,2)=max(stat.tstat);
    end
else
    %vars={varA,varB};
    for permi=1:Nperm
        dataA=varA;
        dataA(M(permi,:)==2,:)=varB(M(permi,:)==2,:);
        dataB=varB;
        dataB(M(permi,:)==2,:)=varA(M(permi,:)==2,:);
        [~,~,~,stat]=ttest(dataA,dataB);
        T(permi,1)=min(stat.tstat);
        T(permi,2)=max(stat.tstat);
    end
end
T=sort(abs(T(:)),'descend');
critT=T(floor(0.05*(length(T))));

[~,~,~,stat]=ttest(varA,varB);
realT=stat.tstat;
sigT=find(abs(realT)>critT);

