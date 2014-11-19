%% Running connectivity analysis

% make sure you have the mask files 'MASKctx+tlrc.BRIK' and
% 'MASKctx+tlrc.HEAD' in you folder.

% example of seed connectivity
Rfusiformseed0812 = seedConnectivity(Rfusiform,correct0812,missed0812,'preStimConn0812,8-12Hz,Sum.wts',[-0.5 0],1,'Rfusiformseed0812',678.17,0.8);


% example of whole cortex connectivity

% first, run these lines
[vol,grid,mesh,M1]=headmodel_BIU('xc,hb,lf_c,rfhp0.1Hz',[],10,'ctx','localspheres');
load ~/ft_BIU/matlab/files/sMRI.mat
mri_realign=sMRI;
mri_realign.transform=inv(M1)*sMRI.transform;
grid2t(grid);
!cp pnt.txt SAM/pnt.txt

% make sure that the image step in the param file is 1 (BV stands for big voxels) 
!SAMcov -r sub22 -d xc,hb,lf_c,rfhp0.1Hz -m preStimAlpha_BV -v 
!SAMwts -r sub22 -d xc,hb,lf_c,rfhp0.1Hz -m preStimAlpha_BV -c Sum -t pnt.txt -b Global -v

% the connectivity function
connec0812 = ctxConnectivity10(correct0812,missed0812,'pnt.txt.wts',[-0.5 0],678.17,0.8,0.0005,0);



% group statistics for seed connectivity

correctAlphaPLIStr = '';
missedAlphaPLIStr = '';
correctAlphaPCStr = '';
missedAlphaPCStr = '';

