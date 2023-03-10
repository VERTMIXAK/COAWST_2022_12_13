import numpy as np
from datetime import datetime
import netCDF4 as netCDF

import pycnal
import pycnal_toolbox


##  load 2-dimentional interannual discharge data
print('Load lat_lon')
nc_data = netCDF.Dataset('lat_lon.nc', 'r')
#runoff = nc_data.variables['runoff'][:]
lon = nc_data.variables['lon'][:]
lat = nc_data.variables['lat'][:]
mask = nc_data.variables['coast_cells'][:]
mask = np.where(mask < 0, 0, mask)
Mp, Lp = lon.shape

lon_corner = np.zeros([Mp+1,Lp+1])
lat_corner = np.zeros([Mp+1,Lp+1])
lon_corner[1:Mp,1:Lp] = 0.25*(lon[:Mp-1,:Lp-1] + lon[1:Mp,:Lp-1] + \
                              lon[:Mp-1,1:Lp] + lon[1:Mp,1:Lp])
lat_corner[1:Mp,1:Lp] = 0.25*(lat[:Mp-1,:Lp-1] + lat[1:Mp,:Lp-1] + \
                              lat[:Mp-1,1:Lp] + lat[1:Mp,1:Lp])
lon_corner[0,1:Lp] = 2*lon_corner[1,1:Lp] - lon_corner[2,1:Lp]
lon_corner[Mp,1:Lp] = 2*lon_corner[Mp-1,1:Lp] - lon_corner[Mp-2,1:Lp]
lon_corner[:,0] = 2*lon_corner[:,1] - lon_corner[:,2]
lon_corner[:,Lp] = 2*lon_corner[:,Lp-1] - lon_corner[:,Lp-2]
lat_corner[0,1:Lp] = 2*lat_corner[1,1:Lp] - lat_corner[2,1:Lp]
lat_corner[Mp,1:Lp] = 2*lat_corner[Mp-1,1:Lp] - lat_corner[Mp-2,1:Lp]
lat_corner[:,0] = 2*lat_corner[:,1] - lat_corner[:,2]
lat_corner[:,Lp] = 2*lat_corner[:,Lp-1] - lat_corner[:,Lp-2]

##  create data remap file for scrip
print('Create remap grid file for Hill and Beamer runoff')
remap_filename = 'remap_grid_runoff.nc'
nc = netCDF.Dataset(remap_filename, 'w', format='NETCDF3_CLASSIC')
nc.Description = 'remap grid file for Hill and Beamer runoff data'
nc.Author = 'build_runoff'
nc.Created = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
nc.title = 'Hill and Beamer runoff'

grid_center_lon = lon.flatten()
grid_center_lat = lat.flatten()
Mp, Lp = lon.shape
grid_imask = mask.flatten()
grid_size = Lp * Mp
grid_corner_lon = np.zeros((grid_size, 4))
grid_corner_lat = np.zeros((grid_size, 4))
k = 0
for j in range(Mp):
    for i in range(Lp):
        grid_corner_lon[k,0] = lon_corner[j,i]
        grid_corner_lat[k,0] = lat_corner[j,i]
        grid_corner_lon[k,1] = lon_corner[j,i+1]
        grid_corner_lat[k,1] = lat_corner[j,i+1]
        grid_corner_lon[k,2] = lon_corner[j+1,i+1]
        grid_corner_lat[k,2] = lat_corner[j+1,i+1]
        grid_corner_lon[k,3] = lon_corner[j+1,i]
        grid_corner_lat[k,3] = lat_corner[j+1,i]
        k = k + 1

nc.createDimension('grid_size', grid_size)
nc.createDimension('grid_corners', 4)
nc.createDimension('grid_rank', 2)

nc.createVariable('grid_dims', 'i4', ('grid_rank'))
nc.variables['grid_dims'].long_name = 'grid size along x and y axis'
nc.variables['grid_dims'].units = 'None'
nc.variables['grid_dims'][:] = [(Lp, Mp)]

nc.createVariable('grid_center_lon', 'f8', ('grid_size'))
nc.variables['grid_center_lon'].long_name = 'longitude of cell center'
nc.variables['grid_center_lon'].units = 'degrees'
nc.variables['grid_center_lon'][:] = grid_center_lon

nc.createVariable('grid_center_lat', 'f8', ('grid_size'))
nc.variables['grid_center_lat'].long_name = 'latitude of cell center'
nc.variables['grid_center_lat'].units = 'degrees'
nc.variables['grid_center_lat'][:] = grid_center_lat

nc.createVariable('grid_imask', 'i4', ('grid_size'))
nc.variables['grid_imask'].long_name = 'mask'
nc.variables['grid_imask'].units = 'None'
nc.variables['grid_imask'][:] = grid_imask

nc.createVariable('grid_corner_lon', 'f8', ('grid_size', 'grid_corners'))
nc.variables['grid_corner_lon'].long_name = 'longitude of cell corner'
nc.variables['grid_corner_lon'].units = 'degrees'
nc.variables['grid_corner_lon'][:] = grid_corner_lon

nc.createVariable('grid_corner_lat', 'f8', ('grid_size', 'grid_corners'))
nc.variables['grid_corner_lat'].long_name = 'latitude of cell corner'
nc.variables['grid_corner_lat'].units = 'degrees'
nc.variables['grid_corner_lat'][:] = grid_corner_lat

nc.close()


#  create NWGOA remap file for scrip
print('Create remap grid file for NWGOA grid')
dstgrd = pycnal.grid.get_ROMS_grid('SEAKp_1km')
dstgrd.hgrid.mask_rho = np.ones(dstgrd.hgrid.mask_rho.shape)
pycnal.remapping.make_remap_grid_file(dstgrd, Cpos='rho')


## compute remap weights
print('compute remap weights using scrip')
# input namelist variables for conservative remapping at rho points
grid1_file = 'remap_grid_runoff.nc'
grid2_file = 'remap_grid_SEAKp_1km_rho.nc'
interp_file1 = 'remap_weights_runoff_to_SEAKp_1km_conservative_nomask.nc'
interp_file2 = 'remap_weights_SEAKp_1km_to_runoff_conservative_nomask.nc'
map1_name = 'Hill to SEAKp_1km conservative Mapping'
map2_name = 'SEAKp_1km to Hill conservative Mapping'
num_maps = 1
map_method = 'conservative'

pycnal.remapping.compute_remap_weights(grid1_file, grid2_file, \
              interp_file1, interp_file2, map1_name, \
              map2_name, num_maps, map_method)
