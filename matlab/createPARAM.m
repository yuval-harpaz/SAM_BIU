function createPARAM(fileName,SAMprog,actName,actWin,contName,contWin,band,segment,statistic,resolution,model,metric);
% createPARAM('test','SPM','rest1',[0 1],'rest2',[0 1],[3 35],[0 1]);
% createPARAM('test','SPM','rest1',[0.1 0.2],'rest2',[0.1 0.2],[3 35],[-0.1 0.7]);

% setting defaults and numbers to texttext
fileName=[fileName,'.param'];
if ~exist('metric','var')
    metric='Power';
end
if ~exist('model','var')
    model='Nolte';
end
if ~exist('resolution','var')
    resolution='0.5';
end
if ~exist('statistic','var')
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
eval(['!echo DataSegment ',segment,' >> ',fileName]);
eval(['!echo ImageMetric ',metric,' >> ',fileName]);
eval(['!echo XBounds -12.0 12.0 >> ',fileName]);
eval(['!echo YBounds -9.0 9.0 >> ',fileName]);
eval(['!echo ZBounds -2.0 15.0 >> ',fileName]);
eval(['!echo ImageStep ',resolution,' >> ',fileName]);
eval(['!echo ImageMode ',mode,' >> ',fileName]);
eval(['!echo Model ',model,' >> ',fileName]);
eval(['!echo LogP TRUE >> ',fileName]);
if strcmp(SAMprog,'ERF')
    eval(['!echo CovSum FALSE >> ',fileName]);
    eval(['!echo Reponse ',actName,' ',actWin,' >> ',fileName]);
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