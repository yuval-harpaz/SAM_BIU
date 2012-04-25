% this is an example of how to use the output of SAMwts to generate virtual
% sensors for raw or averaged data (from fieldtrip), and how to make a
% movie of brain activity for time of interest. this is designed for whole
% head analysis, for few VS of specific location use vs_ft.

cd /home/yuval/Data/tel_hashomer/yuval
load VG % loading fieldtrip averaged data 'VG'
% next function will read the wts file made by SAMwts and multiply the weights by
% the averaged data. you can do that also for unaveraged data and raw,
% (c,rfhp...) data.
% it will make virtuall sensors from time 0 to 1s every 20 samples (for
% 1017.25 sample rate it is 51 samples, ~20ms from each other)
[vs,timeline,allInd]=VS_slice(VG,'SAM/VGerf,1-35Hz,VerbAa.wts',20,[0 1]);
[vs,allInd]=inScalpVS(vs,allInd); % excluding out of the scalp grid points
% here you can make a second vs matrix for another condition and compare
% the two (vsNew=vs1-vs2). alternatively you can go on with the process to
% see images for each condition and not images of the differences.
% next step is necessary if you want images of each condition to make sense
% also without comparison to other conditions.
vsZ=zScoreVS(vs); %standardize channels to avoid bias to medial vs.
% here you make images. it takes time!
vsSlice2afni(allInd,vsZ,'vgZ'); %making afni files starting with vgZ prefix
%then concatnate the vgZ afni files with 3dTcat:
!~/abin/3dTcat -prefix vgZ vgZ*
% then open afni
% choose underlay and overlay
% click "new" button in afni panel
% choose the concatnated file as underlay
% define data mode > lock > timelock.
% open a graph

