function RWhybrid(pat,patient,prefix)
% patient='b026';
% prefix='tf8_';
% pat='/home/yuval/Desktop/STUFF/BF4clinic';
cd (pat);
cd(patient);
source=[prefix,'c,rfhp1.0Hz,ee'];
eval(['!cp ',source,' hyb_c,rfhp1.0Hz,ee'])
pdf=pdf4D(source);
pdf2=pdf4D('hyb_c,rfhp1.0Hz,ee');
chi = channel_index(pdf, {'meg' 'ref' 'TRIGGER' 'RESPONSE' 'UACurrent' 'eeg'}, 'name');
lat = lat2ind(pdf, 4, [0 194]);
data = read_data_block(pdf, lat, chi);
pdfS=pdf4D('/home/yuval/Desktop/STUFF/hybrid/sagit_s1run1/c,rfhp1.0Hz');
chiS = channel_index(pdfS, {'meg' 'ref' 'TRIGGER' 'RESPONSE' 'UACurrent' 'eeg'}, 'name');
load dataS
dataS=dataS(:,1:67817);
dataS(channel_index(pdfS,'A204'),:)=zeros(1,size(dataS,2));
dataS(channel_index(pdfS,'A74'),:)=zeros(1,size(dataS,2));
%rearranging channels
for i=1:size(chi,2)
    dataC(chi(i),:)=data(i,:);
end

for i=1:size(chiS,2)
    dataSC(chiS(i),:)=dataS(i,:);
end
hybrid=dataC;
hybrid(2:274,:)=dataC(2:274,:)+dataSC(2:274,:);
write_data_block(pdf2, hybrid, 1);
cd ..
end