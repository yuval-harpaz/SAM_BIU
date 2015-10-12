function trl2mark(trl,sRate)
% trl - 3 or 4 column trl matrix (4th with trial type)
% sRate - sampling rate
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