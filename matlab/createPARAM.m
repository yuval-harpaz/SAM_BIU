function createPARAM(fileName,SAMprog,actName,actWin,contName,contWin,band,segment,statistic,resolution,model,metric,noiseBand);
%% general notes
% creates *.param file for SAMerf and SAMspm.
% for SAMerf the condition has to be the same for active (called response in the param file)
% and control.
% for SAMspm it could be the same (to divide sources of one condition with its own baseline
% or different to divide Active condition by Control.
% SAMspm can also be used in single state mode. then you should specify a
% noiseBand, I recommend high frequencies where not much happens (default 40-100Hz)
%
% example for 3-35Hz, 0 to 1s, rest1/rest2
% createPARAM('test','SPM','rest1',[0 1],'rest2',[0 1],[3 35],[0 1]);
%
% here a narrow time window is used for SAMspm but the covarince will be
% computed on a large [-0.1 0.7] segment
% createPARAM('test','SPM','rest1',[0.1 0.2],'rest2',[0.1 0.2],[3 35],[-0.1 0.7]);

%% example param files
% one condition SAMspm
%       command
% createPARAM('alpha','SPM','all',[0.1 0.2],[],[],[3 35],[-0.1 0.7],'Pseudo-Z',0.5,'MultiSphere','Power',[50 100]);

%       content of alpha.param
% NumStates 1
% DataBand 3 35
% ImageBand 3 35
% NoiseBand 50 100
% DataSegment -0.1 0.7
% ImageMetric Power
% XBounds -12.0 12.0
% YBounds -9.0 9.0
% ZBounds -2.0 15.0
% ImageMode Pseudo-Z
% Model MultiSphere
% Active all 0.1 0.2
% CovSum FALSE

% you can look in C source code at SAMsrc_BIU/Libs/SAMLIB/GetParams.c for
% more parameters options
%% ImageMode
% 
% Z-Test
% T-Test
% F-Test
% U-Test
% Pseudo-Z
% Pseudo-T
% Pseudo-F
% Sum-Ranks
% ERF
% Diff-ERF
%% ImageMetric
% Power
% PermEntropy <PermSize Tau>
% RankEntropy <Size Tau>
% RankVectorEntropy <Tau>
% SpectEntropy
% Kurtosis
% Predict <Order>
%
%% Model
% SingleSphere <x y z> cm
% MultiSphere
% Nolte

%% setting defaults and numbers to text
fileName=[fileName,'.param'];
if ~exist('metric','var')
    metric='Power';
end
if ~exist('model','var')
    model='Nolte';
end
if ~exist('resolution','var')
    resolution=[];
end
if isempty(resolution)
    resolution='0.5';
end
if ~exist('statistic','var')
    statistic=[];
end
if isempty(statistic)
    statistic='U-Test';
end
numStates='2';
if isempty (contName)
    numStates='1';
end
mode=statistic;
if strcmp(SAMprog,'ERF')
    numStates='1';
    mode='ERF';
end
if strcmp(SAMprog,'ERF')	
    if ~strcmp(actName,contName)
        error('active and control must be the same condition (only different time window)')
    end
end
if isnumeric(actWin)
    actWin=num2str(actWin);
end
if isnumeric(contWin)
    contWin=num2str(contWin);
end
if isnumeric(band)
    band=num2str(band);
end
if isnumeric(segment)
    segment=num2str(segment);
end
% writing the textfile

eval(['!echo NumStates ',numStates,' > ',fileName]);
eval(['!echo DataBand ',band,' >> ',fileName]);
eval(['!echo ImageBand ',band,' >> ',fileName]);
if strcmp(numStates,'1') && strcmp(SAMprog,'SPM')
    if ~exist ('noiseBand','var')
        noiseBand=[];
    end
    if isempty(noiseBand);
        noiseBand=[40 100];
    end
    eval(['!echo NoiseBand ',num2str(noiseBand(1)),' ',num2str(noiseBand(2)),' >> ',fileName]);
end
eval(['!echo DataSegment ',segment,' >> ',fileName]);
eval(['!echo ImageMetric ',metric,' >> ',fileName]);
eval(['!echo XBounds -12.0 12.0 >> ',fileName]);
eval(['!echo YBounds -9.0 9.0 >> ',fileName]);
eval(['!echo ZBounds -2.0 15.0 >> ',fileName]);
eval(['!echo ImageStep ',resolution,' >> ',fileName]);
eval(['!echo ImageMode ',mode,' >> ',fileName]);
eval(['!echo Model ',model,' >> ',fileName]);
if strcmp(numStates,'2')
    eval(['!echo LogP TRUE >> ',fileName]);
end
if strcmp(SAMprog,'ERF')
    eval(['!echo CovSum FALSE >> ',fileName]);
    eval(['!echo Response ',actName,' ',actWin,' >> ',fileName]);
    eval(['!echo Baseline ',contName,' ',contWin,' >> ',fileName]);
elseif strcmp(SAMprog,'SPM')
    eval(['!echo Active ',actName,' ',actWin,' >> ',fileName]);
    if strcmp(numStates,'2')
        eval(['!echo Control ',contName,' ',contWin,' >> ',fileName]);
        eval(['!echo CovSum TRUE >> ',fileName]);
    else
        eval(['!echo CovSum FALSE >> ',fileName]);
    end 
end   
end