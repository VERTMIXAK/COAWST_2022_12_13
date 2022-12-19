clear; close all;tabwindow;

denseFile   = '../Gridpak_dense/PRAIRIE_3km_dense.nc';
templateFile   = '../Gridpak_parent/PRAIRIE_3km_parent.nc_template';
parentFile   = 'PRAIRIE_3km.nc';
parentDataFile = 'PRAIRIE_3km_data.nc';

childFile_oldMethod    = 'PRAIRIENest_3km.nc_oldMethod';
childFile    = 'PRAIRIENest_3km.nc';
childDataFile    = 'PRAIRIENest_3km.nc_data';
contactsFile = 'PRAIRIENest_contacts_3km.nc';


unix(['\rm *ths.txt ',childFile,' ',parentFile,' ',childFile_oldMethod,' ',contactsFile,' ',childDataFile])




aaa=5;


%% write the subset data into the parent file template 


% NOTE don't do the pn, pm, dndx, dmde fields because those numbers in the
% subset data go with the finer grid.

unix(['cp ',templateFile,' ',parentFile]);

fieldList = {
    'lat_rho','lat_psi','lat_u','lat_v',         ...
    'lon_rho','lon_psi','lon_u','lon_v',         ...
    'x_rho','x_psi','x_u','x_v',         ...
    'y_rho','y_psi','y_u','y_v',         ...
    'mask_rho','mask_psi','mask_u','mask_v',         ...
    'h','f','angle'
    };

for ff=1:length(fieldList);
    dum = nc_varget(parentDataFile,char(fieldList(ff)));
    nc_varput(parentFile,char(fieldList(ff)),dum);
end;

%% Define the core area of my grid

myLon = nc_varget(parentFile,'lon_psi');
myLat = nc_varget(parentFile,'lat_psi');

mask = nc_varget(parentFile,'mask_psi');

latLL = 10.6;
lonLL = 152.5;

latDelta = myLat - latLL;
lonDelta = myLon - lonLL;
myDist = sqrt( latDelta.^2 + lonDelta.^2);
[jCoreLL,iCoreLL] = find( min(myDist(:)) == myDist)
[myLat(jCoreLL,iCoreLL) - latLL,myLon(jCoreLL,iCoreLL) - lonLL]

 


latUR = 11.6; 
lonUR = 153.5;

dumY = myLat - latUR;
dumX = myLon - lonUR;
myDist = sqrt( dumY.^2 + dumX.^2);
[jCoreUR,iCoreUR] = find( min(myDist(:)) == myDist)
[myLat(jCoreUR,iCoreUR) - latUR,myLon(jCoreUR,iCoreUR) - lonUR]*111

% fig(1);clf;pcolor(myLon(jCoreLL:jCoreUR,iCoreLL:iCoreUR),myLat(jCoreLL:jCoreUR,iCoreLL:iCoreUR),mask(jCoreLL:jCoreUR,iCoreLL:iCoreUR));shading flat

%% Make the subgrid the old way

coarse2fine(parentFile,childFile_oldMethod,3,iCoreLL,iCoreUR,jCoreLL,jCoreUR)

% note that the child file produced this way works perfectly fine in the
% contacts script, so the fine detail in this netcdf file is just what that
% script wants.



%% Make the subgrid by subsetting

hskip = 3;

xiStart =  hskip * (iCoreLL - 1)         ;
nXi =      hskip * (iCoreUR-iCoreLL + 1) ;
etaStart = hskip * (jCoreLL - 1)         ;
nEta =     hskip * (jCoreUR-jCoreLL + 1) ;

