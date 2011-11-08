function vsZ=zScoreVS(vs)
sd=std(vs');sd=sd'; % computing SD to make z score channels.
meanVS=mean(vs,2); % calculating mean for z score
for i=2:size(vs,2)
    sd(:,i)=sd(:,1);
    meanVS(:,i)=meanVS(:,1);
end
vsZ=(vs-meanVS)./sd;