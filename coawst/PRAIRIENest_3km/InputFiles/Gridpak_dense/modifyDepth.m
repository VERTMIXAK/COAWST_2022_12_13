file = 'PRAIRIE_3km_dense.nc';

dum = nc_varget(file,'hraw');
h = sq(dum(4,:,:));

fig(1);clf;pcolor(h);shading flat;colorbar

h = h - 4000;
fig(2);clf;pcolor(h);shading flat;colorbar

h(h<1000) = 1000;
fig(3);clf;pcolor(h);shading flat;colorbar


dum(5,:,:) = h;
dum(6,:,:) = h*0 + max(h(:));

nc_varput(file,'hraw',dum);

