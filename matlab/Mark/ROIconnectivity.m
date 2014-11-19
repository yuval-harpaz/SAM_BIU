function connectivityStruct = ROIconnectivity(mask1,mask2,data1,data2,weightFile,toi,sampRate,offset)

% This function performs connectivity analysis between two ROIs. It gets
% the names of two masks in talairach space, field-trip data structures of the 
% two conditions, weight file name, a time of interest, the sampling rate 
% and the offset between the beginning of a trial and the actual time-zero 
% as input arguments. The function finds the voxels of maximal power in each
% mask and performs connectivity analysis between them. It outputs the 
% avarage PLI and PC in both condition as well as the p value obtained from the u-test. 


% Getting voxels of maximal power within the masks

eval(['!~megadmin/abin/3dmaskdump -noijk -xyz -mask ' mask1 '+tlrc ''' mask1 '+tlrc'' > mask1.txt'])
eval(['seed1 = importdata(''mask1.txt'');'])
eval(['!~megadmin/abin/3dmaskdump -noijk -xyz -mask ' mask2 '+tlrc ''' mask2 '+tlrc'' > mask2.txt'])
eval(['seed2 = importdata(''mask2.txt'');'])

seed1(:,4) = [];
seed2(:,4) = [];
seed1(:,1:2) = seed1(:,1:2)*(-1); % flipping from RAI to LPI
seed2(:,1:2) = seed2(:,1:2)*(-1);

seed1 = tlrc2orig(seed1); % getting the index
seed2 = tlrc2orig(seed2);
seed1 = round(seed1./5).*5;
seed2 = round(seed2./5).*5;
seed1 = voxIndex(seed1,[-120 120 -90 90 -20 150],5);
seed2 = voxIndex(seed2,[-120 120 -90 90 -20 150],5);
seed1 = unique(seed1);
seed2 = unique(seed2);

% Reading the weights
cd SAM
[~, ~, weights] = readWeights(weightFile);
cd ..

% Finding the voxel of maximal power within the mask.
% Performing hilbert transform and obtaining the instantaneous phase of the voxel

timeWin = round(offset*sampRate + toi*sampRate);

% First ROI, first condition
seed1VS1 = zeros(length(seed1),length(data1.trial{1}));
powseed1VS1 = zeros(length(data1.trial),length(seed1));
for i = 1:length(data1.trial)
    for j = 1:length(seed1)
        seed1VS1(j,:) = (weights(seed1(j),:)./norm(weights(seed1(j),:)))*data1.trial{i}; % noise normalization
        seed1VS1(j,:) = seed1VS1(j,:) - mean(seed1VS1(j,:)); % removing the mean
        powseed1VS1(i,j) = mean(seed1VS1(j,:).^2);
    end
        
end
meanpowseed1VS1 = mean(powseed1VS1);
maxseed1VS1 = find(meanpowseed1VS1 == max(meanpowseed1VS1));

seed1Phase1 = zeros(length(data1.trial),length(timeWin(1)-20:timeWin(2)+20));
for i = 1:length(data1.trial)
    seed1VS1 = (weights(seed1(maxseed1VS1),:)./norm(weights(seed1(maxseed1VS1),:)))*data1.trial{i};
    seed1VS1 = seed1VS1 - mean(seed1VS1);
    seed1Phase1(i,:) = phase(hilbert(seed1VS1(timeWin(1)-20:timeWin(2)+20)));
end
   
% Second ROI, first condition
seed2VS1 = zeros(length(seed2),length(data1.trial{1}));
powseed2VS1 = zeros(length(data1.trial),length(seed2));
for i = 1:length(data1.trial)
    for j = 1:length(seed2)
        seed2VS1(j,:) = (weights(seed2(j),:)./norm(weights(seed2(j),:)))*data1.trial{i}; % noise normalization
        seed2VS1(j,:) = seed2VS1(j,:) - mean(seed2VS1(j,:)); % removing the mean
        powseed2VS1(i,j) = mean(seed2VS1(j,:).^2);
    end
        
end
meanpowseed2VS1 = mean(powseed2VS1);
maxseed2VS1 = find(meanpowseed2VS1 == max(meanpowseed2VS1));

seed2Phase1 = zeros(length(data1.trial),length(timeWin(1)-20:timeWin(2)+20));
for i = 1:length(data1.trial)
    seed2VS1 = (weights(seed2(maxseed2VS1),:)./norm(weights(seed2(maxseed2VS1),:)))*data1.trial{i};
    seed2VS1 = seed2VS1 - mean(seed2VS1);
    seed2Phase1(i,:) = phase(hilbert(seed2VS1(timeWin(1)-20:timeWin(2)+20)));
end

% First ROI, second condition
seed1VS2 = zeros(length(seed1),length(data2.trial{1}));
powseed1VS2 = zeros(length(data2.trial),length(seed1));
for i = 1:length(data2.trial)
    for j = 1:length(seed1)
        seed1VS2(j,:) = (weights(seed1(j),:)./norm(weights(seed1(j),:)))*data2.trial{i}; % noise normalization
        seed1VS2(j,:) = seed1VS2(j,:) - mean(seed1VS2(j,:)); % removing the mean
        powseed1VS2(i,j) = mean(seed1VS2(j,:).^2);
    end
        
end
meanpowseed1VS2 = mean(powseed1VS2);
maxseed1VS2 = find(meanpowseed1VS2 == max(meanpowseed1VS2));

