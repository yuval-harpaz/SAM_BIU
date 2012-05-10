function filter=wts2filter(ActWgts,inside,outN)
% inside=grid.inside;
% outN=size(grid.outside,1);


sensN=248;
srcN 	   = size(ActWgts,1);
for i=1:(srcN+outN)
    filter{i}=[];
end
for i=1:srcN,
    si = inside(i);
    %if ~isempty(sourceGlobal.avg.filter{m})
        %                sourceAvg.mom{m} = sourceGlobal.avg.filter{m}(1,ismeg)*EMSEdata;
    %    sourceAvg.mom{m} = sourceGlobal.avg.filter{m}*standard.avg;
    filter{si}=ActWgts(i,:);
        
    %end
end