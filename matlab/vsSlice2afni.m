function vsSlice2afni(allInd,vs,prefix,Abs);
try
    if isempty(Abs)
        Abs=true;
    end
catch
    Abs=true;
end
% get range of vs data
maxVSval=max(max(abs(vs)));
fac=(2^15-1)./maxVSval; % max value is 32767 (signed short 16bit, 2^15-1)
%if size(
allInd=allInd.*10;
textOP=zeros(size(vs,1),4);
textOP(:,1:3)=allInd;
for i=1:size(vs,2);
    textOP(:,4)=round(vs(:,i).*fac);
    rshOP=reshape(textOP',size(textOP,1)*4,1);
    fid = fopen('VS.txt', 'w');
    fprintf(fid,'%d\t%d\t%d\t%6.3f\n',rshOP);
    fclose(fid);
    %!~/abin/3dUndump -orient PRI -xyz -dval 1 -master ortho+orig -prefix test txtTest
    !rm test+*
    if exist('ortho+orig.BRIK','file')
        !~/abin/3dUndump -orient PRI -xyz -master ortho+orig -dval 0 -prefix test VS.txt
    elseif exist('warped+orig.BRIK','file')
        !~/abin/3dUndump -orient PRI -xyz -master warped+orig -dval 0 -prefix test VS.txt
    else
        error('no warped or ortho!')
    end
    !rm test1+*
    !~/abin/3dresample -dxyz 5 5 5 -prefix test1 -inset test+orig -rmode Cu
    !rm test2+*
    !~/abin/3dfractionize -template test1+orig -input test+orig -preserve -prefix test2
    a='abs(a)/';
    if ~Abs
        a='a/';
    end
    numstr=num2str(i);
    % pad with zeros
    while length(numstr)<3
        numstr=['0',numstr];
    end
    eval(['!~/abin/3dcalc -a test2+orig -expr ''',a,num2str(fac),'''',' -prefix ',prefix,numstr]);
    display(['wrote ',num2str(i),' of ',num2str(size(vs,2)),' files']);
end
end