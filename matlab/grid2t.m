function grid2t(grid)
% grid is a fieldtrip structure or columns of x y z coordinates in cm

if ~isfield(grid,'pos')
    tmp=grid;
    grid={};
    grid.pos=tmp;
    clear tmp
    grid.inside=1:size(grid.pos,1);
else
    grid=ft_convert_units(grid,'cm');
end
pnt=grid.pos(grid.inside,:);
PNT=reshape(pnt',size(pnt,1)*3,1);
if exist('pnt.txt','file')
    !rm pnt.txt
end

fid = fopen('pnt.txt', 'w');
fprintf(fid,'%s\n',num2str(size(pnt,1)));
fprintf(fid,'%f\t%f\t%f\n',PNT);
fclose(fid);