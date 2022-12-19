oldFile = '../../BC_IC_flat/ini_parent/LJ_ic_parent.nc';
gridFile = '../../Grid_seamount_straddleContact/LJ_500m_parent.nc';
newFile = 'LJ_ic_parent.nc';

unix(['cp ',oldFile,' ',newFile])

h = nc_varget(gridFile,'h');
nc_varput(newFile,'h',h);