% rhoXiStart  = xiStart  + 0 ;         rhoXiEnd  = rhoXiStart  + (nXi  + 1) - 1;
% rhoEtaStart = etaStart + 0 ;         rhoEtaEnd = rhoEtaStart + (nEta + 1) - 1;
% psiXiStart  = xiStart  + 1 ;         psiXiEnd  = psiXiStart  + (nXi  + 0) - 1;
% psiEtaStart = etaStart + 1 ;         psiEtaEnd = psiEtaStart + (nEta + 0) - 1;
% uXiStart    = xiStart  + 1 ;         uXiEnd    = uXiStart    + (nXi  + 0) - 1;
% uEtaStart   = etaStart + 0 ;         uEtaEnd   = uEtaStart   + (nEta + 1) - 1;
% vXiStart    = xiStart  + 0 ;         vXiEnd    = vXiStart    + (nXi  + 1) - 1;
% vEtaStart   = etaStart + 1 ;         vEtaEnd   = vEtaStart   + (nEta + 0) - 1;

rhoXiStart  = xiStart  + 0 ;         rhoXiEnd  = rhoXiStart  + (nXi  + 1) - 1;
rhoEtaStart = etaStart + 0 ;         rhoEtaEnd = rhoEtaStart + (nEta + 1) - 1;

psiXiStart  = xiStart  + 0 ;         psiXiEnd  = psiXiStart  + (nXi  + 0) - 1;

psiEtaStart = etaStart + 0 ;         psiEtaEnd = psiEtaStart + (nEta + 0) - 1;
uXiStart    = xiStart  + 0 ;         uXiEnd    = uXiStart    + (nXi  + 0) - 1;
uEtaStart   = etaStart + 0 ;         uEtaEnd   = uEtaStart   + (nEta + 1) - 1;
vXiStart    = xiStart  + 0 ;         vXiEnd    = vXiStart    + (nXi  + 1) - 1;
vEtaStart   = etaStart + 0 ;         vEtaEnd   = vEtaStart   + (nEta + 0) - 1;


unix([
    'ncks '                                                                      ...
          ' -d xi_rho,' ,num2str(rhoXiStart  + 1) ',',num2str(rhoXiEnd  - 1),    ...
          ' -d eta_rho,',num2str(rhoEtaStart + 1),',',num2str(rhoEtaEnd - 1),    ...
          ' -d xi_psi,' ,num2str(psiXiStart  + 1),',',num2str(psiXiEnd  - 1),    ...
          ' -d eta_psi,',num2str(psiEtaStart + 1),',',num2str(psiEtaEnd - 1),    ...
          ' -d xi_u,'   ,num2str(uXiStart    + 1),',',num2str(uXiEnd    - 1),    ...
          ' -d eta_u,'  ,num2str(uEtaStart   + 1),',',num2str(uEtaEnd   - 1),    ...
          ' -d xi_v,'   ,num2str(vXiStart    + 1),',',num2str(vXiEnd    - 1),    ...
          ' -d eta_v,'  ,num2str(vEtaStart   + 1),',',num2str(vEtaEnd   - 1),    ...
          ' ',denseFile,' ',childDataFile
    ])

%% Final step

% It beats the shit out of me why, but the netcdf file produced by
% subsetting doesn't work in the contacts script. I really do want to use
% the numbers, so make a copy of the subgrid file produced by coarse2fine.m
% and the overwrite the fields with the numbers I got by subsetting.

unix(['cp ',childFile_oldMethod,' ',childFile]);

fieldList = {
    'lat_rho','lat_psi','lat_u','lat_v',         ...
    'lon_rho','lon_psi','lon_u','lon_v',         ...
    'x_rho','x_psi','x_u','x_v',         ...
    'y_rho','y_psi','y_u','y_v',         ...
    'mask_rho','mask_psi','mask_u','mask_v',         ...
    'h','f','angle','pn','pm','dndx','dmde'
    };

for ff=1:length(fieldList);
    dum = nc_varget(childDataFile,char(fieldList(ff)));
    nc_varput(childFile,char(fieldList(ff)),dum);
end;

%% Make the contacts file

Gnames = {parentFile, childFile}

[S,G] = contact(Gnames,contactsFile)
