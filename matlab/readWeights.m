function [SAMHeader, ActIndex, ActWgts]=readWeights(fileName)
% open a SAM weights file and read the variables

% May-2011  MA

fid = fopen(fileName,'r'); % 'ieee-le' or 'ieee-be'
%% read the header
title = fread(fid , 8, 'char=>char')';
disp(['Title = ' title])
Version = fread(fid, 1, 'int32=>int32',  'ieee-be');
disp(['Version = ' num2str(Version)]);
setName = fread(fid , 256, 'char=>char')';
disp(['setName = ' setName]);
NumChans = fread(fid, 1, 'int32=>int32',  'ieee-be');
NumWeights = fread(fid, 1, 'int32=>int32',  'ieee-be');
virtualSensors = fread(fid, 1, 'int32=>int32',  'ieee-be');
XStart = fread(fid, 1, 'double=>double',  'ieee-be');
XEnd = fread(fid, 1, 'double=>double',  'ieee-be');
YStart = fread(fid, 1, 'double=>double',  'ieee-be');
YEnd = fread(fid, 1, 'double=>double',  'ieee-be');
ZStart = fread(fid, 1, 'double=>double',  'ieee-be');
ZEnd = fread(fid, 1, 'double=>double',  'ieee-be');
StepSize = fread(fid, 1, 'double=>double',  'ieee-be');
TimeStart = fread(fid, 1, 'double=>double',  'ieee-be'); %problems??
TimeEnd = fread(fid, 1, 'double=>double',  'ieee-be');
% it seems there are 16 bytes of something else here ???
%     they contain:  50.3179  and  8.8369e-028       ???
fseek(fid, 16, 'cof');
MarkerName = fread(fid, 128, 'char=>char')';
%   The following are defined in SAMHeader_V3 but I do not see them here
% HPFreq = fread(fid, 1, 'double=>double',  'ieee-be');
% LPFreq = fread(fid, 1, 'double=>double',  'ieee-be');
% BWFreq = fread(fid, 1, 'double=>double',  'ieee-be');
% MeanNoise = fread(fid, 1, 'double=>double',  'ieee-be');
% MRIName = fread(fid, 256, 'char=>char')';
% Nasion = int32(nan(1,3));
% RightPA = int32(nan(1,3));
% LeftPA = int32(nan(1,3));
% for ii = 1:3
%     Nasion(ii) = fread(fid, 1, 'int32=>int32',  'ieee-be');
%     RightPA(ii) = fread(fid, 1, 'int32=>int32',  'ieee-be');
%     LeftPA(ii) = fread(fid, 1, 'int32=>int32',  'ieee-be');
% end
% SAMType = fread(fid, 1, 'int32=>int32',  'ieee-be');
% SAMUnit = fread(fid, 1, 'int32=>int32',  'ieee-be');
% reserved2 = fread(fid, 1, 'int32=>int32',  'ieee-be');

% There is some data here whos nature is not clear ???
%    all the values are 0                          ???
fseek(fid, 44*4, 'cof');

%% make a SAMHeader from the above
SAMHeader = struct;
SAMHeader.Version = Version;
SAMHeader.virtualSensors = virtualSensors;
SAMHeader.setName = setName;
SAMHeader.NumChans = NumChans;
SAMHeader.NumWeights = NumWeights;
SAMHeader.virtualSensors = virtualSensors;
SAMHeader.XStart = XStart;
SAMHeader.XEnd = XEnd;
SAMHeader.YStart = YStart;
SAMHeader.YEnd = YEnd;
SAMHeader.ZStart = ZStart;
SAMHeader.ZEnd = ZEnd;
SAMHeader.StepSize = StepSize;
SAMHeader.TimeStart = TimeStart;
SAMHeader.TimeEnd = TimeEnd;
SAMHeader.MarkerName = MarkerName;


%% Read the ActIndex
ActIndex = int32(ones(1,NumChans));
for ii = 1:NumChans
    ActIndex(ii) = fread(fid, 1, 'int32=>int32',  'ieee-be');
end

% %% skip bytes to get aligned again with the doubles??
% ftell(fid)  % tell where we are in the file
% % jnk = fread(fid, 2, 'char=>char');
% 
%% Read the weights
WeightsBuffer = fread(fid, NumWeights*NumChans, 'double=>double',  'ieee-be');
bufferCounter = 0;
ActWgts = nan(NumWeights,NumChans);
for c =1:NumWeights
    for m = 1:NumChans
        bufferCounter = bufferCounter + 1;
        ActWgts(c,m) = WeightsBuffer(bufferCounter);
        %ActWgts(c,m) = fread(fid, 1, 'double=>double',  'ieee-be');
    end
end

fclose(fid);
return
