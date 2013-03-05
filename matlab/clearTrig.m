function [newtrig]=clearTrig(trig)
warning('50Hz cleaning with cleanMEG pack will not be possible using the new trigger'); %#ok<WNTAG>
trig16=uint16(trig);
trigf=bitset(trig16,9,0); %getting rid of trigger 256 (9)
trigf=bitset(trigf,10,0);  %getting rid of trigger 512 (10)
trigf=bitset(trigf,11,0);  %getting rid of trigger 1024 (11)
newtrig=single(trigf);
newtrig(newtrig>256)=0;
newtrigonset=newtrig(1,:);newtrigonset(1,1)=0;newtrigonset(1,2:end)=newtrigonset(1,2:end)-newtrigonset(1,1:(end-1));
newtrig=newtrigonset;
newtrig(newtrig<0)=0;
figure;plot(trig);hold on;plot(newtrig,'r');
end