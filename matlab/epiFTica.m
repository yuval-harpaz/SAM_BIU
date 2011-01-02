function [comp]=epiFTica(pat,dataset)
% YHepiFTpca
% FIXME allow EEG, get bad channel names
%pat='/media/D6A0A2E3A0A2C977/BF4clinic/b024/';
%dataset='c,rfhp1.0Hz,ee';
cfg1=[];
cfg1.dataset=[pat,dataset]; % change file name or path+name
cfg1.trialfun='YHbegtrialfun';
cfg2=definetrial(cfg1);
hdr=ft_read_header([pat,dataset]);
pts=hdr.orig.epoch_data.pts_in_epoch;
epochs=(floor(pts/hdr.Fs/5)); % to read 5s epochs
cfg2.channel='MEG';

cfg2.bpfilter='yes';
cfg2.bpfreq=[3 70];

for i=1:epochs 
    trl(i,1)=round((i*hdr.Fs-hdr.Fs)*5+1)
end
trl(:,2)=trl(:,1)+round(5*hdr.Fs);
trl(:,3)=zeros(size(trl,1),1);
cfg3=cfg2;
cfg3.trl=trl;

eEpi=preprocessing(cfg3);
%% comp analysis
% pca/ica
cfg4            = [];
comp_e = componentanalysis(cfg4, eEpi);
cfg5.layout='4D248.lay';
cfg5.comp=[1:10];
figure;
comppic=componentbrowser(cfg5,comp_e);
clear eEpi;
rawEpi=preprocessing(cfg2);

cfg6 = [];
cfg6.topo      = comp.topo;
cfg6.topolabel = comp.topolabel;
comp     = componentanalysis(cfg6, rawEpi);
save([pat,'comp'],'comp');
%%
trigger=zeros(1,size(comp.trial{1,1}(1,:),2));
for c=1:10
    [posPeak,negPeak]=peakDetection(comp_orig.trial{1,1}(c,:),3);
    title([num2str(c)])
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
end


