function wts=filter2wts(filter)
% makes a SAM like weights matrix from fieldtrip's filter
sensN=248;
srcN 	   = size(filter,2);
wts=zeros(srcN,sensN); % fixme - check cells in filter to see N channels
%
% filter = cell(1,srcN+outN);


for i=1:srcN,
    if ~isempty(filter{i})
        %if ~isempty(sourceGlobal.avg.filter{m})
        %                sourceAvg.mom{m} = sourceGlobal.avg.filter{m}(1,ismeg)*EMSEdata;
        %    sourceAvg.mom{m} = sourceGlobal.avg.filter{m}*standard.avg;
        wts(i,:)=filter{i};
        
    end
end