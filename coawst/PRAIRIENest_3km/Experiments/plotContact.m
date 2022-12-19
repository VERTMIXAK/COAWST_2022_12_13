clear;close all;tabwindow

myDir = 'PRAIRIENest_3km_2022_074_deadStillNesting_oneWay_allClo_lotsaWrites2/netcdfOutput/';
% myDir = 'PRAIRIENest_1km_2022_074_deadStillNesting_oneWay_flatBottom/netcdfOutput/';
% myDir = 'PRAIRIENest_1km_2022_074_deadStillNesting_twoWay/netcdfOutput/';

% parentFile = [myDir,'guam_his_00003.nc'];
% parentFile2 = [myDir,'guam_his2_00003.nc'];
% childFile = [myDir,'guam_his_nest_00003.nc'];
% childFile2 = [myDir,'guam_his2_nest_00003.nc']

parentFile = [myDir,'guam_his_00001.nc'];
parentFile2 = [myDir,'guam_his2_00001.nc'];
childFile = [myDir,'guam_his_nest_00001.nc'];
childFile2 = [myDir,'guam_his2_nest_00001.nc']


hA = nc_varget(parentFile,'h');
lonArho = nc_varget(parentFile,'lon_rho');
latArho = nc_varget(parentFile,'lat_rho');
lonAu = nc_varget(parentFile,'lon_u');
latAu = nc_varget(parentFile,'lat_u');
lonAv = nc_varget(parentFile,'lon_v');
latAv = nc_varget(parentFile,'lat_v');

hB = nc_varget(childFile,'h');
lonBrho = nc_varget(childFile,'lon_rho');
latBrho = nc_varget(childFile,'lat_rho');
lonBu = nc_varget(childFile,'lon_u');
latBu = nc_varget(childFile,'lat_u');
lonBv = nc_varget(childFile,'lon_v');
latBv = nc_varget(childFile,'lat_v');

lonmaxRho = max(lonBrho(:));
lonminRho = min(lonBrho(:));
latmaxRho = max(latBrho(:));
latminRho = min(latBrho(:));

lonmaxU = max(lonBu(:));
lonminU = min(lonBu(:));
latmaxU = max(latBu(:));
latminU = min(latBu(:));

lonmaxV = max(lonBv(:));
lonminV = min(lonBv(:));
latmaxV = max(latBv(:));
latminV = min(latBv(:));


%% Get indices for rho grid

latDelta = latArho - latminRho;
lonDelta = lonArho - lonminRho;
myDist = sqrt( latDelta.^2 + lonDelta.^2 );
[jMin,iMin] = find ( min(myDist(:)) == myDist);

latDelta = latArho - latmaxRho;
lonDelta = lonArho - lonmaxRho;
myDist = sqrt( latDelta.^2 + lonDelta.^2 );
[jMax,iMax] = find ( min(myDist(:)) == myDist);

latArho(jMin:jMin+3,iMin:iMin+3);
latBrho(1:5,1:5);


%% plot h

delta = .1;

% fig(3);clf
% pcolorjw(lonArho,latArho,hA);shading flat;hold on
% xlim([lonminRho-delta lonmaxRho+delta]);ylim([latminRho-delta latmaxRho+delta])
% line([lonminRho lonminRho],[latminRho latmaxRho])
% line([lonmaxRho lonmaxRho],[latminRho latmaxRho])
% line([lonminRho lonmaxRho],[latminRho latminRho])
% line([lonminRho lonmaxRho],[latmaxRho latmaxRho])
% caxis([5600 6000]);
% colorbar;title('grid a with contact boundary drawn')
% 
% 
% fig(4);clf
% pcolorjw(lonArho,latArho,hA);shading flat
% xlim([lonminRho-delta lonmaxRho+delta]);ylim([latminRho-delta latmaxRho+delta]);
% caxis([5600 6000]);
% hold on
% line([lonminRho lonminRho],[latminRho latmaxRho])
% line([lonmaxRho lonmaxRho],[latminRho latmaxRho])
% line([lonminRho lonmaxRho],[latminRho latminRho])
% line([lonminRho lonmaxRho],[latmaxRho latmaxRho])
% pcolorjw(lonBrho,latBrho,hB);shading flat
% colorbar;title('grid a with grid b overlay')

done('h')


%% plot U

uA = nc_varget(parentFile,'u');
uB = nc_varget(childFile,'u');

[ntA,nz,ny,nx] = size(uA);
[ntB,nz,ny,nx] = size(uB);
myTa = ntA-3 + 1;
myTb = ntB-9 + 4;
myZ = nz;

myUa = sq(uA(myTa,myZ,:,:));
myUb = sq(uB(myTb,myZ,:,:));
myLim = max(abs(myUb(:)));
% myMax = max(myUa(:));
% myMin = min(myUa(:));
myMax =2e-4;
myMin = -2e-4;

