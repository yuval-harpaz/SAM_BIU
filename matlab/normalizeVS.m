function vsN=normalizeVS(vs,vsBL)

sd=std(vsBL');sd=sd'; % computing SD to make z score channels.
for i=2:size(vs,2)
    sd(:,i)=sd(:,1);
end
vsN=vs./sd;