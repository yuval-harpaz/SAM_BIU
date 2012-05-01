function [vs,allInd]=inScalpVS(vs,allInd)
if size(vs,2)>1
    nonZero=find(sum(abs(vs')>0)); % looking for voxels out of the scalp (weights zero, vs zero)
else
    nonZero=find(abs(vs')>0);
end
vs=vs(nonZero,:); % taking only non zero vs
allInd=allInd(nonZero,:);
end