fig(10);clf;
pcolorjw(lonAu,latAu,myUa);shading flat;colorbar
xlim([lonminU-delta lonmaxU+delta]);ylim([latminU-delta latmaxU+delta]);
% caxis(myLim*[-1 1]);
caxis([myMin myMax]);
title(['u on A grid, nz = ',num2str(myZ),'  nt = ',num2str(myTa)])
hold on
line([lonminU lonminU],[latminU latmaxU])
line([lonmaxU lonmaxU],[latminU latmaxU])
line([lonminU lonmaxU],[latminU latminU])
line([lonminU lonmaxU],[latmaxU latmaxU])

fig(11);clf;
pcolorjw(lonAu,latAu,myUa);shading flat;colorbar
xlim([lonminU-delta lonmaxU+delta]);ylim([latminU-delta latmaxU+delta]);
% caxis(myLim*[-1 1]);
caxis([myMin myMax]);
title(['u on A grid with u on B grid overlay, nz = ',num2str(myZ),'  ntA = ',num2str(myTa),'  ntB = ',num2str(myTb)])
hold on
line([lonminU lonminU],[latminU latmaxU])
line([lonmaxU lonmaxU],[latminU latmaxU])
line([lonminU lonmaxU],[latminU latminU])
line([lonminU lonmaxU],[latmaxU latmaxU])
pcolorjw(lonBu,latBu,myUb);shading flat

fig(12);clf;
pcolorjw(lonBu,latBu,myUb);shading flat;colorbar
% caxis(myLim*[-1 1]);
caxis([myMin myMax]);
title(['u on B grid, nz = ',num2str(myZ),'  ntA = ',num2str(myTa),'  ntB = ',num2str(myTb)])


myLim = max(abs(myUa(:)))/1;
% myMax = max(myUa(:))/1;
% myMin = min(myUa(:))/1;
fig(13);clf;
pcolorjw(lonAu,latAu,myUa);shading flat;colorbar
% caxis(myLim*[-1 1]);
caxis([myMin myMax]);
title(['u on A grid, nz = ',num2str(myZ),'  ntB = ',num2str(myTa),'  ntB = ',num2str(myTb)])

done('u')


%% plot V

vA = nc_varget(parentFile,'v');
vB = nc_varget(childFile,'v');

[nt,nz,ny,nx] = size(vA);

myVa = sq(vA(myT,myZ,:,:));
myVb = sq(vB(myT,myZ,:,:));
myLim = max(abs(myVb(:)));
myMax = max(myVb(:));
myMin = min(myVb(:));

fig(20);clf;
pcolorjw(lonAv,latAv,myVa);shading flat;colorbar
xlim([lonminV-delta lonmaxV+delta]);ylim([latminV-delta latmaxV+delta]);
% caxis(myLim*[-1 1]);
caxis([myMin myMax]);
title(['v on A grid, nz = ',num2str(myZ),'  nt = ',num2str(myT)])
hold on
line([lonminV lonminV],[latminV latmaxV])
line([lonmaxV lonmaxV],[latminV latmaxV])
line([lonminV lonmaxV],[latminV latminV])
line([lonminV lonmaxV],[latmaxV latmaxV])





fig(21);clf;
pcolorjw(lonAv,latAv,myVa);shading flat;colorbar
xlim([lonminV-delta lonmaxV+delta]);ylim([latminV-delta latmaxV+delta]);
% caxis(myLim*[-1 1]);
caxis([myMin myMax]);
title(['v on A grid with v on B grid overlay, nz = ',num2str(myZ),'  nt = ',num2str(myT)])
hold on
line([lonminV lonminV],[latminV latmaxV])
line([lonmaxV lonmaxV],[latminV latmaxV])
line([lonminV lonmaxV],[latminV latminV])
line([lonminV lonmaxV],[latmaxV latmaxV])
pcolorjw(lonBv,latBv,myVb);shading flat

fig(22);clf;
pcolorjw(lonBv,latBv,myVb);shading flat;colorbar
% caxis(myLim*[-1 1]);
caxis([myMin myMax]);
title(['v on B grid, nz = ',num2str(myZ),'  nt = ',num2str(myT)])

done('v')


%% W

wA = nc_varget(parentFile,'w');
wB = nc_varget(childFile,'w');

myWa = sq(wA(myT,myZ,:,:));
myWb = sq(wB(myT,myZ,:,:));
myLim = max(abs(myWb(:)));
myMax = max(myWb(:));
myMin = min(myWb(:));

fig(30);clf;
pcolorjw(lonArho,latArho,myWa);shading flat;colorbar
xlim([lonminRho-delta lonmaxRho+delta]);ylim([latminRho-delta latmaxRho+delta]);
% caxis(myLim*[-1 1]);
caxis([myMin myMax]);
title(['w on A grid, nz = ',num2str(myZ),'  nt = ',num2str(myT)])
hold on
line([lonminRho lonminRho],[latminRho latmaxRho])
line([lonmaxRho lonmaxRho],[latminRho latmaxRho])
line([lonminRho lonmaxRho],[latminRho latminRho])
line([lonminRho lonmaxRho],[latmaxRho latmaxRho])




