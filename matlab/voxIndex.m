function [ind,allInd]=voxIndex(vox,boxSize,step,allIndices)
% gives the index 'ind' of a voxel in a box.
% can also give a 3 column matrix (x y z) of all voxels in the box.
%
% example:
% boxSize=[-10 10 -9 9 0 15];
% vox=[6.5 2 7];
% step=0.5;
% allIndices=1 % to create an x y z matrix for all voxels

%% finding the specified voxel

sizes=diff(boxSize);
sizes=sizes(1:2:5);
sizes=sizes/step+1;
for indi=1:size(vox,1)
    ind(indi,1)= (vox(indi,1)-boxSize(1))/step*sizes(2)*sizes(3)+...
        (vox(indi,2)-boxSize(3))/step*sizes(3)+...
        (vox(indi,3)-boxSize(5))/step+1;
    %display(['index=',num2str(ind)]);
end
%% creating a matrix
allInd=[];
if exist('allIndices','var')
    if allIndices==1
        i=0;
        for x=boxSize(1):step:boxSize(2)
            for y=boxSize(3):step:boxSize(4)
                for z=boxSize(5):step:boxSize(6)
                    i=i+1;
                    allInd(i,1:3)=[x y z];
                end
            end
        end
    end
end
%
%
% ind=[boxSize(1) boxSize(3) boxSize(5)+(vox-1)*step];
end