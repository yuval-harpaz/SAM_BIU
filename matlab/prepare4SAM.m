patient='b026';

sr=678.17;
source='c,rfhp1.0Hz,ee';
eval(['cd /media/D6A0A2E3A0A2C977/BF4clinic/',patient])
trig=readTrig_BIU(source);
trig=zeros(size(trig));
trig(1,6782)=10;
rewriteTrig(source,trig,[74 204]);
cd ..