seed1Phase2 = zeros(length(data2.trial),length(timeWin(1)-20:timeWin(2)+20));
for i = 1:length(data2.trial)
    seed1VS2 = (weights(seed1(maxseed1VS2),:)./norm(weights(seed1(maxseed1VS2),:)))*data2.trial{i};
    seed1VS2 = seed1VS2 - mean(seed1VS2);
    seed1Phase2(i,:) = phase(hilbert(seed1VS2(timeWin(1)-20:timeWin(2)+20)));
end
   
% Second ROI, second condition
seed2VS2 = zeros(length(seed2),length(data2.trial{1}));
powseed2VS2 = zeros(length(data2.trial),length(seed2));
for i = 1:length(data2.trial)
    for j = 1:length(seed2)
        seed2VS2(j,:) = (weights(seed2(j),:)./norm(weights(seed2(j),:)))*data2.trial{i}; % noise normalization
        seed2VS2(j,:) = seed2VS2(j,:) - mean(seed2VS2(j,:)); % removing the mean
        powseed2VS2(i,j) = mean(seed2VS2(j,:).^2);
    end
        
end
meanpowseed2VS2 = mean(powseed2VS2);
maxseed2VS2 = find(meanpowseed2VS2 == max(meanpowseed2VS2));

seed2Phase2 = zeros(length(data2.trial),length(timeWin(1)-20:timeWin(2)+20));
for i = 1:length(data2.trial)
    seed2VS2 = (weights(seed2(maxseed2VS2),:)./norm(weights(seed2(maxseed2VS2),:)))*data2.trial{i};
    seed2VS2 = seed2VS2 - mean(seed2VS2);
    seed2Phase2(i,:) = phase(hilbert(seed2VS2(timeWin(1)-20:timeWin(2)+20)));
end


%% Calculating connectivity and statistical analysis 
clear i
    
    % Calculating phase, PLI and PC for the first condition
    dPhaseCor = zeros(length(data1.trial),length((timeWin(1):timeWin(2))));
    PLIcorrect = zeros(1,length(data1.trial));
    PCcorrect = zeros(1,length(data1.trial));
    for l = 1:length(data1.trial) 
        dPhaseCor(l,:) = (seed1Phase1(l,21:length(seed1Phase1)-20)-seed2Phase1(l,21:length(seed2Phase1)-20)); % clear padding 
        PLIcorrect(l) = abs(mean(sign(sin(dPhaseCor(l,:)))));
        PCcorrect(l) = abs(mean(exp(1i*(dPhaseCor(l,:)))));
    end
    avgPLIcorrect = mean(PLIcorrect);
    avgPCcorrect = mean(PCcorrect);
    stdPLIcorrect = std(PLIcorrect);
    stdPCcorrect = std(PCcorrect);

    % Calculating phase, PLI and PC for the second condition
    dPhaseMis = zeros(length(data2.trial),length((timeWin(1):timeWin(2))));
    PLImissed = zeros(1,length(data2.trial));
    PCmissed = zeros(1,length(data2.trial));
    for l = 1:length(data2.trial) 
        dPhaseMis(l,:) = (seed1Phase2(l,21:length(seed1Phase2)-20)-seed2Phase2(l,21:length(seed2Phase2)-20)); % clear padding 
        PLImissed(l) = abs(mean(sign(sin(dPhaseMis(l,:)))));
        PCmissed(l) = abs(mean(exp(1i*(dPhaseMis(l,:)))));
    end
    avgPLImissed = mean(PLImissed);
    avgPCmissed = mean(PCmissed);
    stdPLImissed = std(PLImissed);
    stdPCmissed = std(PCmissed);
    
    % u-test
    
    utestPLI = ranksum(PLIcorrect,PLImissed);
    utestPC = ranksum(PCcorrect,PCmissed);
    

% Building the output structure
connectivityStruct.avgPLIcond1 = avgPLIcorrect;
connectivityStruct.avgPCcond1 = avgPCcorrect;
connectivityStruct.avgPLIcond2 = avgPLImissed;
connectivityStruct.avgPCcond2 = avgPCmissed;
connectivityStruct.stdPLIcond1 = stdPLIcorrect;
connectivityStruct.stdPCcond1 = stdPCcorrect;
connectivityStruct.stdPLIcond2 = stdPLImissed;
connectivityStruct.stdPCcond2 = stdPCmissed;
connectivityStruct.uTestPLI = utestPLI;
connectivityStruct.uTestPC = utestPC;

% Bar plot

% figure
% bar([avgPLIcorrect avgPLImissed],0.6)
% hold on
% errorbar([avgPLIcorrect avgPLImissed],[stdPLIcorrect./sqrt(length(data1.trial)) stdPLImissed./sqrt(length(data2.trial))],'k','linestyle','none')
% set(gca,'xticklabel',{'correct','missed'})
% title('average PLI')
% ylabel('PLI')
% 
% figure
% bar([avgPCcorrect avgPCmissed],0.6)
% hold on
% errorbar([avgPCcorrect avgPCmissed],[stdPCcorrect./sqrt(length(data1.trial)) stdPCmissed./sqrt(length(data2.trial))],'k','linestyle','none')
% set(gca,'xticklabel',{'correct','missed'})
% title('average PC')
% ylabel('PC')


end


