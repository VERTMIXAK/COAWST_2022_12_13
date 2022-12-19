parentFile = 'PRAIRIEinner_1km.nc';
childFile = 'PRAIRIEinnerNest_1km.nc';
contactsFile = 'PRAIRIEinnerNest_contacts_1km.nc';

unix(['cp ../Gridpak/',parentFile,' .']);
unix(['cp ../Gridpak/',childFile,' .']);



dum = nc_varget(childFile,'h');
hMin = max(dum(:))
nc_varput(childFile,'h',hMin + 0*dum);


dum = nc_varget(parentFile,'h');
nc_varput(parentFile,'h',hMin + 0*dum);


%% Make the contacts file

Gnames = {parentFile, childFile}

[S,G] = contact(Gnames,contactsFile)