

load tempSurf

Tri1=rh((rh(1)+2):end,1:3);
Tri1=Tri1+1;
X1=rh(2:(rh(1)+1),1);
Y1=rh(2:(rh(1)+1),2);
Z1=rh(2:(rh(1)+1),3);

Tri=lh((lh(1)+2):end,1:3);
Tri=Tri+1;
X=lh(2:(lh(1)+1),1);
Y=lh(2:(lh(1)+1),2);
Z=lh(2:(lh(1)+1),3);

xMR=mean([min([X1;X]) max([X1;X])]);
yMR=mean([min([Y1;Y]) max([Y1;Y])]);
zMR=mean([min([Z1;Z]) max([Z1;Z])]);
C1=sqrt(X1.^2+((Y1-yMR)*0.785).^2+(Z1-zMR).^2);
C=sqrt(X.^2+((Y-yMR)*0.785).^2+(Z-zMR).^2);

figure;
trisurf(Tri1,X1,Y1,Z1,C1,'EdgeColor','none')
hold on
trisurf(Tri,X,Y,Z,C,'EdgeColor','none')
colormap('gray')
alpha(.7)
view(-90,0)
grid off
%view(90,0)
