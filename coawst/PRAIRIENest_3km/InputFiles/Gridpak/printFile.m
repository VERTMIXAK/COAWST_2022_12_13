function F = printFile(fileName)

lonRho = nc_varget(fileName,'lon_rho');
lonPsi = nc_varget(fileName,'lon_psi');
lonU   = nc_varget(fileName,'lon_u');
lonV   = nc_varget(fileName,'lon_v');

latRho = nc_varget(fileName,'lat_rho');
latPsi = nc_varget(fileName,'lat_psi');
latU   = nc_varget(fileName,'lat_u');
latV   = nc_varget(fileName,'lat_v');

fig(100);clf
myX=lonRho(:);
myY=latRho(:);
plot(myX,myY,'.r');
hold on; title('rho vs psi')
myX=lonPsi(:);
myY=latPsi(:);
plot(myX,myY,'.b');

fig(101);clf
myX=lonRho(:);
myY=latRho(:);
plot(myX,myY,'.r');
hold on; title('rho vs u')
myX=lonU(:);
myY=latU(:);
plot(myX,myY,'.b');

fig(102);clf
myX=lonRho(:); 
myY=latRho(:);
plot(myX,myY,'.r');
hold on; title('rho vs v')
myX=lonV(:);
myY=latV(:);
plot(myX,myY,'.b');