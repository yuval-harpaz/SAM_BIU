function grid2t(grid)
pnt=grid.pos(grid.inside,:)./10;
PNT=reshape(pnt',size(pnt,1)*3,1);
if exist('pnt.txt','file')
    !rm pnt.txt
end

fid = fopen('pnt.txt', 'w');
fprintf(fid,'%s\n',size(pnt,1));
fprintf(fid,'%s\t%s\t%s\n',PNT);
fclose(fid);