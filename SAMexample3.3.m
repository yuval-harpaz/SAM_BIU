trl=reindex(datacln.cfg.previous.trl,datacln.cfg.trl); % this is to get the 4th row of trl to the cleaned trl
trigTime=(trl(:,1)-trl(:,3))./1017.25; % correcting the offset and changing units from samples to seconds
NoPain=trigTime(find(trl(:,4)==240 |trl(:,4)==222),1); % unifying two conditions
Pain=trigTime(find(trl(:,4)==230 |trl(:,4)==250),1); 
Trig2mark('Pain',Pain','NoPain',NoPain'); % creating a marker file (MarkerFile.mrk)
fitMRI2hs('c,rfhp0.1Hz'); % creating an individual MRI from template
!~/abin/3dWarp -deoblique T.nii
hs2afni % converting the hs_file to afni format

% NOW NUDGE !!!

% after nudging: create a mask of the brain (ortho_brainhull.ply)
!~/abin/3dSkullStrip -input warped+orig -prefix mask -mask_vol -skulls -o_ply ortho 
!meshnorm ortho_brainhull.ply > hull.shape % saves the brainhull as hull.shape file.

% you need ERFemp.param for the next step, find it in SAM_BIU/docs
RUN='MOI715';DATA='c,rfhp0.1Hz';COV='Global';MARK='ERFemp';Active='Paina';
eval(['!SAMcov -r ',RUN,' -d ',DATA,' -m ',MARK,' -v']);
eval(['!SAMwts -r ',RUN,' -d ',DATA,' -m ',MARK,' -c ',Active,' -v']);
eval(['!SAMerf -r ',RUN,' -d ',DATA,' -m ',MARK,' -v']);

MARK='SPMemp';
eval(['!SAMcov -r ',RUN,' -d ',DATA,' -m ',MARK,' -v']);
eval(['!SAMwts -r ',RUN,' -d ',DATA,' -m ',MARK,' -c Sum -v']);
eval(['!SAMspm -r ',RUN,' -d ',DATA,' -m ',MARK,' -v']);
