function M=fitMRI2hs(data);
%% the function creates a new mri nii file based on a template, fitted by
% fidutial points
% examplecommand: fitMRI2hs('c,rfDC');
%% creating fieldTrip data
cfg.dataset=data;
cfg.trialdef.poststim=0.1;
cfg.trialfun='trialfun_beg';
cfg1=definetrial(cfg);
cfg1.channel='A1';
ftdata=ft_preprocessing(cfg1);
%% creating SPM data
headshapefile='hs_file';
D=spm_eeg_ft2spm(ftdata,'modtempfile');
%%
S.D = D;
S.task = 'headshape';
S.headshapefile = headshapefile;
S.source = 'convert';
S.regfid{1, 1} = 'NZ';
S.regfid{1, 2} = 'NZ';
S.regfid{2, 1} = 'L';
S.regfid{2, 2} = 'L';
S.regfid{3, 1} = 'R';
S.regfid{3, 2} = 'R';
S.regfid{4, 1} = 'fiducial4';
S.regfid{4, 2} = 'fiducial4';
S.regfid{5, 1} = 'fiducial5';
S.regfid{5, 2} = 'fiducial5';
S.save = 1;
D = spm_eeg_prep(S);
meegfid = D.fiducials;
D.inv = {struct('mesh', [])};
D.inv{1}.date    = strvcat(date,datestr(now,15));
D.inv{1}.comment = {''};
D.inv{1}.mesh= spm_eeg_inv_mesh([], 2);
spm_eeg_inv_checkmeshes(D);

tmesh=D.inv{1}.mesh;
%COREGISTRATION WITH TEMPLATE MRI
meegfid = D.fiducials;
mrifid = D.inv{1}.mesh.fid;
meegfid.fid.pnt   = meegfid.fid.pnt(1:3,:);
meegfid.fid.label = meegfid.fid.label(1:3,:); 
mrifid.fid.pnt   = mrifid.fid.pnt(1:3,:);
mrifid.fid.label = meegfid.fid.label(1:3,:);
M1=[];
S =[];
S.sourcefid = meegfid;
S.targetfid = mrifid; 
S.useheadshape = 1;
S.template = 2;
M1 = spm_eeg_inv_datareg(S);
%% create a new MRI from template, scaled to subject
copyfile(fullfile(spm('dir'), 'canonical', 'single_subj_T1.nii'),'T.nii');
spm_get_space('T.nii', inv(M1)*spm_get_space(fullfile(spm('dir'), 'canonical', 'single_subj_T1.nii')));
%
%% rotate the MRI to fit svl images
M2=zeros(4,4);
M2(1,2)=-1;M2(2,1)=1;M2(3,3)=1;M2(4,4)=1;
spm_get_space('T.nii', M2*spm_get_space('T.nii'));
warning(' ');
% display('oblique MRI. to create AFNI format:');
% display('if the last step failed (3dWarp) in a terminal write: 3dWarp -deoblique T.nii');
% display('the mri will be called warped+orig.BRIK');
M=spm_get_space('T.nii');
delete modtempfile.mat
delete modtempfile.dat
if exist('~/abin','dir')
    !~/abin/3dWarp -deoblique T.nii
elseif exist('/home/megadmin/abin','dir')
    !/home/megadmin/abin/3dWarp -deoblique T.nii
else
    warning('afni folder wasnt found. in a terminal write: 3dWarp -deoblique T.nii');
end
end
