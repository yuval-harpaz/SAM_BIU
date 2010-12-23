function [mrifid,meegfid]=fitMRI(hspath);
%% creates T.nii MRI file based on the single_subj_T1.nii adjusted to the headshape at the given path.

%% check path and read hs_file
if ~exist('hspath')==1
    hspath='';
end
if ~exist([hspath,'/hs_file'])==2
    error('no headshape was found for this path')
end
meegfid=ft_read_headshape([hspath,'/hs_file']); %values in meters!

%% calculating distance between ears
P1=meegfid.fid.pnt(1,:);
P2=meegfid.fid.pnt(2,:);
P3=meegfid.fid.pnt(3,:);
P4=[0 0 0]; % the point between the two ears
meegNormal = cross(P1-P2, P1-P3); %perpendicular line to fiducials plane
%distance in mm
dLRmeeg=round(1000*sqrt((P3(1)-P2(1))^2 + (P3(2)-P2(2))^2 + (P3(3)-P2(3))^2)); 
dNZmeeg=round(1000*sqrt((P1(1)-P4(1))^2 + (P1(2)-P4(2))^2 + (P1(3)-P4(3))^2));
%finding the closest headshape point to the perpendicular line (vertex)
for i=1:size(meegfid.pnt,1)
    pt=meegfid.pnt(i,1:3);
    meegDist(i,1) = point_to_line(pt,[0 0 0],meegNormal);
end;
clear i pt;    
[v_meeg,i_meeg]=min(meegDist);
P5=meegfid.pnt(i_meeg,1:3); %vertex on headshape
dVmeeg=round(1000*sqrt((P5(1)-P4(1))^2 + (P5(2)-P4(2))^2 + (P5(3)-P4(3))^2));

%% MRI fidutials
dLRmri=166;
dNZmri=108;
dVmri=169;
LRrat=dLRmeeg/dLRmri; % x
NZrat=dNZmeeg/dNZmri; % y
Vrat=dVmeeg/dVmri; % z
copyfile(fullfile(spm('dir'), 'canonical', 'single_subj_T1.nii'),'T.nii');
% copyfile('/home/meg/maor/SAM/single_subj_T1.nii','T.nii');
M=[LRrat 0 0 0;0 NZrat 0 0;0 0 Vrat 0; 0 0 0 1];
spm_get_space('T.nii', spm_get_space(fullfile(spm('dir'), 'canonical', 'single_subj_T1.nii'))*M);


% mrifid=rmfield(meegfid,'pnt');
% mrifid.fid.pnt=[1,85,-41;-83,-20,-65;83,-20,-65;-87,-11,-62;87,-11,-62;];
% P1=mrifid.fid.pnt(1,:);
% P2=mrifid.fid.pnt(2,:);
% P3=mrifid.fid.pnt(3,:);
% P4=[(mrifid.fid.pnt(2,1)+mrifid.fid.pnt(3,1))/2 (mrifid.fid.pnt(2,2)+mrifid.fid.pnt(3,2))/2 (mrifid.fid.pnt(2,3)+mrifid.fid.pnt(3,3))/2]; % the point between 
% P5=[0,-20,104];
% dLRmri=round(sqrt((P3(1)-P2(1))^2 + (P3(2)-P2(2))^2 + (P3(3)-P2(3))^2)); 
% dNZmri=round(sqrt((P1(1)-P4(1))^2 + (P1(2)-P4(2))^2 + (P1(3)-P4(3))^2));
% dVmri=round(sqrt((P5(1)-P4(1))^2 + (P5(2)-P4(2))^2 + (P5(3)-P4(3))^2));
% LRrat=dLRmeeg/dLRmri; % x
% NZrat=dNZmeeg/dNZmri; % y
% Vrat=dVertxmeeg/dVertxmri; % z

