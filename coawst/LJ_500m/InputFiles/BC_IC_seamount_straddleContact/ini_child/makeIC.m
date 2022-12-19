oldFile = '../../BC_IC_flat/ini_child/LJ_ic_child.nc';
gridFile = '../../Grid_seamount_straddleContact/LJ_500m_child.nc';
newFile = 'LJ_ic_child.nc';

unix(['cp ',oldFile,' ',newFile])

h = nc_varget(gridFile,'h');
nc_varput(newFile,'h',h);
