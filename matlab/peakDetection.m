function [posPeak,negPeak]=peakDetection(channel,threshold);
% channel can be any time series- EEG MEG ICA... intended for ICA.
% threshold is number of SDs to count as peak. 3 is recommended for
% epilepsy.
channel=channel/(std(channel));
channel1bck=zeros(1,size(channel,2));
channel1bck(1,1:(end-1))=channel(1,2:end);
a=channel(1,:)>threshold;
b=channel(1,:)>channel1bck;
c=a+b;
c=c==2;
d=(c(2:end)-c(1:(end-1))==1);
figure;plot(channel(1,:),'k');hold on;plot((d*threshold),'r');
posPeak=d;
a1=channel(1,:)<(-1*threshold);
b1=channel(1,:)<channel1bck;
c1=a1+b1;
c1=c1==2;
d1=(c1(2:end)-c1(1:(end-1))==1)*(-1);
plot((d1*threshold),'b');
legend('channel',[num2str(sum(d)),' positive peaks'],[num2str(sum((-1)*d1)),' negative peaks'])
negPeak=d1;
end