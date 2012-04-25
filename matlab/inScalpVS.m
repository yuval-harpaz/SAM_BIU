function [vs,allInd]=inScalpVS(vs,allInd)
nonZero=find(sum(abs(vs')>0)); % looking for voxels out of the scalp (weights zero, vs zero)
vs=vs(nonZero,:); % taking only non zero vs
allInd=allInd(nonZero,:);
end