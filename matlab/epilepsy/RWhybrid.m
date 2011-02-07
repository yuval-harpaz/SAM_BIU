patient='b026';
prefix='tf8';
pat='/home/yuval/Desktop/STUFF/BF4clinic';
cd (pat);
cd(patient);
source=[prefix,'_c,rfhp1.0Hz,ee'];
eval(['!cp ',source,' hyb_c,rfhp1.0Hz,ee'])
pdf=pdf4D(source);
pdf2=pdf4D('hyb_c,rfhp1.0Hz,ee');

chi = channel_index(pdf, {'meg' 'ref' 'TRIGGER' 'RESPONSE' 'UACurrent' 'eeg'}, 'name');
lat = lat2ind(pdf, 4, [0 194]);
chn = channel_name(pdf, chi);
data = read_data_block(pdf, lat, chi);
 pdfS=pdf4D('/home/yuval/Desktop/STUFF/hybrid/sagit_s1run1/c,rfhp1.0Hz');
% hdr=get(pdfS,'header');
% latS=lat2ind(pdfS,1,[3 103])
 chiS = channel_index(pdfS, {'meg' 'ref' 'TRIGGER' 'RESPONSE' 'UACurrent' 'eeg'}, 'name');
% chnS = channel_name(pdfS, chiS);
% dataS = read_data_block(pdfS, latS, chiS);
load dataS
dataS=dataS(:,1:67817);
dataS(channel_index(pdfS,'A204'),:)=zeros(1,size(dataS,2));
dataS(channel_index(pdfS,'A74'),:)=zeros(1,size(dataS,2));

%for i=1:274; hybrid(chi(i),:)=data(chi(i),:)+dataS(chiS(i),:);end
%save hybrid hybrid
%rearranging channels
for i=1:size(chi,2)
    dataC(chi(i),:)=data(i,:);
end

for i=1:size(chiS,2)
    dataSC(chiS(i),:)=dataS(i,:);
end
%dataC=dataC(1:274,:);
hybrid=dataC;
hybrid(2:274,:)=dataC(2:274,:)+dataSC(2:274,:);

%pdfH=pdf4D('/opt/msw/data/megdaw_data0/hybrid20s/1Hz34EEGf/21.05.09@11:58/1/B1B2_200_c,rfhp1.0Hz,ee,fbp1-40,o,n,cc');

write_data_block(pdf2, hybrid, 1);
% 
% noise=dataC;
% noise(1:274,:)=dataSC;
% pdfN=pdf4D('/home/yuval/Desktop/hybrid/180_200s/noise/180_200_c,rfhp1.0Hz,ee');
% write_data_block(pdfN, hybrid, 1);
% 