fig(31);clf;
pcolorjw(lonArho,latArho,myWa);shading flat;colorbar
xlim([lonminRho-delta lonmaxRho+delta]);ylim([latminRho-delta latmaxRho+delta]);
caxis(myLim*[-1 1]);
% caxis(myLim*[-1 1]);
caxis([myMin myMax]);
title(['w on A grid with w on B grid overlay, nz = ',num2str(myZ),'  nt = ',num2str(myT)])
hold on
line([lonminRho lonminRho],[latminRho latmaxRho])
line([lonmaxRho lonmaxRho],[latminRho latmaxRho])
line([lonminRho lonmaxRho],[latminRho latminRho])
line([lonminRho lonmaxRho],[latmaxRho latmaxRho])
pcolorjw(lonBrho,latBrho,myWb);shading flat;colorbar


fig(32);clf;
pcolorjw(lonBrho,latBrho,myWb);shading flat;colorbar
% caxis(myLim*[-1 1]);
caxis([myMin myMax]);
title(['w on B grid, nz = ',num2str(myZ),'  nt = ',num2str(myT)])

done('w')


%% plot Ubar


uA = nc_varget(parentFile2,'ubar');
uB = nc_varget(childFile2,'ubar');

[nt,ny,nx] = size(uA);


myUa = sq(uA(myT,:,:));
myUb = sq(uB(myT,:,:));
myLim = max(abs(myUb(:)));
myMax = max(myUb(:));
myMin = min(myUb(:));

fig(40);clf;
pcolorjw(lonAu,latAu,myUa);shading flat;colorbar
xlim([lonminU-delta lonmaxU+delta]);ylim([latminU-delta latmaxU+delta]);
% caxis(myLim*[-1 1]);
caxis([myMin myMax]);
title(['ubar on A grid, nt = ',num2str(myT)])
hold on
line([lonminU lonminU],[latminU latmaxU])
line([lonmaxU lonmaxU],[latminU latmaxU])
line([lonminU lonmaxU],[latminU latminU])
line([lonminU lonmaxU],[latmaxU latmaxU])





fig(41);clf;
pcolorjw(lonAu,latAu,myUa);shading flat;colorbar
xlim([lonminU-delta lonmaxU+delta]);ylim([latminU-delta latmaxU+delta]);
% caxis(myLim*[-1 1]);
caxis([myMin myMax]);
title(['ubar on A grid with u on B grid overlay, nt = ',num2str(myT)])
hold on
line([lonminU lonminU],[latminU latmaxU])
line([lonmaxU lonmaxU],[latminU latmaxU])
line([lonminU lonmaxU],[latminU latminU])
line([lonminU lonmaxU],[latmaxU latmaxU])
pcolorjw(lonBu,latBu,myUb);shading flat



fig(42);clf;
pcolorjw(lonBu,latBu,myUb);shading flat;colorbar
% caxis(myLim*[-1 1]);
caxis([myMin myMax]);
title(['ubar on B grid, nt = ',num2str(myT)])

done('ubar')


%% plot Vbar


vA = nc_varget(parentFile2,'vbar');
vB = nc_varget(childFile2,'vbar');

[nt,ny,nx] = size(vA);


myVa = sq(vA(myT,:,:));
myVb = sq(vB(myT,:,:));
myLim = max(abs(myVb(:)));
myMax = max(myVb(:));
myMin = min(myVb(:));

fig(50);clf;
pcolorjw(lonAv,latAv,myVa);shading flat;colorbar
xlim([lonminV-delta lonmaxV+delta]);ylim([latminV-delta latmaxV+delta]);
% caxis(myLim*[-1 1]);
caxis([myMin myMax]);
title(['vbar on A grid, nt = ',num2str(myT)])
hold on
line([lonminV lonminV],[latminV latmaxV])
line([lonmaxV lonmaxV],[latminV latmaxV])
line([lonminV lonmaxV],[latminV latminV])
line([lonminV lonmaxV],[latmaxV latmaxV])





fig(51);clf;
pcolorjw(lonAv,latAv,myVa);shading flat;colorbar
xlim([lonminV-delta lonmaxV+delta]);ylim([latminV-delta latmaxV+delta]);
% caxis(myLim*[-1 1]);
caxis([myMin myMax]);
title(['vbar on A grid with v on B grid overlay, nt = ',num2str(myT)])
hold on
line([lonminV lonminV],[latminV latmaxV])
line([lonmaxV lonmaxV],[latminV latmaxV])
line([lonminV lonmaxV],[latminV latminV])
line([lonminV lonmaxV],[latmaxV latmaxV])
pcolorjw(lonBv,latBv,myVb);shading flat



fig(52);clf;
pcolorjw(lonBv,latBv,myVb);shading flat;colorbar
% caxis(myLim*[-1 1]);
caxis([myMin myMax]);
title(['vbar on B grid, nt = ',num2str(myT)])

done('vbar')

