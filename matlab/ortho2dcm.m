function ortho2dcm(data,prefix,patientName)
% data is 256x256x256 such as in [~,data,~,~]=BrikLoad('ortho+orig');
load  ~/SAM_BIU/docs/orthoDicomInfo
if exist('patientName','var')
    if ~isempty(patientName)
        if ischar(patientName)
            orthoDicomInfo.PatientName.FamilyName=patientName;
        else
            display('patientName has to be text')
        end
    end
end
if ~exist('prefix','var')
    prefix='';
end
if isempty(prefix)
    prefix='ortho';
end
display('writing files')
for slicei=1:256
    orthoDicomInfo.InStackPositionNumber=uint32(slicei);
    orthoDicomInfo.ImagePositionPatient(3)=orthoDicomInfo.ImagePositionPatient(3)+1;
    Y=fliplr(squeeze(data(:,257-slicei,:)));
    dcmName=[prefix,num2str(slicei),'.dcm'];
    if slicei<100
        dcmName=[prefix,'0',num2str(slicei),'.dcm'];
        if slicei<10
            dcmName=[prefix,'00',num2str(slicei),'.dcm'];
        end
    end
    dicomwrite(uint16(Y), dcmName, orthoDicomInfo);
    orthoDicomInfo.SliceLocation=orthoDicomInfo.SliceLocation+1;
    disp(dcmName)
end
