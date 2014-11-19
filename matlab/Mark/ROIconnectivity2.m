function connectivityStruct = ROIconnectivity2(mask1,mask2,data1,data2,weightFile,toi,sampRate,offset)

% This function performs connectivity analysis between two ROIs. It gets
% the names of two masks in talairach space, field-trip data structures of the 
% two conditions, weight file name, a time of interest, the sampling rate
% and the offset between the beginning of a trial and the actual time-zero. 
% as input arguments. The function performs the analysis between each voxel
% pair possible between ROIs and averages to get a mean PLI between ROIs.
% It outputs the avarage PLI and PC in both condition as well as the p value 
% obtained from the u-test. 


% Getting the voxels within the masks

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
seed1VS1 = cell(1,length(data1.trial{1}));
seed1Phase1 = cell(1,length(data1.trial{1}));
for i = 1:length(data1.trial)
    for j = 1:length(seed1)
        seed1VS1{i}(j,:) = (weights(seed1(j),:)./norm(weights(seed1(j),:)))*data1.trial{i}; % noise normalization
        seed1VS1{i}(j,:) = seed1VS1{i}(j,:) - mean(seed1VS1{i}(j,:)); % removing the mean
        seed1Phase1{i}(j,:) = phase(hilbert(seed1VS1{i}(j,timeWin(1)-20:timeWin(2)+20)));
    end
        
end
   
% Second ROI, first condition
seed2VS1 = cell(1,length(data1.trial{1}));
seed2Phase1 = cell(1,length(data1.trial{1}));
for i = 1:length(data1.trial)
    for j = 1:length(seed2)
        seed2VS1{i}(j,:) = (weights(seed2(j),:)./norm(weights(seed2(j),:)))*data1.trial{i}; % noise normalization
        seed2VS1{i}(j,:) = seed2VS1{i}(j,:) - mean(seed2VS1{i}(j,:)); % removing the mean
        seed2Phase1{i}(j,:) = phase(hilbert(seed2VS1{i}(j,timeWin(1)-20:timeWin(2)+20)));
    end
        
end

% First ROI, second condition
seed1VS2 = cell(1,length(data2.trial{1}));
seed1Phase2 = cell(1,length(data2.trial{1}));
for i = 1:length(data2.trial)
    for j = 1:length(seed1)
        seed1VS2{i}(j,:) = (weights(seed1(j),:)./norm(weights(seed1(j),:)))*data2.trial{i}; % noise normalization
        seed1VS2{i}(j,:) = seed1VS2{i}(j,:) - mean(seed1VS2{i}(j,:)); % removing the mean
        seed1Phase2{i}(j,:) = phase(hilbert(seed1VS2{i}(j,timeWin(1)-20:timeWin(2)+20)));
    end
        
end
   
% Second ROI, second condition
seed2VS2 = cell(1,length(data2.trial{1}));
seed2Phase2 = cell(1,length(data2.trial{1}));
for i = 1:length(data2.trial)
    for j = 1:length(seed2)
        seed2VS2{i}(j,:) = (weights(seed2(j),:)./norm(weights(seed2(j),:)))*data2.trial{i}; % noise normalization
        seed2VS2{i}(j,:) = seed2VS2{i}(j,:) - mean(seed2VS2{i}(j,:)); % removing the mean
        seed2Phase2{i}(j,:) = phase(hilbert(seed2VS2{i}(j,timeWin(1)-20:timeWin(2)+20)));
    end
        
end


%% Calculating connectivity and statistical analysis 
clear i


    
    % Calculating phase, PLI and PC for the first condition
    
    PLIcorrect = zeros(length(data1.trial),length(seed1),length(seed2));
    PCcorrect = zeros(length(data1.trial),length(seed1),length(seed2));
    for l = 1:length(data1.trial) 
        for j = 1:length(seed1)
            for k = 1:length(seed2)
                dPhaseCor = seed1Phase1{l}(j,21:length(seed1Phase1{l})-20)-seed2Phase1{l}(k,21:length(seed2Phase1{l})-20); % clear padding 
                PLIcorrect(l,j,k) = abs(mean(sign(sin(dPhaseCor))));
                PCcorrect(l,j,k) = abs(mean(exp(1i*(dPhaseCor))));
            end
        end
    end
    avgPLIcorrectTrials = mean(mean(PLIcorrect,3),2);
    avgPCcorrectTrials = mean(mean(PCcorrect,3),2);
    avgPLIcorrect = mean(avgPLIcorrectTrials);
    avgPCcorrect = mean(avgPCcorrectTrials);
    stdPLIcorrect = std(avgPLIcorrectTrials);
    stdPCcorrect = std(avgPCcorrectTrials);

    % Calculating phase, PLI and PC for the second condition
    
    PLImissed = zeros(length(data2.trial),length(seed1),length(seed2));
    PCmissed = zeros(length(data2.trial),length(seed1),length(seed2));
    for l = 1:length(data2.trial) 
        for j = 1:length(seed1)
            for k = 1:length(seed2)
                dPhaseCor = seed1Phase2{l}(j,21:length(seed1Phase2{l})-20)-seed2Phase2{l}(k,21:length(seed2Phase2{l})-20); % clear padding 
                PLImissed(l,j,k) = abs(mean(sign(sin(dPhaseCor))));
                PCmissed(l,j,k) = abs(mean(exp(1i*(dPhaseCor))));
            end
        end
    end
    avgPLImissedTrials = mean(mean(PLImissed,3),2);
    avgPCmissedTrials = mean(mean(PCmissed,3),2);
    avgPLImissed = mean(avgPLImissedTrials);
    avgPCmissed = mean(avgPCmissedTrials);
    stdPLImissed = std(avgPLImissedTrials);
    stdPCmissed = std(avgPCmissedTrials);
    
    % u-test
    
    utestPLI = ranksum(avgPLIcorrectTrials,avgPLImissedTrials);
    utestPC = ranksum(avgPCcorrectTrials,avgPCmissedTrials);
    

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


