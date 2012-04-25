function vsSlice2afni(allInd,vs,prefix);
allInd=allInd.*10;
textOP=zeros(size(vs,1),4);
textOP(:,1:3)=allInd;
for i=1:size(vs,2);
    textOP(:,4)=round(vs(:,i).*1000);
    rshOP=reshape(textOP',size(textOP,1)*4,1);
    fid = fopen('txtVS', 'w');
    fprintf(fid,'%d\t%d\t%d\t%6.3f\n',rshOP);
    fclose(fid);
    %!~/abin/3dUndump -orient PRI -xyz -dval 1 -master ortho+orig -prefix test txtTest
    !rm test+*
    !~/abin/3dUndump -orient PRI -xyz -master ortho+orig -dval 0 -prefix test txtVS
    !rm test1+*
    !~/abin/3dresample -dxyz 5 5 5 -prefix test1 -inset test+orig -rmode Cu
    !rm test2+*
    !~/abin/3dfractionize -template test1+orig -input test+orig -preserve -prefix test2
    eval(['!~/abin/3dcalc -a test2+orig -expr ''','abs(a)/1000''',' -prefix ',prefix,num2str(i)]);
    display(['wrote ',num2str(i),' of ',num2str(size(vs,2)),' files']);
end
end