cfg=[];
cfg.step=5;
cfg.boxSize=[-120 120 -90 90 -20 150];
for s = 1:22
    eval(['cd sub' num2str(s)])
    
    %!~megadmin/abin/3dmaskdump -noijk -xyz -mask MASKctx+tlrc 'MASKctx+tlrc' > cortexCoord.txt
    ctxCoord = importdata('cortexCoord.txt');
    ctxCoord(:,4) = [];
    ctxCoord(:,1:2) = ctxCoord(:,1:2)*(-1); % flipping from RAI to LPI
    ctxOrig = tlrc2orig(ctxCoord);
    ctxOrig = round(ctxOrig./5).*5; % round to the nearest voxel in 5mm intervals
    ctxind = voxIndex(ctxOrig,[-120 120 -90 90 -20 150],5);
    ctxind = unique(ctxind);
    
    eval(['load connectivity1325env_sub' num2str(s) ])
    
    brikVSPLIcorr = zeros(63455,1);
    eval(['brikVSPLIcorr(ctxind) = RfusiformSeed1325env_sub' num2str(s) '.avgPLIcond1;'])
    brikVSPLImiss = zeros(63455,1);
    eval(['brikVSPLImiss(ctxind) = RfusiformSeed1325env_sub' num2str(s) '.avgPLIcond2;'])
    brikVSPCcorr = zeros(63455,1);
    eval(['brikVSPCcorr(ctxind) = RfusiformSeed1325env_sub' num2str(s) '.avgPCcond1;'])
    brikVSPCmiss = zeros(63455,1);
    eval(['brikVSPCmiss(ctxind) = RfusiformSeed1325env_sub' num2str(s) '.avgPCcond2;'])
    
    eval(['cfg.prefix = ''correctAlphaPLIsub' num2str(s) ''';'])
    VS2Brik(cfg,brikVSPLIcorr);
    eval(['cfg.prefix = ''missedAlphaPLIsub' num2str(s) ''';'])
    VS2Brik(cfg,brikVSPLImiss);
    eval(['cfg.prefix = ''correctAlphaPCsub' num2str(s) ''';'])
    VS2Brik(cfg,brikVSPCcorr);
    eval(['cfg.prefix = ''missedAlphaPCsub' num2str(s) ''';'])
    VS2Brik(cfg,brikVSPCmiss);
    
    eval(['!@auto_tlrc -apar warped+tlrc -input correctAlphaPLIsub' num2str(s) '+orig -dxyz 5'])
    eval(['!@auto_tlrc -apar warped+tlrc -input missedAlphaPLIsub' num2str(s) '+orig -dxyz 5'])
    eval(['!@auto_tlrc -apar warped+tlrc -input correctAlphaPCsub' num2str(s) '+orig -dxyz 5'])
    eval(['!@auto_tlrc -apar warped+tlrc -input missedAlphaPCsub' num2str(s) '+orig -dxyz 5'])
    
    correctAlphaPLIStr = sprintf('%s correctAlphaPLIsub%s+tlrc',correctAlphaPLIStr, num2str(s));
    missedAlphaPLIStr = sprintf('%s missedAlphaPLIsub%s+tlrc',missedAlphaPLIStr, num2str(s));
    correctAlphaPCStr = sprintf('%s correctAlphaPCsub%s+tlrc',correctAlphaPCStr, num2str(s));
    missedAlphaPCStr = sprintf('%s missedAlphaPCsub%s+tlrc',missedAlphaPCStr, num2str(s));
    
    eval(['!cp correctAlphaPLIsub' num2str(s) '+tlrc* //media/Mark/Mark/MEG_data/grands/seedConnectivityAlpha'])
    eval(['!cp missedAlphaPLIsub' num2str(s) '+tlrc* //media/Mark/Mark/MEG_data/grands/seedConnectivityAlpha'])
    eval(['!cp correctAlphaPCsub' num2str(s) '+tlrc* //media/Mark/Mark/MEG_data/grands/seedConnectivityAlpha'])
    eval(['!cp missedAlphaPCsub' num2str(s) '+tlrc* //media/Mark/Mark/MEG_data/grands/seedConnectivityAlpha'])
    
    cd ..
end

cd grands
cd seedConnectivityAlpha

eval(['!3dttest++ -paired -prefix ttestAlphaPLI -mask MASKctx+tlrc -setA' correctAlphaPLIStr ' -setB' missedAlphaPLIStr ]) 
eval(['!3dttest++ -paired -prefix ttestAlphaPC -mask MASKctx+tlrc -setA' correctAlphaPCStr ' -setB' missedAlphaPCStr ])



%% Group statistics and visualizations for whole cortex connectivity

for s = 1:22
    eval(['cd sub' num2str(s) ])
    load connec0713
    eval(['connec0713sub' num2str(s) ' = connec0713;'])
    clear connec0713
    cd ..
end


tic
pValMatPLI = zeros(931,931);
uValMatPLI = zeros(931,931);
pValMatPC = zeros(931,931);
uValMatPC = zeros(931,931);
for xi = 1:931
    for yi = 1:931
        for subi = 1:22
            eval(['corrVecPLI(' num2str(subi) ') = connec0713sub' num2str(subi) '.avgPLIcond1(' num2str(xi) ',' num2str(yi) ');'])
            eval(['missVecPLI(' num2str(subi) ') = connec0713sub' num2str(subi) '.avgPLIcond2(' num2str(xi) ',' num2str(yi) ');'])
            eval(['corrVecPC(' num2str(subi) ') = connec0713sub' num2str(subi) '.avgPCcond1(' num2str(xi) ',' num2str(yi) ');'])
            eval(['missVecPC(' num2str(subi) ') = connec0713sub' num2str(subi) '.avgPCcond2(' num2str(xi) ',' num2str(yi) ');'])
        end
        [pValMatPLI(xi,yi),~,tempStat] = ranksum(corrVecPLI,missVecPLI);
        uValMatPLI(xi,yi) = tempStat.ranksum;
        [pValMatPC(xi,yi),~,tempStat] = ranksum(corrVecPC,missVecPC);
        uValMatPC(xi,yi) = tempStat.ranksum;
    end
end
toc


% grand average

connec0713grandCorrPLI = (connec0713sub1.avgPLIcond1 + connec0713sub2.avgPLIcond1 + connec0713sub3.avgPLIcond1 + connec0713sub4.avgPLIcond1 + connec0713sub5.avgPLIcond1 + connec0713sub6.avgPLIcond1 + connec0713sub7.avgPLIcond1 + connec0713sub8.avgPLIcond1 + connec0713sub9.avgPLIcond1 + connec0713sub10.avgPLIcond1 + connec0713sub11.avgPLIcond1 + connec0713sub12.avgPLIcond1 + connec0713sub13.avgPLIcond1 + connec0713sub14.avgPLIcond1 + connec0713sub15.avgPLIcond1 + connec0713sub16.avgPLIcond1 + connec0713sub17.avgPLIcond1 + connec0713sub18.avgPLIcond1 + connec0713sub19.avgPLIcond1 + connec0713sub20.avgPLIcond1 + connec0713sub21.avgPLIcond1 + connec0713sub22.avgPLIcond1)./22;
connec0713grandMissPLI = (connec0713sub1.avgPLIcond2 + connec0713sub2.avgPLIcond2 + connec0713sub3.avgPLIcond2 + connec0713sub4.avgPLIcond2 + connec0713sub5.avgPLIcond2 + connec0713sub6.avgPLIcond2 + connec0713sub7.avgPLIcond2 + connec0713sub8.avgPLIcond2 + connec0713sub9.avgPLIcond2 + connec0713sub10.avgPLIcond2 + connec0713sub11.avgPLIcond2 + connec0713sub12.avgPLIcond2 + connec0713sub13.avgPLIcond2 + connec0713sub14.avgPLIcond2 + connec0713sub15.avgPLIcond2 + connec0713sub16.avgPLIcond2 + connec0713sub17.avgPLIcond2 + connec0713sub18.avgPLIcond2 + connec0713sub19.avgPLIcond2 + connec0713sub20.avgPLIcond2 + connec0713sub21.avgPLIcond2 + connec0713sub22.avgPLIcond2)./22;
connec0713grandCorrPC = (connec0713sub1.avgPCcond1 + connec0713sub2.avgPCcond1 + connec0713sub3.avgPCcond1 + connec0713sub4.avgPCcond1 + connec0713sub5.avgPCcond1 + connec0713sub6.avgPCcond1 + connec0713sub7.avgPCcond1 + connec0713sub8.avgPCcond1 + connec0713sub9.avgPCcond1 + connec0713sub10.avgPCcond1 + connec0713sub11.avgPCcond1 + connec0713sub12.avgPCcond1 + connec0713sub13.avgPCcond1 + connec0713sub14.avgPCcond1 + connec0713sub15.avgPCcond1 + connec0713sub16.avgPCcond1 + connec0713sub17.avgPCcond1 + connec0713sub18.avgPCcond1 + connec0713sub19.avgPCcond1 + connec0713sub20.avgPCcond1 + connec0713sub21.avgPCcond1 + connec0713sub22.avgPCcond1)./22;
connec0713grandMissPC = (connec0713sub1.avgPCcond2 + connec0713sub2.avgPCcond2 + connec0713sub3.avgPCcond2 + connec0713sub4.avgPCcond2 + connec0713sub5.avgPCcond2 + connec0713sub6.avgPCcond2 + connec0713sub7.avgPCcond2 + connec0713sub8.avgPCcond2 + connec0713sub9.avgPCcond2 + connec0713sub10.avgPCcond2 + connec0713sub11.avgPCcond2 + connec0713sub12.avgPCcond2 + connec0713sub13.avgPCcond2 + connec0713sub14.avgPCcond2 + connec0713sub15.avgPCcond2 + connec0713sub16.avgPCcond2 + connec0713sub17.avgPCcond2 + connec0713sub18.avgPCcond2 + connec0713sub19.avgPCcond2 + connec0713sub20.avgPCcond2 + connec0713sub21.avgPCcond2 + connec0713sub22.avgPCcond2)./22;

save ctxConnecAlpha uValMatPLI uValMatPC pValMatPLI pValMatPC connec0713grandCorrPLI connec0713grandMissPLI connec0713grandCorrPC connec0713grandMissPC


% Setting a threshold and splitting into two directions

alpha = 0.0025;

sigMatPLIpos = zeros(931,931);
sigMatPLIneg = zeros(931,931);
sigMatPCpos = zeros(931,931);
sigMatPCneg = zeros(931,931);
for xi = 1:931
    for yi = 1:931
        if pValMatPLIalpha(xi,yi) < alpha
            if connec0713grandCorrPLI(xi,yi) > connec0713grandMissPLI(xi,yi)
                sigMatPLIpos(xi,yi) = pValMatPLIalpha(xi,yi);
            elseif connec0713grandCorrPLI(xi,yi) < connec0713grandMissPLI(xi,yi)
                sigMatPLIneg(xi,yi) = pValMatPLIalpha(xi,yi);
            end
        end
        if pValMatPCalpha(xi,yi) < alpha
            if connec0713grandCorrPC(xi,yi) > connec0713grandMissPC(xi,yi)
                sigMatPCpos(xi,yi) = pValMatPCalpha(xi,yi);
            elseif connec0713grandCorrPC(xi,yi) < connec0713grandMissPC(xi,yi)
                sigMatPCneg(xi,yi) = pValMatPCalpha(xi,yi);
            end
        end
    end
end

posChangePLI = find(sigMatPLIpos);
negChangePLI = find(sigMatPLIneg);
posChangePC = find(sigMatPCpos);
negChangePC = find(sigMatPCneg);


% Finding hubs

hubsPLIpos = zeros(1,931);
hubsPLIneg = zeros(1,931);
hubsPCpos = zeros(1,931);
hubsPCneg = zeros(1,931);
for i = 1:931
    hubsPLIpos(i) = length(find(sigMatPLIpos(i,:)));
    hubsPLIneg(i) = length(find(sigMatPLIneg(i,:)));
    hubsPCpos(i) = length(find(sigMatPCpos(i,:)));
    hubsPCneg(i) = length(find(sigMatPCneg(i,:)));
end

hubNumPLIpos = prctile(hubsPLIpos,97.5);
hubNumPLIneg = prctile(hubsPLIneg,97.5);
hubNumPCpos = prctile(hubsPCpos,97.5);
hubNumPCneg = prctile(hubsPCneg,97.5);

hubListPLIpos = find(hubsPLIpos>hubNumPLIpos);
hubListPLIneg = find(hubsPLIneg>hubNumPLIneg);
hubListPCpos = find(hubsPCpos>hubNumPCpos);
hubListPCneg = find(hubsPCneg>hubNumPCneg);


% 3D ploting

load bnd.mat
bnd.tri=bnd.face;
bnd.pnt=bnd.vert;

load templateGrid

figure
ft_plot_mesh(bnd,'facealpha',0.05,'edgecolor','none', 'facecolor', 'black', 'edgealpha', 0.05);
hold on

for i = 1:length(posChangePLI)
    tempX = rem(posChangePLI(i),931);
    if tempX == 0
        tempX = 931;
    end
    tempY = ceil(posChangePLI(i)/931);
    
    plot3([template_grid.pos(template_grid.inside(tempX),1) template_grid.pos(template_grid.inside(tempY),1)],...
    [template_grid.pos(template_grid.inside(tempX),2) template_grid.pos(template_grid.inside(tempY),2)],...
    [template_grid.pos(template_grid.inside(tempX),3) template_grid.pos(template_grid.inside(tempY),3)],'r') 
    title('PLI in correct condition')
end

% Adding hubs
for i = 1:length(hubListPLIpos)
    scatter3(template_grid.pos(template_grid.inside(hubListPLIpos(i)),1), template_grid.pos(template_grid.inside(hubListPLIpos(i)),2),...
        template_grid.pos(template_grid.inside(hubListPLIpos(i)),3), 32, 'g', 'filled')
end


figure
ft_plot_mesh(bnd,'facealpha',0.05,'edgecolor','none', 'facecolor', 'black', 'edgealpha', 0.05);
hold on

for i = 1:length(negChangePLI)
    tempX = rem(negChangePLI(i),931);
    if tempX == 0
        tempX = 931;
    end
    tempY = ceil(negChangePLI(i)/931);
    
    plot3([template_grid.pos(template_grid.inside(tempX),1) template_grid.pos(template_grid.inside(tempY),1)],...
    [template_grid.pos(template_grid.inside(tempX),2) template_grid.pos(template_grid.inside(tempY),2)],...
    [template_grid.pos(template_grid.inside(tempX),3) template_grid.pos(template_grid.inside(tempY),3)],'b')
    title('PLI in missed condition')
end

% Adding hubs
for i = 1:length(hubListPLIneg)
    scatter3(template_grid.pos(template_grid.inside(hubListPLIneg(i)),1), template_grid.pos(template_grid.inside(hubListPLIneg(i)),2),...
        template_grid.pos(template_grid.inside(hubListPLIneg(i)),3), 32, 'g', 'filled')
end


figure
ft_plot_mesh(bnd,'facealpha',0.05,'edgecolor','none', 'facecolor', 'black', 'edgealpha', 0.05);
hold on

for i = 1:length(posChangePC)
    tempX = rem(posChangePC(i),931);
    if tempX == 0
        tempX = 931;
    end
    tempY = ceil(posChangePC(i)/931);
    
    plot3([template_grid.pos(template_grid.inside(tempX),1) template_grid.pos(template_grid.inside(tempY),1)],...
    [template_grid.pos(template_grid.inside(tempX),2) template_grid.pos(template_grid.inside(tempY),2)],...
    [template_grid.pos(template_grid.inside(tempX),3) template_grid.pos(template_grid.inside(tempY),3)],'r') 
    title('PC in correct condition')
end

% Adding hubs
for i = 1:length(hubListPCpos)
    scatter3(template_grid.pos(template_grid.inside(hubListPCpos(i)),1), template_grid.pos(template_grid.inside(hubListPCpos(i)),2),...
        template_grid.pos(template_grid.inside(hubListPCpos(i)),3), 32, 'g', 'filled')
end


figure
ft_plot_mesh(bnd,'facealpha',0.05,'edgecolor','none', 'facecolor', 'black', 'edgealpha', 0.05);
hold on

for i = 1:length(negChangePC)
    tempX = rem(negChangePC(i),931);
    if tempX == 0
        tempX = 931;
    end
    tempY = ceil(negChangePC(i)/931);
    
    plot3([template_grid.pos(template_grid.inside(tempX),1) template_grid.pos(template_grid.inside(tempY),1)],...
    [template_grid.pos(template_grid.inside(tempX),2) template_grid.pos(template_grid.inside(tempY),2)],...
    [template_grid.pos(template_grid.inside(tempX),3) template_grid.pos(template_grid.inside(tempY),3)],'b')
    title('PC in missed condition')
end

% Adding hubs
for i = 1:length(hubListPCneg)
    scatter3(template_grid.pos(template_grid.inside(hubListPCneg(i)),1), template_grid.pos(template_grid.inside(hubListPCneg(i)),2),...
        template_grid.pos(template_grid.inside(hubListPCneg(i)),3), 32, 'g', 'filled')
end


% getting talairach coordinates of hubs and finding ROIs
tlrcCoordPLIpos = mni2tal(template_grid.pos(template_grid.inside(hubListPLIpos),:));
tlrcCoordPLIneg = mni2tal(template_grid.pos(template_grid.inside(hubListPLIneg),:));
tlrcCoordPCpos = mni2tal(template_grid.pos(template_grid.inside(hubListPCpos),:));
tlrcCoordPCneg = mni2tal(template_grid.pos(template_grid.inside(hubListPCneg),:));

for i = 1:length(tlrcCoordPLIpos)
    eval(['!whereami ' num2str(tlrcCoordPLIpos(i,1)) ' ' num2str(tlrcCoordPLIpos(i,2)) ' ' num2str(tlrcCoordPLIpos(i,3)) ' -lpi -atlas TT_Daemon >> ROIposPLI.txt'])
end

for i = 1:length(tlrcCoordPLIneg)
    eval(['!whereami ' num2str(tlrcCoordPLIneg(i,1)) ' ' num2str(tlrcCoordPLIneg(i,2)) ' ' num2str(tlrcCoordPLIneg(i,3)) ' -lpi -atlas TT_Daemon >> ROInegPLI.txt'])
end

for i = 1:length(tlrcCoordPCpos)
    eval(['!whereami ' num2str(tlrcCoordPCpos(i,1)) ' ' num2str(tlrcCoordPCpos(i,2)) ' ' num2str(tlrcCoordPCpos(i,3)) ' -lpi -atlas TT_Daemon >> ROIposPC.txt'])
end

for i = 1:length(tlrcCoordPCneg)
    eval(['!whereami ' num2str(tlrcCoordPCneg(i,1)) ' ' num2str(tlrcCoordPCneg(i,2)) ' ' num2str(tlrcCoordPCneg(i,3)) ' -lpi -atlas TT_Daemon >> ROInegPC.txt'])
end

%% Reducing dimentionality before statistics

for s = 1:22
    eval(['cd sub' num2str(s) ])
    load connec0713
    eval(['connec0713sub' num2str(s) ' = connec0713;'])
    clear connec0713
    cd ..
end

load regStruct

% creating the ROI confusion matrices for each subject
tic
ROImat.PLIcorr = cell(1,22);
ROImat.PLImiss = cell(1,22);
ROImat.PCcorr = cell(1,22);
ROImat.PCmiss = cell(1,22);
for subi = 1:22
    ROImat.PLIcorr{subi} = zeros(60,60);
    ROImat.PLImiss{subi} = zeros(60,60);
    ROImat.PCcorr{subi} = zeros(60,60);
    ROImat.PCmiss{subi} = zeros(60,60);
    for roii = 1:60
        for roij = 1:60
            for roisi = regStruct.ROIcelNum{roii}
                eval(['ROImat.PLIcorr{' num2str(subi) '}(' num2str(roii) ',' num2str(roij) ') = ROImat.PLIcorr{' num2str(subi) '}(' num2str(roii) ',' num2str(roij) ') + sum(connec0713sub' num2str(subi) '.avgPLIcond1(' num2str(roisi) ',regStruct.ROIcelNum{' num2str(roij) '}));'])
                eval(['ROImat.PLImiss{' num2str(subi) '}(' num2str(roii) ',' num2str(roij) ') = ROImat.PLImiss{' num2str(subi) '}(' num2str(roii) ',' num2str(roij) ') + sum(connec0713sub' num2str(subi) '.avgPLIcond2(' num2str(roisi) ',regStruct.ROIcelNum{' num2str(roij) '}));'])
                eval(['ROImat.PCcorr{' num2str(subi) '}(' num2str(roii) ',' num2str(roij) ') = ROImat.PCcorr{' num2str(subi) '}(' num2str(roii) ',' num2str(roij) ') + sum(connec0713sub' num2str(subi) '.avgPCcond1(' num2str(roisi) ',regStruct.ROIcelNum{' num2str(roij) '}));'])
                eval(['ROImat.PCmiss{' num2str(subi) '}(' num2str(roii) ',' num2str(roij) ') = ROImat.PCmiss{' num2str(subi) '}(' num2str(roii) ',' num2str(roij) ') + sum(connec0713sub' num2str(subi) '.avgPCcond2(' num2str(roisi) ',regStruct.ROIcelNum{' num2str(roij) '}));'])
            end
            ROImat.PLIcorr{subi}(roii,roij) = ROImat.PLIcorr{subi}(roii,roij)./(length(regStruct.ROIcelNum{roii})*length(regStruct.ROIcelNum{roij}));
            ROImat.PLImiss{subi}(roii,roij) = ROImat.PLImiss{subi}(roii,roij)./(length(regStruct.ROIcelNum{roii})*length(regStruct.ROIcelNum{roij}));
            ROImat.PCcorr{subi}(roii,roij) = ROImat.PCcorr{subi}(roii,roij)./(length(regStruct.ROIcelNum{roii})*length(regStruct.ROIcelNum{roij}));
            ROImat.PCmiss{subi}(roii,roij) = ROImat.PCmiss{subi}(roii,roij)./(length(regStruct.ROIcelNum{roii})*length(regStruct.ROIcelNum{roij}));
        end
        ROImat.PLIcorr{subi}(roii,roii) = 0;
        ROImat.PLImiss{subi}(roii,roii) = 0;
        ROImat.PCcorr{subi}(roii,roii) = 0;
        ROImat.PCmiss{subi}(roii,roii) = 0;
    end
end
toc      

save ROImat2 ROImat


% statistics

tic
pValMatPLI = zeros(60,60);
zValMatPLI = zeros(60,60);
pValMatPC = zeros(60,60);
zValMatPC = zeros(60,60);
for xi = 1:60
    for yi = 1:60
        for subi = 1:22
            corrVecPLI(subi) = ROImat.PLIcorr{subi}(xi,yi);
            missVecPLI(subi) = ROImat.PLImiss{subi}(xi,yi);
            corrVecPC(subi) = ROImat.PCcorr{subi}(xi,yi);
            missVecPC(subi) = ROImat.PCmiss{subi}(xi,yi);
        end
        [pValMatPLI(xi,yi),~,tempStat] = ranksum(corrVecPLI,missVecPLI);
        zValMatPLI(xi,yi) = tempStat.zval;
        [pValMatPC(xi,yi),~,tempStat] = ranksum(corrVecPC,missVecPC);
        zValMatPC(xi,yi) = tempStat.zval;
    end
    zValMatPLI(xi,xi) = 0;
    zValMatPC(xi,xi) = 0;
end
toc

save ctxConnecAlphaROI pValMatPLI zValMatPLI pValMatPC zValMatPC

% Setting a threshold and splitting into two directions

alpha = 0.025;

sigMatPLIpos = zeros(60,60);
sigMatPLIneg = zeros(60,60);
sigMatPCpos = zeros(60,60);
sigMatPCneg = zeros(60,60);
for xi = 1:60
    for yi = 1:60
        if pValMatPLI(xi,yi) < alpha
            if zValMatPLI(xi,yi) > 0
                sigMatPLIpos(xi,yi) = zValMatPLI(xi,yi);
            elseif zValMatPLI(xi,yi) < 0
                sigMatPLIneg(xi,yi) = zValMatPLI(xi,yi);
            end
        end
        if pValMatPC(xi,yi) < alpha
            if zValMatPC(xi,yi) > 0
                sigMatPCpos(xi,yi) = zValMatPC(xi,yi);
            elseif zValMatPC(xi,yi) < 0
                sigMatPCneg(xi,yi) = zValMatPC(xi,yi);
            end
        end
    end
end

posChangePLI = find(sigMatPLIpos);
negChangePLI = find(sigMatPLIneg);
posChangePC = find(sigMatPCpos);
negChangePC = find(sigMatPCneg);


% confusion matrices ploting

figure
imagesc(sigMatPLIpos)
colorbar
title('stronger PLI in the correct condition')

figure
imagesc(sigMatPLIneg)
colorbar
title('stronger PLI in the missed condition')

figure
imagesc(sigMatPCpos)
colorbar
title('stronger PC in the correct condition')

figure
imagesc(sigMatPCneg)
colorbar
title('stronger PC in the missed condition')


load objTlrcBrainSrf

% brain surface for stronger PLI in the correct condition

bnd.tri=obj1.f3';
bnd.pnt=obj1.v';

figure
ft_plot_mesh(bnd,'facealpha',0.05,'edgecolor','none', 'facecolor', 'black', 'edgealpha', 0.05);
hold on

bnd.tri=obj2.f3';
bnd.pnt=obj2.v';
ft_plot_mesh(bnd,'facealpha',0.05,'edgecolor','none', 'facecolor', 'black', 'edgealpha', 0.05);

for i = 1:length(posChangePLI)
    tempX = rem(posChangePLI(i),60);
    if tempX == 0
        tempX = 60;
    end
    tempY = ceil(posChangePLI(i)/60);
    
    plot3([regStruct.ROIcoords_tlrc(tempX,1) regStruct.ROIcoords_tlrc(tempY,1)],...
    [regStruct.ROIcoords_tlrc(tempX,2) regStruct.ROIcoords_tlrc(tempY,2)],...
    [regStruct.ROIcoords_tlrc(tempX,3) regStruct.ROIcoords_tlrc(tempY,3)],'r') 
    title('PLI in correct condition')
end



% brain surface for stronger PLI in the missed condition

bnd.tri=obj1.f3';
bnd.pnt=obj1.v';

figure
ft_plot_mesh(bnd,'facealpha',0.05,'edgecolor','none', 'facecolor', 'black', 'edgealpha', 0.05);
hold on

bnd.tri=obj2.f3';
bnd.pnt=obj2.v';
ft_plot_mesh(bnd,'facealpha',0.05,'edgecolor','none', 'facecolor', 'black', 'edgealpha', 0.05);

for i = 1:length(negChangePLI)
    tempX = rem(negChangePLI(i),60);
    if tempX == 0
        tempX = 60;
    end
    tempY = ceil(negChangePLI(i)/60);
    
    plot3([regStruct.ROIcoords_tlrc(tempX,1) regStruct.ROIcoords_tlrc(tempY,1)],...
    [regStruct.ROIcoords_tlrc(tempX,2) regStruct.ROIcoords_tlrc(tempY,2)],...
    [regStruct.ROIcoords_tlrc(tempX,3) regStruct.ROIcoords_tlrc(tempY,3)],'b') 
    title('PLI in missed condition')
end




% brain surface for stronger PC in the correct condition

bnd.tri=obj1.f3';
bnd.pnt=obj1.v';

figure
ft_plot_mesh(bnd,'facealpha',0.05,'edgecolor','none', 'facecolor', 'black', 'edgealpha', 0.05);
hold on

bnd.tri=obj2.f3';
bnd.pnt=obj2.v';
ft_plot_mesh(bnd,'facealpha',0.05,'edgecolor','none', 'facecolor', 'black', 'edgealpha', 0.05);

for i = 1:length(posChangePC)
    tempX = rem(posChangePC(i),60);
    if tempX == 0
        tempX = 60;
    end
    tempY = ceil(posChangePC(i)/60);
    
    plot3([regStruct.ROIcoords_tlrc(tempX,1) regStruct.ROIcoords_tlrc(tempY,1)],...
    [regStruct.ROIcoords_tlrc(tempX,2) regStruct.ROIcoords_tlrc(tempY,2)],...
    [regStruct.ROIcoords_tlrc(tempX,3) regStruct.ROIcoords_tlrc(tempY,3)],'r') 
    title('PC in correct condition')
end



% brain surface for stronger PC in the missed condition

bnd.tri=obj1.f3';
bnd.pnt=obj1.v';

figure
ft_plot_mesh(bnd,'facealpha',0.05,'edgecolor','none', 'facecolor', 'black', 'edgealpha', 0.05);
hold on

bnd.tri=obj2.f3';
bnd.pnt=obj2.v';
ft_plot_mesh(bnd,'facealpha',0.05,'edgecolor','none', 'facecolor', 'black', 'edgealpha', 0.05);

for i = 1:length(negChangePC)
    tempX = rem(negChangePC(i),60);
    if tempX == 0
        tempX = 60;
    end
    tempY = ceil(negChangePC(i)/60);
    
    plot3([regStruct.ROIcoords_tlrc(tempX,1) regStruct.ROIcoords_tlrc(tempY,1)],...
    [regStruct.ROIcoords_tlrc(tempX,2) regStruct.ROIcoords_tlrc(tempY,2)],...
    [regStruct.ROIcoords_tlrc(tempX,3) regStruct.ROIcoords_tlrc(tempY,3)],'b') 
    title('PC in missed condition')
end