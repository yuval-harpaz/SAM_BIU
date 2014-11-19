function connectivityStruct = seedConnectivityEnv(seed,data1,data2,weightFile,toi,AFNI,prefix,sampRate,offset,stats,varargin)

% This function performs connectivity analysis on the whole cortex. It gets
% a seed voxel in tlrc (LPI) coordinates, field-trip data structures of the 
% two conditions, weight file name, a time of interest, an option to create
%files for AFNI(1-create, 0-don't create), a prefix for the 
% to-be-created AFNI files, the sampling rate and the offset between the
% beginning of a trial and the actual time-zero as input. 
% It may also get a vector of indeces of voxels that reside in the cortex.
% The function outputs the avarage PLI and PC for each voxel in every condition. 
% It may also performs a u-test between conditions (if 'stats = 1'), voxel by voxel and outputs-
% (1 - p-value) and it creates brik files for Afni.

% Trasforming the seed coordinates to weights indeces

seed = tlrc2orig(seed);
seed = round(seed./5).*5;
seed = voxIndex(seed,[-120 120 -90 90 -20 150],5);

% Getting voxels which reside in the cortex
if nargin < 11
    !~megadmin/abin/3dmaskdump -noijk -xyz -mask MASKctx+tlrc 'MASKctx+tlrc' > cortexCoord.txt
    ctxCoord = importdata('cortexCoord.txt');
    ctxCoord(:,4) = [];
    ctxCoord(:,1:2) = ctxCoord(:,1:2)*(-1); % flipping from RAI to LPI
    ctxOrig = tlrc2orig(ctxCoord);
    ctxOrig = round(ctxOrig./5).*5; % round to the nearest voxel in 10mm intervals
    ctxind = voxIndex(ctxOrig,[-120 120 -90 90 -20 150],5);
    ctxind = unique(ctxind);
else
    ctxind = varargin{1};
end

% Reading the weights
cd SAM
[~, ~, weights] = readWeights(weightFile);
cd ..

% Getting the VS, performing hilbert transform, obtaining the instantaneous phase and the
% envelope of the seed voxel
timeWin = round(offset*sampRate + toi*sampRate);
load filtDataCoef

seedPhase1 = zeros(length(data1.trial),length(timeWin(1)-50:timeWin(2)+50));% padding with 50 samples
for i = 1:length(data1.trial)
    seedVS1 = (weights(seed,:)./norm(weights(seed,:)))*data1.trial{i}; % noise normalization
    seedVS1 = seedVS1 - mean(seedVS1); % removing the mean
    seedEnv1 = abs(hilbert(seedVS1)); % obtaining the envelope 
    tempPad = [ones(1,500)*seedEnv1(1) seedEnv1 ones(1,500)*seedEnv1(end)]; % padding before filtering
    y = filter(FiltData, tempPad);seedEnv1filtPad = fliplr(filter(FiltData,fliplr(y))); % filtering
    seedEnv1filt = seedEnv1filtPad(501:length(seedEnv1filtPad)-500); % removing padding
    seedPhase1(i,:) = phase(hilbert(seedEnv1filt(timeWin(1)-50:timeWin(2)+50))); % obtaining the phase
end

seedPhase2 = zeros(length(data2.trial),length(timeWin(1)-50:timeWin(2)+50));
for i = 1:length(data2.trial)
    seedVS2 = (weights(seed,:)./norm(weights(seed,:)))*data2.trial{i}; % noise normalization
    seedVS2 = seedVS2 - mean(seedVS2); % removing the mean
    seedEnv2 = abs(hilbert(seedVS2)); % obtaining the envelope 
    tempPad = [ones(1,500)*seedEnv2(1) seedEnv2 ones(1,500)*seedEnv2(end)]; % padding before filtering
    y = filter(FiltData, tempPad);seedEnv2filtPad = fliplr(filter(FiltData,fliplr(y))); % filtering
    seedEnv2filt = seedEnv2filtPad(501:length(seedEnv2filtPad)-500); % removing padding
    seedPhase2(i,:) = phase(hilbert(seedEnv2filt(timeWin(1)-50:timeWin(2)+50))); % obtaining the phase
end



%% Calculating connectivity and statistical analysis 

clear i

utestPLI = zeros(1,length(ctxind));
utestRankPLI = zeros(1,length(ctxind));
utestZvalPLI = zeros(1,length(ctxind));
utestPC = zeros(1,length(ctxind));
utestRankPC = zeros(1,length(ctxind));
utestZvalPC = zeros(1,length(ctxind));
utestPLI2 = zeros(1,length(ctxind));
utestPC2 = zeros(1,length(ctxind));

avgPLIcorrect = zeros(1,length(ctxind));
avgPCcorrect = zeros(1,length(ctxind));
avgPLImissed = zeros(1,length(ctxind));
avgPCmissed = zeros(1,length(ctxind));
stdPLIcorrect = zeros(1,length(ctxind));
stdPCcorrect = zeros(1,length(ctxind));
stdPLImissed = zeros(1,length(ctxind));
stdPCmissed = zeros(1,length(ctxind));

trlPLIcorrect = cell(1,length(ctxind));
trlPCcorrect = cell(1,length(ctxind));
trlPLImissed = cell(1,length(ctxind));
trlPCmissed = cell(1,length(ctxind));

for j = 1:length(ctxind)
    
    % Calculating phase, PLI and PC for the first condition
    bandPhase1 = zeros(length(data1.trial),length((timeWin(1)-50:timeWin(2)+50))); % padding with 50 samples
    dPhaseCor = zeros(length(data1.trial),length((timeWin(1):timeWin(2))));
    PLIcorrect = zeros(1,length(data1.trial));
    PCcorrect = zeros(1,length(data1.trial));
    for l = 1:length(data1.trial) 
        VS1 = (weights(ctxind(j),:)./norm(weights(ctxind(j),:)))*data1.trial{l}; % noise normalization
        VS1 = VS1 - mean(VS1); % removing the mean
        
        voxEnv1 = abs(hilbert(VS1)); % obtaining the envelope 
        tempPad = [ones(1,500)*voxEnv1(1) voxEnv1 ones(1,500)*voxEnv1(end)]; % padding before filtering
        y = filter(FiltData, tempPad);voxEnv1filtPad = fliplr(filter(FiltData,fliplr(y))); % filtering
        voxEnv1filt = voxEnv1filtPad(501:length(voxEnv1filtPad)-500); % removing padding
        
        bandPhase1(l,:) = phase(hilbert(voxEnv1filt(timeWin(1)-50:timeWin(2)+50)));
        dPhaseCor(l,:) = (seedPhase1(l,51:length(seedPhase1)-50)-bandPhase1(l,51:length(seedPhase1)-50)); % clear padding 
        PLIcorrect(l) = abs(mean(sign(sin(dPhaseCor(l,:)))));
        PCcorrect(l) = abs(mean(exp(1i*(dPhaseCor(l,:)))));
    end
    avgPLIcorrect(j) = mean(PLIcorrect);
    avgPCcorrect(j) = mean(PCcorrect);
    stdPLIcorrect(j) = std(PLIcorrect);
    stdPCcorrect(j) = std(PCcorrect);
    trlPLIcorrect{j} = PLIcorrect;
    trlPCcorrect{j} = PCcorrect;

    % Calculating phase, PLI and PC for the second condition
    bandPhase2 = zeros(length(data2.trial),length(timeWin(1)-50:timeWin(2)+50));
    dPhaseMis = zeros(length(data2.trial),length((timeWin(1):timeWin(2))));
    PLImissed = zeros(1,length(data2.trial));
    PCmissed = zeros(1,length(data2.trial));
    for l = 1:length(data2.trial) 
        VS2 = (weights(ctxind(j),:)./norm(weights(ctxind(j),:)))*data2.trial{l}; % noise normalization
        VS2 = VS2 - mean(VS2); % removing the mean
        
        voxEnv2 = abs(hilbert(VS2)); % obtaining the envelope 
        tempPad = [ones(1,500)*voxEnv2(1) voxEnv2 ones(1,500)*voxEnv2(end)]; % padding before filtering
        y = filter(FiltData, tempPad);voxEnv2filtPad = fliplr(filter(FiltData,fliplr(y))); % filtering
        voxEnv2filt = voxEnv2filtPad(501:length(voxEnv2filtPad)-500); % removing padding
        
        bandPhase2(l,:) = phase(hilbert(voxEnv2filt(timeWin(1)-50:timeWin(2)+50)));
        dPhaseMis(l,:) = (seedPhase2(l,51:length(seedPhase2)-50)-bandPhase2(l,51:length(seedPhase2)-50)); % clear padding 
        PLImissed(l) = abs(mean(sign(sin(dPhaseMis(l,:)))));
        PCmissed(l) = abs(mean(exp(1i*(dPhaseMis(l,:)))));
    end
    avgPLImissed(j) = mean(PLImissed);
    avgPCmissed(j) = mean(PCmissed);
    stdPLImissed(j) = std(PLImissed);
    stdPCmissed(j) = std(PCmissed);
    trlPLImissed{j} = PLImissed;
    trlPCmissed{j} = PCmissed;
    
    % u-test
    
    if stats == 1
    
        [utestPLI(j),~,tempStatPLI] = ranksum(PLIcorrect,PLImissed);
        utestRankPLI(j) = tempStatPLI.ranksum;
        utestZvalPLI(j) = tempStatPLI.zval;
        utestPLI2(j) = 1 - utestPLI(j); % 1- p-value
        if avgPLImissed(j) > avgPLIcorrect(j) % hypothesis direction
            utestPLI2(j) = (-1)*utestPLI2(j);
        end
        
        [utestPC(j),~,tempStatPC] = ranksum(PCcorrect,PCmissed);
        utestRankPC(j) = tempStatPC.ranksum;
        utestZvalPC(j) = tempStatPC.zval;
        utestPC2(j) = 1 - utestPC(j);% 1- p-value
        if avgPCmissed(j) > avgPCcorrect(j) % hypothesis direction
            utestPC2(j) = (-1)*utestPC2(j);
        end
    
    end
end

% Building the output structure

connectivityStruct.trlPLIcond1 = trlPLIcorrect;
connectivityStruct.trlPCcond1 = trlPCcorrect;
connectivityStruct.trlPLIcond2 = trlPLImissed;
connectivityStruct.trlPCcond2 = trlPCmissed;

connectivityStruct.avgPLIcond1 = avgPLIcorrect;
connectivityStruct.avgPCcond1 = avgPCcorrect;
connectivityStruct.avgPLIcond2 = avgPLImissed;
connectivityStruct.avgPCcond2 = avgPCmissed;
connectivityStruct.stdPLIcond1 = stdPLIcorrect;
connectivityStruct.stdPCcond1 = stdPCcorrect;
connectivityStruct.stdPLIcond2 = stdPLImissed;
connectivityStruct.stdPCcond2 = stdPCmissed;

if stats == 1
    connectivityStruct.uTestPvaluePLI = utestPLI;
    connectivityStruct.uTestPvaluePC = utestPC;
    connectivityStruct.uTestRanksumPLI = utestRankPLI;
    connectivityStruct.uTestRanksumPC = utestRankPC;
    connectivityStruct.uTestZvalPLI = utestZvalPLI;
    connectivityStruct.uTestZvalPC = utestZvalPC;
end

% Creating brik files for afni

if AFNI == 1
    cfg=[];
    cfg.step=5;
    cfg.boxSize=[-120 120 -90 90 -20 150];
    
    brikVSPLI = zeros(63455,1);
    brikVSPLI(ctxind) = utestPLI2;
    brikVSPC = zeros(63455,1);
    brikVSPC(ctxind) = utestPC2;
    
    eval(['cfg.prefix = ''' prefix 'PLI'';']);
    VS2Brik(cfg,brikVSPLI);
    eval(['cfg.prefix = ''' prefix 'PC'';']);
    VS2Brik(cfg,brikVSPC);
    
    % move to talairach space and multiply by a mask
    eval(['!@auto_tlrc -apar warped+tlrc -input ' prefix 'PLI+orig -dxyz 5'])
    eval(['!3dcalc -prefix ' prefix 'PLIctx -a MASKctx+tlrc -b ' prefix 'PLI+tlrc -datum float -exp ''a*b'''])
    eval(['!@auto_tlrc -apar warped+tlrc -input ' prefix 'PC+orig -dxyz 5'])
    eval(['!3dcalc -prefix ' prefix 'PCctx -a MASKctx+tlrc -b ' prefix 'PC+tlrc -datum float -exp ''a*b'''])
end

end


