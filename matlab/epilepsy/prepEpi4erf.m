% better run script in stages

%% 1) ICA for spike classification
%specify path and dataset filename

pat='';
dataset='c,rfhp1.0Hz,ee';
comp=epiFTica(pat,dataset,[],'M');
%% 2) create a trigger channel
% check the components with component browser.
% specify components 'compNum' to be written as triggers. try compNum=1:10 for start.
compNum=3;
trigger=comp2trig(comp,compNum);
%% 3) write the new trigger channel to file
% has to write one trigger value per file because SAM crashes when triggers
% overlap
% specify bad channels to be replaced by zeros.
if ~isempty(pat)
    cd(pat);
end
for i=1:size(compNum,2)
    trig=compNum(i)*(trigger==compNum(i));
    trig(1,1:200)=0;trig(1,(end-200):end)=0; %ignoring edges
    rewriteTrig(dataset,trig,['tf',num2str(compNum(i))],[]);
end
%%
% in a terminal run
% SAMwts -r b099 -d tf3_c,rfhp1.0Hz,ee -c Global,20-70Hz -C -Z -x "-10 10" -y "-9 9" -z "0 14" -s 0.5 -v
% SAMspm -r b099 -d tf3_c,rfhp1.0Hz,ee -a Global,0-100Hz,Global,ECD -c Global,0-100Hz,Global,ECD -m ica3 -D 1 -P -v
% SAMerf -r b099 -d tf3_c,rfhp1.0Hz,ee -w Global,0-100Hz,Global,ECD -m 3 -f "3 70" -v -t "-0.05 0.05" -b "-0.15 -0.05" -z 3

    
    