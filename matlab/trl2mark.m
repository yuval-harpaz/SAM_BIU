function trl2mark(trl,sRate)
% trl - 3 or 4 column trl matrix (4th with trial type)
% sRate - sampling rate
% trl can also be a fieldtrip structure, with averaged or trials data (no
% need to give sRate in this case
if isstruct(trl)
    sRate=trl.fsample;
    gotTRL=false;
    if isfield(trl,'trl')
        trl=trl;
    else
        if isfield(trl,'sampleinfo')
            temp=trl.sampleinfo(:,1:2);
            if iscell(trl.time)
                t0=nearest(trl.time{1},0);
                if trl.time{1}(t0)>0.005;
                    warning('setting offset to 0')
                    t0=1;
                end
            else
                t0=nearest(trl.time,0);
                if trl.time(t0)>0.005;
                    warning('setting offset to 0')
                    t0=1;
                end
            end
            
        end
        temp(:,3)=-t0+1;
        if isfield(trl,'trialinfo')
            temp(:,4)=trl.trialinfo;
        end
        trl=temp; 
    end
end
all=(trl(:,1)+trl(:,3))'./sRate;
str=['Trig2mark(''','All''',',all'];
if size(trl,2)>3
    Ntrig=length(unique(trl(:,4)));
    for trgi=unique(trl(:,4))'
        eval(['trg',num2str(trgi),'=all(find(trl(:,4)==trgi));']);
        str=[str,',','''trg',num2str(trgi),''',trg',num2str(trgi)];
    end
end
str=[str,');'];
eval(str)