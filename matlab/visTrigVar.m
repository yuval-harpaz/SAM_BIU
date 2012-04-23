function [meanDif,stdDif]=visTrigVar(trig,prestim)
% estimates the mean and std of the difference between the onset on the E'
% trigger and the onset of the visual trigger
% trig can be the output of readTrig_BIU
% prestim is in samples, not time (see fixVisTrig)
%%
tf=fixVisTrig(trig,prestim);
trig=uint16(trig);
trig=bitset(trig,9,0); %getting rid of trigger 256 (9)
trig=bitset(trig,10,0);  %getting rid of trigger 512 (10)
trig=bitset(trig,12,0);   %getting rid of trigger 2048 (12)
trigSh=zeros(size(trig));
trigSh(1,2:end)=trig(1:(end-1));
trig1st=trig-uint16(trigSh);
trig1=find(trig1st>0);
trig2=find(tf>0);
if size(trig1,2)~=size(trig2,2)
    error('number of triggers not the same on trig and fixed visual trig')
end
dif=trig2-trig1;
meanDif=mean(dif,2);
stdDif=std(dif);
end

