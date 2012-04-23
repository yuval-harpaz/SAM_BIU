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
    p=find(posPeak>0);
    n=find(negPeak<0);
    i=p;
    trig=posPeak*c;
    if sum(n>0)>sum(p>0)
        i=n;
        trig=negPeak*c;
    end
    dif=diff(i);
    difi=find(dif<200);
    for j=1:size(difi,2)  % deleting spikes 200 samples after other spikes
        trig(1,i(1,(difi(j)+1)))=0;
    end
    trig(1,(size(trig,2)+1))=0;
    trigger=trigger+trig;
    hold on; plot(trig,'g')
    title(['ICA ',num2str(c),': ',num2str(size(find(trig),2)),' spikes remained (green)']);
    display([num2str(size(find(trig),2)),' spikes remained (green)']);
end

end
