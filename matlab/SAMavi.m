
sub='15';
source='xc,lf_c,rfhp0.1Hz';
pat='/home/avi/Desktop/BP';
cd([pat,'/',sub])
trig=readTrig_BIU(source);
trig=clearTrig(trig);
for trval=[52 200 204 208 212 54]
    time0=find(trig==trval)
    epoched=time0+1017:1017:time0+40*1017.25+5;
    epoched=epoched/1017.25;
    eval(['cond',num2str(trval),'=epoched;']);
end
save trials cond*
Trig2mark('rest1',cond52,'press1',cond200,'press2',cond204,'press3',cond208,'press4',cond212,'rest2',cond54)
fitMRI2hs(source);
!~/abin/3dWarp -deoblique T.nii
hs2afni
% NOW NUDGE
!~/abin/3dSkullStrip -input warped+orig -prefix mask -mask_vol -skulls -o_ply ortho
!meshnorm ortho.ply > hull.shape

MARK='rest1_9';Active='rest1';
createPARAM(MARK,'SPM',Active,[0 1],'',[],[7.5 10.5],[0 1],'Z-Test');
eval(['!SAMcov -r ',sub,' -d ',source,' -m ',MARK,' -v']);
eval(['!SAMwts -r ',sub,' -d ',source,' -m ',MARK,' -c ',Active,'a -v']);
eval(['!SAMspm -r ',sub,' -d ',source,' -m ',MARK,' -v']);
cd([sub,'/SAM']);system('cp rest*.svl ../');cd ../..

MARK='rest2_11';Active='rest2';
createPARAM(MARK,'SPM',Active,[0 1],'',[],[10.5 14.5],[0 1],'Z-Test');
eval(['!SAMcov -r ',sub,' -d ',source,' -m ',MARK,' -v']);
eval(['!SAMwts -r ',sub,' -d ',source,' -m ',MARK,' -c ',Active,'a -v']);
eval(['!SAMspm -r ',sub,' -d ',source,' -m ',MARK,' -v']);
cd([sub,'/SAM']);system('cp rest2*.svl ../');cd ../..

MARK='pressDiffp';Active='press1';Control='rest1';
createPARAM(MARK,'SPM',Active,[0 1],Control,[0 1],[10.5 14.5],[0 1],'Pseudo-Z');
eval(['!SAMcov -r ',sub,' -d ',source,' -m ',MARK,' -v']);
eval(['!SAMwts -r ',sub,' -d ',source,' -m ',MARK,' -c Sum -v']);
eval(['!SAMspm -r ',sub,' -d ',source,' -m ',MARK,' -v']);
cd([sub,'/SAM']);system('cp press*.svl ../');cd ../..


%~/Desktop/BP/15$ 3dcalc -a press1_11+orig -b rest1_11+orig -expr '100 *(a-b)/b ' -prefix percent_chng

% MARK='ERFemp';Active='Paina';
% eval(['!SAMcov -r ',sub,' -d ',source,' -m ',MARK,' -v']);
% eval(['!SAMwts -r ',sub,' -d ',source,' -m ',MARK,' -c ',Active,' -v']);
% eval(['!SAMerf -r ',sub,' -d ',source,' -m ',MARK,' -v']);
% 
% MARK='SPMemp';
% eval(['!SAMcov -r ',sub,' -d ',source,' -m ',MARK,' -v']);
% eval(['!SAMwts -r ',sub,' -d ',source,' -m ',MARK,' -c Sum -v']);
% eval(['!SAMspm -r ',sub,' -d ',source,' -m ',MARK,' -v']);
