fileOld = 'UH_GUAMFinner_1km_bdry.nc_ORIG';
fileNew = 'Flat_bdry_GUAMFinner_1km.nc';
fileIC  = 'ini_078/Flat_078_ic_GUAMFinner_1km.nc';
unix(['cp ',fileOld,' ',fileNew]);

%% temp

root = 'temp';
temp = nc_varget(fileIC,'temp');
[NZ,NY,NX] = size(temp);

dum = nc_varget(fileNew,[root,'_west']);
[nt,nz,ny] = size(dum);
for tt=1:nt
    dum(tt,:,:) = sq(temp(:,:,1));
end;
nc_varput(fileNew,[root,'_west'],dum);

dum = nc_varget(fileNew,[root,'_east']);
[nt,nz,ny] = size(dum);
for tt=1:nt
    dum(tt,:,:) = sq(temp(:,:,end));
end;
nc_varput(fileNew,[root,'_east'],dum);


dum = nc_varget(fileNew,[root,'_south']);
[nt,nz,ny] = size(dum);
for tt=1:nt
    dum(tt,:,:) = sq(temp(:,1,:));
end;
nc_varput(fileNew,[root,'_south'],dum);

dum = nc_varget(fileNew,[root,'_north']);
[nt,nz,ny] = size(dum);
for tt=1:nt
    dum(tt,:,:) = sq(temp(:,end,:));
end;
nc_varput(fileNew,[root,'_north'],dum);

aaa=5;


%% salt

root = 'salt';
temp = nc_varget(fileIC,'salt');
[NZ,NY,NX] = size(temp);

dum = nc_varget(fileNew,[root,'_west']);
[nt,nz,ny] = size(dum);
for tt=1:nt
    dum(tt,:,:) = sq(temp(:,:,1));
end;
nc_varput(fileNew,[root,'_west'],dum);

dum = nc_varget(fileNew,[root,'_east']);
[nt,nz,ny] = size(dum);
for tt=1:nt
    dum(tt,:,:) = sq(temp(:,:,end));
end;
nc_varput(fileNew,[root,'_east'],dum);


dum = nc_varget(fileNew,[root,'_south']);
[nt,nz,ny] = size(dum);
for tt=1:nt
    dum(tt,:,:) = sq(temp(:,1,:));
end;
nc_varput(fileNew,[root,'_south'],dum);

dum = nc_varget(fileNew,[root,'_north']);
[nt,nz,ny] = size(dum);
for tt=1:nt
    dum(tt,:,:) = sq(temp(:,end,:));
end;
nc_varput(fileNew,[root,'_north'],dum);

aaa=5;


%% zeta

root = 'zeta';

dum = nc_varget(fileNew,[root,'_west']);
nc_varput(fileNew,[root,'_west'],0.*dum);

dum = nc_varget(fileNew,[root,'_east']);
nc_varput(fileNew,[root,'_east'],0.*dum);

dum = nc_varget(fileNew,[root,'_north']);

