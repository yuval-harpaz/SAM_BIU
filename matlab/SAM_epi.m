function kur=SAM_epi(weights,source,TimeInt)
% gives g2 excess kurtosis estimate by sliding window, similar tp SAMepi
% give it the names of the weight file and data file
FIXME I started with kur1.m and stopped working on this function
for ti=1:9
    lat(ti)=2^(ti-4);
    samps=round(678.17*lat(ti));
    segBeg=1:round(samps/2):length(vsR);
    segBeg=segBeg(1:end-2);
    X=[];
    for segi=1:length(segBeg)
        X(segi,1:samps)=vsR(segBeg(segi):(segBeg(segi)+samps-1));
    end
    g=G2(X);
    maxG2(ti)=max(g);
    sumG2(ti)=sum(g(find(g>1)));
end
maxG2
meanG2
