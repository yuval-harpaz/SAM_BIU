function connectivityStruct = ctxConnectivity10(data1,data2,weightFile,toi,sampRate,offset,alphaValue,stat,varargin)

% This function performs connectivity analysis on the whole cortex, between
% each voxel pair resized to 1cm^3 (LPI). It gets field-trip data structures of the 
% two conditions (filteresd), weight file name, a time of interest, sampling rate,
% the offset of the real zero from the beginning of the trial, the alpha value 
% for statistical analysis and an option to run statistical analysis (0-not
% statistical analysis, 1 - perform utest).
% It may also get a vector of indeces of voxel that reside in the cortes.
% The function outputs the avarage PLI and PC for each voxel in every condition. 
% It also performs a u-test between conditions, voxel by voxel and outputs-
% (1 - p-value) and it creates brik files for Afni.


% Getting voxels which reside in the cortex
% if nargin ~= 9 
%     !~megadmin/abin/3dmaskdump -noijk -xyz -mask ctxMask10mm+tlrc 'ctxMask10mm+tlrc' > cortexCoord10.txt
%     ctxCoord = importdata('cortexCoord10.txt');
%     ctxCoord(:,4) = [];
%     ctxCoord(:,1:2) = ctxCoord(:,1:2)*(-1); % flipping from RAI to LPI
%     ctxOrig = tlrc2orig(ctxCoord);
%     ctxOrig = round(ctxOrig./10).*10; % round to the nearest voxel in 10mm intervals
%     ctxind = voxIndex(ctxOrig,[-120 120 -90 90 -20 150],10);
%     ctxind = unique(ctxind);
% else
%     ctxind = varargin{1};
% end

% Reading the weights
cd SAM
[~, ~, weights] = readWeights(weightFile);
cd ..

% Transforming the time window to samples
timeWin = round(offset*sampRate + toi*sampRate);

% Calculating virtual sensors
% VScond1 = calcVS(weights,data1,1,ctxind);
% VScond2 = calcVS(weights,data2,1,ctxind);

VScond1 = cell(1,length(data1.trial));
for i = 1:length(data1.trial)
    VScond1{i} = weights*data1.trial{i};
    for j = 1:length(weights)
        normWgts = norm(weights(j,:));
        VScond1{i}(j,:) = VScond1{i}(j,:)./normWgts; % noise normalization
        VScond1{i}(j,:) = VScond1{i}(j,:) - mean(VScond1{i}(j,:)); % removing the mean
    end
end

VScond2 = cell(1,length(data2.trial));
for i = 1:length(data2.trial)
    VScond2{i} = weights*data2.trial{i};
    for j = 1:length(weights)
        normWgts = norm(weights(j,:));
        VScond2{i}(j,:) = VScond2{i}(j,:)./normWgts; % noise normalization
        VScond2{i}(j,:) = VScond2{i}(j,:) - mean(VScond2{i}(j,:)); % removing the mean
    end
end
%% Calculating connectivity and statistical analysis 
clear i

utestPLI = zeros(length(weights));
utestZvalPLI = zeros(length(weights));
utestPC = zeros(length(weights));
utestZvalPC = zeros(length(weights));

avgPLIcorrect = zeros(length(weights));
avgPCcorrect = zeros(length(weights));
avgPLImissed = zeros(length(weights));
avgPCmissed = zeros(length(weights));
stdPLIcorrect = zeros(length(weights));
stdPCcorrect = zeros(length(weights));
stdPLImissed = zeros(length(weights));
stdPCmissed = zeros(length(weights));

% trlPLIcorrect = cell(length(ctxind));
% trlPCcorrect = cell(length(ctxind));
% trlPLImissed = cell(length(ctxind));
% trlPCmissed = cell(length(ctxind));

