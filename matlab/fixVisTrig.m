function [newtrig,events]=fixVisTrig(trig,prestim,onORoffset,alltrigs)
% replacing visual signal (2048) with onsets or offsets
% changes values according to previous triger (sent by eprime)
% requires trig (output of readTrig_BIU) and prestim (number of sample points to look back for E' trigger) 
% NOTE, prestim is in samples, not time.
% onORoffset specifies whether to write trigger values at the visual
% trigger onsets or offsets (default - onset)
% event list is created with columns for trigger onset, trigger value and
% trigger offset.
% alltrigs: in order to mark all trials (to run ICA on all conditions for example)
% 10 samples before every visual trigger the specified value (alltrigs) is added to newtrig.
% for standart visual experiments run as
% [newtrig,events]=fixVisTrig(trig,102,'onset',1);
%% 
if isempty(onORoffset)
    onORoffset='onset';
end
    
warning('50Hz cleaning with cleanMEG pack will not be possible using the new trigger'); %#ok<WNTAG>
trig16=uint16(trig);
trigf=bitset(trig16,9,0); %getting rid of trigger 256 (9)
trigf=bitset(trigf,10,0);  %getting rid of trigger 512 (10)
%trigf=bitset(trigf,11,0);  %getting rid of trigger 1024 (11)
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
            ioffset=find(offsets>ionset,1);
            if strcmp(onORoffset,'onset');
                newtrig(1,ionset)=tvalue;
            elseif strcmp(onORoffset,'offset');
                newtrig(1,offsets(ioffset))=tvalue;
            end
            events(i,1)=ionset; %#ok<AGROW>
            events(i,2)=tvalue; %#ok<AGROW>
            events(i,3)=offsets(ioffset); %#ok<AGROW>
            tvalue=0; %#ok<NASGU>
        end
    end
end
if exist('alltrigs','var')
    if ~isempty(alltrigs)
        trigs=find(newtrig>0);
        newtrig(1,trigs-10)=alltrigs;
    end
end
figure;plot(trig);hold on;plot(newtrig,'r');
end