% The point of this script is to create the parentDataFile
clear; close all;tabwindow;

denseFile   = '../Gridpak_dense/PRAIRIEinner_1km_dense.nc';
parentDataFile = 'PRAIRIEinner_1km_data.nc';

unix(['\rm *ths.txt *.in gridparam.h sqgrid.in ',parentDataFile])



%% subset to get parent grid data file

hskip = 3;
xiStart = 0;
nXi = 1572;         % This will stop a smidge shy of the RHS
nXi = nXi/hskip;
etaStart = 0;
nEta = 1374;        % This will stop a smidge shy of the top
nEta = nEta/hskip;


rhoXiStart  = xiStart                ;         rhoXiEnd  = rhoXiStart  + (nXi  + 0)*hskip;
rhoEtaStart = etaStart               ;         rhoEtaEnd = rhoEtaStart + (nEta + 0)*hskip;
psiXiStart  = xiStart  + (hskip-1)/2 ;         psiXiEnd  = psiXiStart  + (nXi  - 1)*hskip;
psiEtaStart = etaStart + (hskip-1)/2 ;         psiEtaEnd = psiEtaStart + (nEta - 1)*hskip;
uXiStart    = xiStart  + (hskip-1)/2 ;         uXiEnd    = uXiStart    + (nXi  - 1)*hskip;
uEtaStart   = etaStart               ;         uEtaEnd   = uEtaStart   + (nEta + 0)*hskip;
vXiStart    = xiStart                ;         vXiEnd    = vXiStart    + (nXi  + 0)*hskip;
vEtaStart   = etaStart + (hskip-1)/2 ;         vEtaEnd   = vEtaStart   + (nEta - 1)*hskip;

unix([
    'ncks '                                                                                 ...
          ' -d xi_rho,' ,num2str(rhoXiStart) ,',',num2str(rhoXiEnd) ,',',num2str(hskip),    ...
          ' -d eta_rho,',num2str(rhoEtaStart),',',num2str(rhoEtaEnd),',',num2str(hskip),    ...
          ' -d xi_psi,' ,num2str(psiXiStart) ,',',num2str(psiXiEnd) ,',',num2str(hskip),    ...
          ' -d eta_psi,',num2str(psiEtaStart),',',num2str(psiEtaEnd),',',num2str(hskip),    ...
          ' -d xi_u,'   ,num2str(uXiStart)   ,',',num2str(uXiEnd)   ,',',num2str(hskip),    ...
          ' -d eta_u,'  ,num2str(uEtaStart)  ,',',num2str(uEtaEnd)  ,',',num2str(hskip),    ...
          ' -d xi_v,'   ,num2str(vXiStart)   ,',',num2str(vXiEnd)   ,',',num2str(hskip),    ...
          ' -d eta_v,'  ,num2str(vEtaStart)  ,',',num2str(vEtaEnd)  ,',',num2str(hskip),    ...
          ' ',denseFile,' ',parentDataFile
    ])



% printFile(parentDataFile);


%% Create the sqgrid.in file

xPsi = nc_varget(parentDataFile,'x_psi');
yPsi = nc_varget(parentDataFile,'y_psi');

[ny,nx] = size(yPsi);

myXWest = xPsi(:,1);
myYWest = yPsi(:,1);

myXSouth = xPsi(1,:);
myYSouth = yPsi(1,:);

myXEast = xPsi(:,end);
myYEast = yPsi(:,end);

myXNorth = xPsi(end,:);
myYNorth = yPsi(end,:);

dumWest = zeros(ny,2);
for jj=1:ny
    dumWest(jj,:) = [myXWest(end-jj+1), myYWest(end-jj+1)];
end

dumSouth = zeros(nx,2);
for ii=1:nx
    dumSouth(ii,:) = [myXSouth(ii),myYSouth(ii)];
end

dumEast = zeros(ny,2);
for jj=1:ny
    dumEast(jj,:) = [myXEast(jj), myYEast(jj)];
end

dumNorth = zeros(nx,2);
for ii=1:nx
    dumNorth(ii,:) = [myXNorth(end-ii+1),myYNorth(end-ii+1)];
end

fid=fopen('nx.in','w');
fprintf(fid,'%i\n',nx);
fclose(fid);

fid=fopen('ny.in','w');
fprintf(fid,'%i\n',ny);
fclose(fid);

save('west.in','dumWest','-ascii');
save('south.in','dumSouth','-ascii');
save('east.in','dumEast','-ascii');
save('north.in','dumNorth','-ascii');

gridparam = ['      parameter (   Lm=',num2str(nx-1),'   Mm=',num2str(ny-1),'   )']
save('gridparameter.h','gridparam','-ascii');

unix(['bash makeSqgrid.bash'])

unix(['\rm west.in east.in south.in north.in nx.in ny.in'])

unix(['mv sqgrid.in ../Gridpak_parent'])