for j = 1:length(weights) % loop over voxels
    for k = 1:length(weights) % loop over voxels
        
        % Calculating phase, PLI and PC for the first condition

        PLIcorrect = zeros(1,length(data1.trial));
        PCcorrect = zeros(1,length(data1.trial));
        
        for l = 1:length(data1.trial) % loop over trials
            bandPhase1 = phase(hilbert(VScond1{l}(j,timeWin(1)-20:timeWin(2)+20))); % padding with 20 samples, voxel 1
            bandPhase2 = phase(hilbert(VScond1{l}(k,timeWin(1)-20:timeWin(2)+20))); % padding with 20 samples, voxel 2
            dPhaseCor = (bandPhase1(21:length(bandPhase1)-20) - bandPhase2(21:length(bandPhase2)-20)); % clear padding, phase difference
            PLIcorrect(l) = abs(mean(sign(sin(dPhaseCor))));
            PCcorrect(l) = abs(mean(exp(1i*(dPhaseCor))));
        end
        
        avgPLIcorrect(j,k) = mean(PLIcorrect);
        avgPCcorrect(j,k) = mean(PCcorrect);
        stdPLIcorrect(j,k) = std(PLIcorrect);
        stdPCcorrect(j,k) = std(PCcorrect);
%         trlPLIcorrect{j,k} = PLIcorrect;
%         trlPCcorrect{j,k} = PCcorrect;
        
        % Calculating phase, PLI and PC for the second condition
        
        PLImissed = zeros(1,length(data2.trial));
        PCmissed = zeros(1,length(data2.trial));
        
        for l = 1:length(data2.trial) % loop over trials
            bandPhase1 = phase(hilbert(VScond2{l}(j,timeWin(1)-20:timeWin(2)+20))); % padding with 20 samples, voxel 1
            bandPhase2 = phase(hilbert(VScond2{l}(k,timeWin(1)-20:timeWin(2)+20))); % padding with 20 samples, voxel 2
            dPhaseMis = (bandPhase1(21:length(bandPhase2)-20) - bandPhase2(21:length(bandPhase2)-20)); % clear padding, phase difference
            PLImissed(l) = abs(mean(sign(sin(dPhaseMis))));
            PCmissed(l) = abs(mean(exp(1i*(dPhaseMis))));
        end
        
        avgPLImissed(j,k) = mean(PLImissed);
        avgPCmissed(j,k) = mean(PCmissed);
        stdPLImissed(j,k) = std(PLImissed);
        stdPCmissed(j,k) = std(PCmissed);
%         trlPLImissed{j,k} = PLImissed;
%         trlPCmissed{j,k} = PCmissed;
        
        % u-test
        if stat == 1
            [utestPLI(j,k),~,tempStatPLI] = ranksum(PLIcorrect,PLImissed);
            utestZvalPLI(j,k) = tempStatPLI.zval;
            if utestPLI(j,k) > alphaValue
                utestZvalPLI(j,k) = 0; % nullifying values below alpha-Value
            end
            
            [utestPC(j,k),~,tempStatPC] = ranksum(PCcorrect,PCmissed);
            utestZvalPC(j,k) = tempStatPC.zval;
            if utestPC(j,k) > alphaValue
                utestZvalPC(j,k) = 0; % nullifying values below alpha-Value
            end
        end
    end
end

% Building the output structure

% connectivityStruct.trlPLIcond1 = trlPLIcorrect;
% connectivityStruct.trlPCcond1 = trlPCcorrect;
% connectivityStruct.trlPLIcond2 = trlPLImissed;
% connectivityStruct.trlPCcond2 = trlPCmissed;

connectivityStruct.avgPLIcond1 = avgPLIcorrect;
connectivityStruct.avgPCcond1 = avgPCcorrect;
connectivityStruct.avgPLIcond2 = avgPLImissed;
connectivityStruct.avgPCcond2 = avgPCmissed;
connectivityStruct.stdPLIcond1 = stdPLIcorrect;
connectivityStruct.stdPCcond1 = stdPCcorrect;
connectivityStruct.stdPLIcond2 = stdPLImissed;
connectivityStruct.stdPCcond2 = stdPCmissed;

if stat == 1
    
    connectivityStruct.uTestPvaluePLI = utestPLI;
    connectivityStruct.uTestPvaluePC = utestPC;
    connectivityStruct.uTestZvalPLI = utestZvalPLI;
    connectivityStruct.uTestZvalPC = utestZvalPC;


    % visualization
    
    figure
    imagesc(utestPLI)
    colorbar
    title('PLI u-test p-values')
    
    figure
    imagesc(utestPC)
    colorbar
    title('PC u-test p-values')
    
    figure
    imagesc(utestZvalPLI)
    colorbar
    title('PLI u-test z-values')
    
    figure
    imagesc(utestZvalPC)
    colorbar
    title('PC u-test z-values')
end

end
