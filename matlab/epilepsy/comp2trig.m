function trigger=comp2trig(comp,compNum)
% takes a FieldTrip comp structure (output of ft_componentanalysis), runs 
% a peak detection on specified components and writes the peaks (positive
% or negative, whichever there is more of) on the trigger channel. the 
% trigger value for a component is the component number.
% 
%%
trigger=zeros(1,size(comp.trial{1,1}(1,:),2));
for c=compNum
    [posPeak,negPeak]=peakDetection(comp.trial{1,1}(c,:),3);
    title(num2str(c))
    i=find(posPeak>0);
    n=find(negPeak<0);
    if sum(n>0)>sum(i>0)
        i=n;
    end
    %display(['found ',num2str(sum(i)),' spikes']);
    dif=diff(i);
    difi=find(dif<200);
    %display([num2str(size(difi,2)),' spikes were rejected , they were less than 200 samples after another spike'])
    trig=posPeak*c;
    for j=1:size(difi,2)  % deleting spikes 200 samples after other spikes
        trig(1,i(1,(j+1)))=0;
    end
    trig(1,(size(trig,2)+1))=0;
    trigger=trigger+trig;
end
% save([pat,'trigger'],'trigger')
% cd(pat);
% rewriteTrig(dataset,trigger,[]);
end

% [posPeak,negPeak]=YHpeakDetection(comp_orig.trial{1,1}(compNum,:),3);
% i=find(posPeak>0);
% display(['found ',num2str(sum(i)),'positive peaks']);
% dif=diff(i);
% difi=find(dif<200);
% display([num2str(size(difi,2)),' spikes were rejected , they were less than 200 samples after another spike'])
% trig=posPeak*10;
% for j=1:size(difi,2)  % deleting spikes 200 samples after other spikes
%     trig(1,i(1,(j+1)))=0;
% end
% trig(1,(size(trig,2)+1))=0;
% save([pat,'trig'],'trig')
% cd(pat);
% rewriteTrig(dataset,trig,[]);


