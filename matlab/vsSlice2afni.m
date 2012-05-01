function vsSlice2afni(allInd,vs,prefix);
% get range of vs data
minVSval=min(min(abs(vs)));fac=10^(ceil(-log10(minVSval)));
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
    eval(['!~/abin/3dcalc -a test2+orig -expr ''','abs(a)/',num2str(fac),'''',' -prefix ',prefix,num2str(i)]);
    display(['wrote ',num2str(i),' of ',num2str(size(vs,2)),' files']);
end
end