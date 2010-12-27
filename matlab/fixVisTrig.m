function [trigf,events]=fixVisTrig(trig,prestim);
% replacing visual signal (2048) with onsets and offsets
% changes values according to previous triger (sent by eprime,
% offset=onset+300)
% requires trig (output of readTrig_BIU) and prestim (number of points to look back for E' trigger) 
% NOTE, prestim is in samples, not time.
% event list is created with columns for trigger onset, trigger value and
% trigger offset.
%% 
warning('50Hz cleaning will not be possible after');
trig16=uint16(trig);
trigf=bitset(trig16,9,0); %getting rid of trigger 256 (9)
trigf=bitset(trigf,10,0);  %getting rid of trigger 512 (9)
vis=bitand(trigf,2048);   % reading the visual information
trigf=bitset(trigf,12,0);   %getting rid of trigger 2048 (12)
visonset=vis(1,:);visonset(1,1)=0;visonset(1,2:end)=visonset(1,2:end)-visonset(1,1:(end-1));
visoffset=vis(1,:);visoffset(1,end)=0;visoffset(1,1:(end-1))=visoffset(1,1:(end-1))-visoffset(1,2:end);
visonset=visonset==2048;visoffset=visoffset==2048;
onsets=find(visonset);offsets=find(visoffset);
newtrig=zeros(size(trigf));
events=[];
for i=1:size(onsets,2)
    ionset=onsets(1,i);
    if ionset>prestim
        [fstTrig,v]=find(fliplr(trigf((ionset-prestim):ionset)),1);
        tvalue=trigf(ionset-v+1);
        if tvalue>0;
            newtrig(1,ionset)=tvalue;
            events(i,1)=ionset;
            events(i,2)=tvalue;
            ioffset=find(offsets>ionset,1);
            newtrig(1,offsets(ioffset))=300+tvalue;
            events(i,3)=offsets(ioffset);
            tvalue=0;
         end
    end
end
end