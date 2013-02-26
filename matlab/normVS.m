function vs=normVS(vs,noise,BLsamps)

% normalizes virtual sensors
% vs has n rows for virtual sensors, m columns for samples
% noise is a vector with n length, a noise estimate to devide each row by
% BLsamps e.g. [1 103], beg and end samples for baseline correction.
% example: nvs=normVS(vs,[],[]); % only baseline correstion;
% another example:
% noise=Wgts-repmat(mean(Wgts,2),1,size(Wgts,2));
% noise=mean(noise.*noise,2);
% nvs=normVS(vs,noise,[1 103])

if exist('BLsamps','var')
    if ~isempty(BLsamps)
        vs=vs-repmat(mean(vs(:,BLsamp(1):BLsamp(2),2)),1,size(vs,2));
    else
        vs=vs-repmat(mean(vs,2),1,size(vs,2));
    end
else
    warning('No baseline correction. Better run vs=normVS(vs,noise,[])');
end
if ~isempty(noise)
    vs=vs./repmat(noise,1,size(vs,2));
end
end
