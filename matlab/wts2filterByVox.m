function filter=wts2filterByVox(ActWgts,voxind)



srcN 	   = size(ActWgts,1);
for i=1:srcN
    filter{i}=[]; %#ok<AGROW>
end
for i=1:size(voxind,1)
    % si = inside(i);
    %if ~isempty(sourceGlobal.avg.filter{m})
        %                sourceAvg.mom{m} = sourceGlobal.avg.filter{m}(1,ismeg)*EMSEdata;
    %    sourceAvg.mom{m} = sourceGlobal.avg.filter{m}*standard.avg;
    filter{voxind(i)}=ActWgts(voxind(i),:); %#ok<AGROW>
        
    %end
end