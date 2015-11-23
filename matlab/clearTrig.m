function [newtrig]=clearTrig(trig,values)
if ~exist('values','var')
    values=[256,512,1024];
end
bits=log2(values)+1;
trigf=uint16(trig);
for biti=1:length(bits)
    trigf=bitset(trigf,bits(biti),0); 
end
% trigf=bitset(trigf,10,0);  %getting rid of trigger 512 (10)
% trigf=bitset(trigf,11,0);  %getting rid of trigger 1024 (11)
newtrig=single(trigf);
newtrig(newtrig>256)=0;
newtrigonset=newtrig(1,:);newtrigonset(1,1)=0;newtrigonset(1,2:end)=newtrigonset(1,2:end)-newtrigonset(1,1:(end-1));
newtrig=newtrigonset;
newtrig(newtrig<0)=0;
figure;plot(trig);hold on;plot(newtrig,'r');
end