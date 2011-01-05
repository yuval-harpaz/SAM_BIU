function [comp]=epiFTica(pat,dataset,badChans,EorM)
% YHepiFTpca
% EorM specifies EEG or MEG , 'E' or 'M'.
%pat='/media/D6A0A2E3A0A2C977/BF4clinic/b024/';
%dataset='c,rfhp1.0Hz,ee';
%badChans=[74 204]
if ~exist('badChans');badChans=[];end %#ok<EXIST>
if ~exist('pat');pat='';end %#ok<EXIST>
if ~exist('EorM');EorM='M';warning('reading MEG channels by default');end %#ok<WNTAG,EXIST>

% creating a string of channel names disincluding bad channels
chanstr='';
if EorM=='M';
    for i=1:248
        if ~any(badChans==i)
            chanstr=[chanstr,'''A',num2str(i),'''',' ']; %#ok<AGROW>
        end
    end
elseif EorM=='E';
    for i=1:30
        if ~any(badChans==i)
            chanstr=[chanstr,'''E',num2str(i),'''',' ']; %#ok<AGROW>
        end
    end
end
    
cfg1=[];
cfg1.dataset=[pat,dataset]; % change file name or path+name
cfg1.trialfun='trialfun_beg';
cfg2=ft_definetrial(cfg1);
hdr=ft_read_header([pat,dataset]);
pts=hdr.orig.epoch_data.pts_in_epoch;
epochs=(floor(pts/hdr.Fs/5)); % to read 5s epochs
%cfg2.channel='MEG';
%cfg2.channel={ 'A22' 'A2' 'A104' 'A241' 'A138' 'A214' 'A71' 'A26' 'A93' 'A39' 'A125' 'A20' 'A65' 'A9' 'A8' 'A95' 'A114' 'A175' 'A16' 'A228' 'A35' 'A191' 'A37' 'A170' 'A207' 'A112' 'A224' 'A82' 'A238' 'A202' 'A220' 'A28' 'A239' 'A13' 'A165' 'A204' 'A233' 'A98' 'A25' 'A70' 'A72' 'A11' 'A47' 'A160' 'A64' 'A3' 'A177' 'A63' 'A155' 'A10' 'A127' 'A67' 'A115' 'A247' 'A174' 'A194' 'A5' 'A242' 'A176' 'A78' 'A168' 'A31' 'A223' 'A245' 'A219' 'A12' 'A186' 'A105' 'A222' 'A76' 'A50' 'A188' 'A231' 'A45' 'A180' 'A99' 'A234' 'A215' 'A235' 'A181' 'A38' 'A230' 'A91' 'A212' 'A24' 'A66' 'A42' 'A96' 'A57' 'A86' 'A56' 'A116' 'A151' 'A141' 'A120' 'A189' 'A80' 'A210' 'A143' 'A113' 'A27' 'A137' 'A135' 'A167' 'A75' 'A240' 'A206' 'A107' 'A130' 'A100' 'A43' 'A200' 'A102' 'A132' 'A183' 'A199' 'A122' 'A19' 'A62' 'A21' 'A229' 'A84' 'A213' 'A55' 'A32' 'A85' 'A146' 'A58' 'A60' 'A88' 'A79' 'A169' 'A54' 'A203' 'A145' 'A103' 'A163' 'A139' 'A49' 'A166' 'A156' 'A128' 'A68' 'A159' 'A236' 'A161' 'A121' 'A4' 'A61' 'A6' 'A126' 'A14' 'A94' 'A15' 'A193' 'A150' 'A227' 'A59' 'A36' 'A225' 'A195' 'A30' 'A109' 'A172' 'A108' 'A81' 'A171' 'A218' 'A173' 'A201' 'A74' 'A29' 'A164' 'A205' 'A232' 'A69' 'A157' 'A97' 'A217' 'A101' 'A124' 'A40' 'A123' 'A153' 'A178' 'A1' 'A179' 'A33' 'A147' 'A117' 'A148' 'A87' 'A89' 'A243' 'A119' 'A52' 'A142' 'A211' 'A190' 'A53' 'A192' 'A73' 'A226' 'A136' 'A184' 'A51' 'A237' 'A77' 'A129' 'A131' 'A198' 'A197' 'A182' 'A46' 'A92' 'A41' 'A90' 'A7' 'A23' 'A83' 'A154' 'A34' 'A17' 'A18' 'A248' 'A149' 'A118' 'A208' 'A152' 'A140' 'A144' 'A209' 'A110' 'A111' 'A244' 'A185' 'A246' 'A162' 'A106' 'A187' 'A48' 'A221' 'A196' 'A133' 'A158' 'A44' 'A134' 'A216' }
cfg2.channel=eval(['{',chanstr,'}']);
cfg2.bpfilter='yes';
cfg2.bpfreq=[3 70];
cfg2.padding=0.05;
for i=2:(epochs -1) % skipping beg and end 5s to allow padding
    trl((i-1),1)=round((i*5*hdr.Fs-5*hdr.Fs)+1); %#ok<AGROW>
end
trl(:,2)=trl(:,1)+round(5*hdr.Fs);
trl(:,3)=zeros(size(trl,1),1);
trl=double(trl);
cfg3=cfg2;
cfg3.trl=trl;
eEpi=ft_preprocessing(cfg3);
%% comp analysis
% pca/ica
cfg4            = [];
comp_e = componentanalysis(cfg4, eEpi);
cfg5.layout='4D248.lay';
cfg5.comp=1:10;
figure;
comppic=componentbrowser(cfg5,comp_e); %#ok<NASGU>
clear eEpi;
rawEpi=preprocessing(cfg2);

cfg6 = [];
cfg6.topo      = comp_e.topo;
cfg6.topolabel = comp_e.topolabel;
comp     = componentanalysis(cfg6, rawEpi);
save([pat,'comp'],'comp');
%%
% end
% save([pat,'trigger'],'trigger')
end


